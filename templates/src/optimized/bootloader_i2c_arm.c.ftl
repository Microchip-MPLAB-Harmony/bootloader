/*******************************************************************************
  ${BTL_TYPE} Bootloader Source File

  File Name:
    bootloader_${BTL_TYPE?lower_case}.c

  Summary:
    This file contains source code necessary to execute ${BTL_TYPE} bootloader.

  Description:
    This file contains source code necessary to execute I2C bootloader.
    It implements bootloader protocol which uses I2C peripheral to download
    application firmware into internal flash.
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
 *******************************************************************************/
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Include Files
// *****************************************************************************
// *****************************************************************************

#include "definitions.h"
#include "bootloader_common.h"
#include <device.h>

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

#define SET_BIT(reg, bits)                      (reg |= (bits))
#define CLR_BIT(reg, bits)                      (reg &= ~(bits))
#define IS_BIT_SET(reg, bit)                    ((reg & bit)? true:false)

#define BL_BUFFER_SIZE                          ERASE_BLOCK_SIZE

#define BL_STATUS_BIT_BUSY                      (0x01 << 0)
#define BL_STATUS_BIT_INVALID_COMMAND           (0x01 << 1)
#define BL_STATUS_BIT_INVALID_MEM_ADDR          (0x01 << 2)
#define BL_STATUS_BIT_COMMAND_EXECUTION_ERROR   (0x01 << 3)      //Valid only when BL_STATUS_BIT_BUSY is 0
#define BL_STATUS_BIT_CRC_ERROR                 (0x01 << 4)
#define BL_STATUS_BIT_COMM_ERROR                (0x01 << 5)
#define BL_STATUS_BIT_ALL                       (BL_STATUS_BIT_BUSY | BL_STATUS_BIT_INVALID_COMMAND | BL_STATUS_BIT_INVALID_MEM_ADDR | \
                                                 BL_STATUS_BIT_COMMAND_EXECUTION_ERROR | BL_STATUS_BIT_CRC_ERROR | BL_STATUS_BIT_COMM_ERROR)

typedef enum
{
    BL_COMMAND_UNLOCK = 0xA0,
    BL_COMMAND_ERASE = 0xA1,
    BL_COMMAND_PROGRAM = 0xA2,
    BL_COMMAND_VERIFY = 0xA3,
    BL_COMMAND_RESET = 0xA4,
    BL_COMMAND_READ_STATUS = 0xA5,
<#if BTL_DUAL_BANK == true>
    BL_COMMAND_BKSWAP_RESET = 0xA6,
</#if>
<#if BTL_FUSE_PROGRAM_ENABLE == true>
    BL_COMMAND_DEVCFG_PROGRAM = 0xA7,
</#if>
    BL_COMMAND_READ_VERSION = 0xA8,
    BL_COMMAND_MAX,
}BL_COMMAND;

typedef enum
{
    BL_I2C_READ_COMMAND = 0,
    BL_I2C_READ_COMMAND_ARGUMENTS,
    BL_I2C_READ_PROGRAM_DATA,
}BL_I2C_READ_STATE;

typedef enum
{
    BL_FLASH_STATE_IDLE = 0,
    BL_FLASH_STATE_ERASE,
    BL_FLASH_STATE_WRITE,
    BL_FLASH_STATE_VERIFY,
    BL_FLASH_STATE_RESET,
    BL_FLASH_STATE_ERASE_BUSY_POLL,
    BL_FLASH_STATE_WRITE_BUSY_POLL,
<#if BTL_DUAL_BANK == true>
    BL_FLASH_STATE_BKSWAP_RESET,
</#if>
}BL_FLASH_STATE;

typedef struct
{
    uint32_t                                appImageStartAddr;
    uint32_t                                appImageSize;
}BL_COMMAND_PROTOCOL_UNLOCK;

typedef struct
{
    uint32_t                                nBytes;
    uint32_t                                memAddr;
    uint8_t                                 data[BL_BUFFER_SIZE];
}BL_COMMAND_PROTOCOL_PROGRAM;

typedef struct
{
    uint32_t                                memAddr;
}BL_COMMAND_PROTOCOL_ERASE;

typedef struct
{
    uint32_t                                crc;
}BL_COMMAND_PROTOCOL_VERIFY;

typedef union __ALIGNED(4)
{
    uint32_t                                cmdArg[2];
    BL_COMMAND_PROTOCOL_UNLOCK              unlockCommand;
    BL_COMMAND_PROTOCOL_ERASE               eraseCommand;
    BL_COMMAND_PROTOCOL_PROGRAM             programCommand;
    BL_COMMAND_PROTOCOL_VERIFY              verifyCommand;
}BL_COMMAND_PROTOCOL;

typedef struct
{
    int32_t                                 index;
    uint32_t                                nCmdArgWords;
    BL_I2C_READ_STATE                       rdState;
    BL_FLASH_STATE                          flashState;
    BL_COMMAND                              command;
    uint8_t                                 status;
    uint32_t                                appImageStartAddr;
    uint32_t                                appImageEndAddr;
    uint32_t                                nFlashBytesWritten;
    BL_COMMAND_PROTOCOL                     cmdProtocol;
}BL_PROTOCOL;



// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

static BL_PROTOCOL blProtocol;

static bool i2cBLActive = false;

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Local Functions
// *****************************************************************************
// *****************************************************************************

static void BL_I2C_SendResponse(uint8_t command)
{
    static uint8_t numVersionBytesSent = 0;
    uint16_t btlVersion = 0;

    switch(command)
    {
        case BL_COMMAND_READ_STATUS:
            ${PERIPH_USED}_WriteByte(blProtocol.status);

            /* Clear all status bits except the busy bit */
            CLR_BIT(blProtocol.status, (BL_STATUS_BIT_ALL & ~(BL_STATUS_BIT_BUSY)));

            break;

        case BL_COMMAND_READ_VERSION:
            btlVersion = bootloader_GetVersion();

            if (numVersionBytesSent == 0)
            {
                ${PERIPH_USED}_WriteByte(((btlVersion >> 8) & 0xFF));

                numVersionBytesSent = 1;
            }
            else
            {
                ${PERIPH_USED}_WriteByte((btlVersion & 0xFF));

                numVersionBytesSent = 0;
            }

            break;

        default:
            break;
    }
}

static bool BL_I2C_MasterWriteHandler(uint8_t rdByte)
{
    switch(blProtocol.rdState)
    {
        case BL_I2C_READ_COMMAND:
            blProtocol.command = rdByte;
            /* Set default value of index to 3. Over-write below if needed */
            blProtocol.index = 3;

            blProtocol.nCmdArgWords = 0;

            if ((blProtocol.command < BL_COMMAND_UNLOCK) || (blProtocol.command >= BL_COMMAND_MAX))
            {
                SET_BIT(blProtocol.status, BL_STATUS_BIT_INVALID_COMMAND);
                return false;
            }
            else if (blProtocol.command == BL_COMMAND_RESET)
            {
                blProtocol.flashState = BL_FLASH_STATE_RESET;
            }
<#if BTL_DUAL_BANK == true>
            else if (blProtocol.command == BL_COMMAND_BKSWAP_RESET)
            {
                blProtocol.flashState = BL_FLASH_STATE_BKSWAP_RESET;
            }
</#if>
            else if ((blProtocol.command == BL_COMMAND_READ_STATUS) || (blProtocol.command == BL_COMMAND_READ_VERSION))
            {
                /* Do Nothing */
            }
            else
            {
                /* All commands transition to the BL_I2C_READ_COMMAND_ARGUMENTS state */
                blProtocol.rdState = BL_I2C_READ_COMMAND_ARGUMENTS;
            }
            break;
        case BL_I2C_READ_COMMAND_ARGUMENTS:
            ((uint8_t*)&blProtocol.cmdProtocol.cmdArg[blProtocol.nCmdArgWords])[blProtocol.index--] = rdByte;

            if (blProtocol.index < 0)
            {
                /* Program enters here after receiving each word of the command argument */
                blProtocol.nCmdArgWords++;

<#if BTL_FUSE_PROGRAM_ENABLE == true>
                if ((blProtocol.command == BL_COMMAND_UNLOCK) || (blProtocol.command == BL_COMMAND_PROGRAM) || (blProtocol.command == BL_COMMAND_DEVCFG_PROGRAM))
<#else>
                if ((blProtocol.command == BL_COMMAND_UNLOCK) || (blProtocol.command == BL_COMMAND_PROGRAM))
</#if>
                {
                    if (blProtocol.nCmdArgWords < 2)
                    {
                        blProtocol.index = 3;
                    }
                }
            }

            if (blProtocol.index < 0)
            {
                /* Set default state to BL_I2C_READ_COMMAND. Over-write below if needed */
                blProtocol.rdState = BL_I2C_READ_COMMAND;

                if (blProtocol.command == BL_COMMAND_UNLOCK)
                {
                    /* Since this is the first command, clear any previously set status bits (host may be retrying and status may be set from previous communication) */
                    CLR_BIT(blProtocol.status, BL_STATUS_BIT_ALL);

                    /* Save application start address and size for future reference */
                    if ((blProtocol.cmdProtocol.unlockCommand.appImageStartAddr + blProtocol.cmdProtocol.unlockCommand.appImageSize) > (FLASH_START + FLASH_LENGTH))
                    {
                        SET_BIT(blProtocol.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }
                    else
                    {
                        blProtocol.appImageStartAddr = blProtocol.cmdProtocol.unlockCommand.appImageStartAddr;
                        blProtocol.appImageEndAddr = blProtocol.cmdProtocol.unlockCommand.appImageStartAddr + blProtocol.cmdProtocol.unlockCommand.appImageSize;
                    }
                }
                else if (blProtocol.command == BL_COMMAND_PROGRAM)
                {
                    if ((blProtocol.cmdProtocol.programCommand.memAddr < blProtocol.appImageStartAddr) || (blProtocol.cmdProtocol.programCommand.nBytes > BL_BUFFER_SIZE)
                     || ((blProtocol.cmdProtocol.programCommand.memAddr + blProtocol.cmdProtocol.programCommand.nBytes) > blProtocol.appImageEndAddr))
                    {
                        SET_BIT(blProtocol.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }
                    else
                    {
                        blProtocol.index = 0;
                        blProtocol.rdState = BL_I2C_READ_PROGRAM_DATA;
                    }
                }
                else if (blProtocol.command == BL_COMMAND_ERASE)
                {
<#if BTL_FUSE_PROGRAM_ENABLE == true>
                    if (((blProtocol.cmdProtocol.eraseCommand.memAddr >= blProtocol.appImageStartAddr) && ((blProtocol.cmdProtocol.eraseCommand.memAddr + ERASE_BLOCK_SIZE) <= blProtocol.appImageEndAddr))
                        || ((blProtocol.cmdProtocol.eraseCommand.memAddr >= ${MEM_USED}_USERROW_START_ADDRESS) && ((blProtocol.cmdProtocol.eraseCommand.memAddr + ERASE_BLOCK_SIZE) <= (${MEM_USED}_USERROW_START_ADDRESS + ${MEM_USED}_USERROW_SIZE)))
    <#if .vars["${MEM_USED?lower_case}"].FLASH_BOCORROW_START_ADDRESS??>
                        || ((blProtocol.cmdProtocol.eraseCommand.memAddr >= ${MEM_USED}_BOCORROW_START_ADDRESS) && ((blProtocol.cmdProtocol.eraseCommand.memAddr + ERASE_BLOCK_SIZE) <= (${MEM_USED}_BOCORROW_START_ADDRESS + ${MEM_USED}_BOCORROW_SIZE)))
    </#if>
                       )
<#else>
                    if ((blProtocol.cmdProtocol.eraseCommand.memAddr >= blProtocol.appImageStartAddr) && ((blProtocol.cmdProtocol.eraseCommand.memAddr + ERASE_BLOCK_SIZE) <= blProtocol.appImageEndAddr))
</#if>
                    {
                        SET_BIT(blProtocol.status, BL_STATUS_BIT_BUSY);
                        blProtocol.flashState = BL_FLASH_STATE_ERASE;
                    }
                    else
                    {
                        SET_BIT(blProtocol.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }
                }
<#if BTL_FUSE_PROGRAM_ENABLE == true>
                else if (blProtocol.command == BL_COMMAND_DEVCFG_PROGRAM)
                {
                    if (((blProtocol.cmdProtocol.programCommand.memAddr >= ${MEM_USED}_USERROW_START_ADDRESS)
                          && (blProtocol.cmdProtocol.programCommand.nBytes <= BL_BUFFER_SIZE)
                          && ((blProtocol.cmdProtocol.programCommand.memAddr + blProtocol.cmdProtocol.programCommand.nBytes) <= (${MEM_USED}_USERROW_START_ADDRESS + ${MEM_USED}_USERROW_SIZE)))
    <#if .vars["${MEM_USED?lower_case}"].FLASH_BOCORROW_START_ADDRESS??>
                        || ((blProtocol.cmdProtocol.programCommand.memAddr >= ${MEM_USED}_BOCORROW_START_ADDRESS)
                          && (blProtocol.cmdProtocol.programCommand.nBytes <= BL_BUFFER_SIZE)
                          && ((blProtocol.cmdProtocol.programCommand.memAddr + blProtocol.cmdProtocol.programCommand.nBytes) <= (${MEM_USED}_BOCORROW_START_ADDRESS + ${MEM_USED}_BOCORROW_SIZE)))
    </#if>
                        )
                    {
                        blProtocol.index = 0;
                        blProtocol.rdState = BL_I2C_READ_PROGRAM_DATA;
                    }
                    else
                    {
                        SET_BIT(blProtocol.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }
                }
</#if>
                else if (blProtocol.command == BL_COMMAND_VERIFY)
                {
                   SET_BIT(blProtocol.status, BL_STATUS_BIT_BUSY);
                   blProtocol.flashState = BL_FLASH_STATE_VERIFY;
                }
            }
            break;
        case BL_I2C_READ_PROGRAM_DATA:
            blProtocol.cmdProtocol.programCommand.data[blProtocol.index++] = rdByte;
            if (blProtocol.index >= blProtocol.cmdProtocol.programCommand.nBytes)
            {
                SET_BIT(blProtocol.status, BL_STATUS_BIT_BUSY);
                blProtocol.nFlashBytesWritten = 0;
                blProtocol.rdState = BL_I2C_READ_COMMAND;
                blProtocol.flashState = BL_FLASH_STATE_WRITE;
            }
            break;
        default:
            break;
    }
    return true;
}

<#if PERIPH_USED?starts_with("TWIHS")>
static void BL_I2C_EventsProcess(void)
{
    TWIHS_SLAVE_STATUS_FLAG statusRegister;

    statusRegister = ${PERIPH_USED}_StatusGet();

    if (statusRegister & TWIHS_SR_SVACC_Msk) //host is accessing our client address
    {
        i2cBLActive   = true;

        if (IS_BIT_SET(blProtocol.status, BL_STATUS_BIT_BUSY)) //if client is busy, send back a NACK
        {
            ${PERIPH_USED}_NACKDataPhase(true);
        }
        else //client is not busy
        {
            if (statusRegister & TWIHS_SR_SVREAD_Msk) //if host is reading
            {
                BL_I2C_SendResponse(blProtocol.command);
            }
            else //if host is writing
            {
                if (statusRegister & TWIHS_SR_RXRDY_Msk) //we have received a character from the host
                {
                    if (BL_I2C_MasterWriteHandler(${PERIPH_USED}_ReadByte()) == true) //reading the byte will clear the RXRDY bit
                    {
                        ${PERIPH_USED}_NACKDataPhase(false);
                    }
                    else
                    {
                        ${PERIPH_USED}_NACKDataPhase(true);
                    }
                }
                else
                {
                    //do nothing, just wait for next character
                }
            }
        }
    }
    else if ((statusRegister & TWIHS_SR_SVACC_Msk) == 0) //if SVCACC=0, that is end of access
    {
        /* Reset the I2C read state machine */
        blProtocol.rdState = BL_I2C_READ_COMMAND;
    }
    else
    {
        //do nothing
    }
}
<#else>
static void BL_I2C_EventsProcess(void)
{

    static bool isFirstRxByte;
    static bool transferDir;
    <#assign PERIPHERAL_INST_NAME = PERIPH_INSTANCE_NAME>
    <#if .vars[PERIPHERAL_INST_NAME].I2CS_INTENSET_ERROR>
    SERCOM_I2C_SLAVE_ERROR error;
    </#if>
    SERCOM_I2C_SLAVE_INTFLAG intFlags = ${PERIPH_USED}_InterruptFlagsGet();

    <#if .vars[PERIPHERAL_INST_NAME].I2CS_INTENSET_ERROR>
    if (intFlags & SERCOM_I2C_SLAVE_INTFLAG_ERROR)
    {
        error = ${PERIPH_USED}_ErrorGet();
        (void)error;

        ${PERIPH_USED}_InterruptFlagsClear(SERCOM_I2C_SLAVE_INTFLAG_ERROR);

        SET_BIT(blProtocol.status, BL_STATUS_BIT_COMM_ERROR);
    }
    else <#else>    </#if>if (intFlags & SERCOM_I2C_SLAVE_INTFLAG_AMATCH)
    {
        isFirstRxByte = true;
        i2cBLActive   = true;

        transferDir = ${PERIPH_USED}_TransferDirGet();

        /* Reset the I2C read state machine */
        blProtocol.rdState = BL_I2C_READ_COMMAND;

        if (IS_BIT_SET(blProtocol.status, BL_STATUS_BIT_BUSY))
        {
            ${PERIPH_USED}_CommandSet(SERCOM_I2C_SLAVE_COMMAND_SEND_NAK);
        }
        else
        {
            ${PERIPH_USED}_CommandSet(SERCOM_I2C_SLAVE_COMMAND_SEND_ACK);
        }
    }
    else if (intFlags & SERCOM_I2C_SLAVE_INTFLAG_DRDY)
    {
        if (transferDir == SERCOM_I2C_SLAVE_TRANSFER_DIR_WRITE)
        {
            if (BL_I2C_MasterWriteHandler(${PERIPH_USED}_ReadByte()) == true)
            {
                ${PERIPH_USED}_CommandSet(SERCOM_I2C_SLAVE_COMMAND_SEND_ACK);
            }
            else
            {
                ${PERIPH_USED}_CommandSet(SERCOM_I2C_SLAVE_COMMAND_SEND_NAK);
            }
        }
        else
        {
            if ((isFirstRxByte == true) || (${PERIPH_USED}_LastByteAckStatusGet() == SERCOM_I2C_SLAVE_ACK_STATUS_RECEIVED_ACK))
            {
                BL_I2C_SendResponse(blProtocol.command);

                isFirstRxByte = false;

                ${PERIPH_USED}_CommandSet(SERCOM_I2C_SLAVE_COMMAND_RECEIVE_ACK_NAK);
            }
            else
            {
                ${PERIPH_USED}_CommandSet(SERCOM_I2C_SLAVE_COMMAND_WAIT_FOR_START);
            }
        }

    }
    else if (intFlags & SERCOM_I2C_SLAVE_INTFLAG_PREC)
    {
        ${PERIPH_USED}_InterruptFlagsClear(SERCOM_I2C_SLAVE_INTFLAG_PREC);
    }
}
</#if>

static void BL_I2C_FlashTask(void)
{
    switch(blProtocol.flashState)
    {
        case BL_FLASH_STATE_ERASE:
<#if .vars["${MEM_USED?lower_case}"].NVMCTRL_REGION_LOCK_UNLOCK_WITHOUT_ADDR?? && .vars["${MEM_USED?lower_case}"].NVMCTRL_REGION_LOCK_UNLOCK_WITHOUT_ADDR == true>
            if ((blProtocol.cmdProtocol.eraseCommand.memAddr >= blProtocol.appImageStartAddr) && ((blProtocol.cmdProtocol.eraseCommand.memAddr + ERASE_BLOCK_SIZE) <= blProtocol.appImageEndAddr))
            {
                if (blProtocol.cmdProtocol.eraseCommand.memAddr < APP_START_ADDRESS)
                {
                    ${MEM_USED}_SecureRegionUnlock(NVMCTRL_SECURE_MEMORY_REGION_BOOTLOADER);
                }
                else
                {
    <#if __TRUSTZONE_ENABLED?? && __TRUSTZONE_ENABLED == "true">
                    ${MEM_USED}_SecureRegionUnlock(NVMCTRL_SECURE_MEMORY_REGION_APPLICATION);

                    while(${MEM_USED}_IsBusy() == true)
                    {
        <#if BTL_WDOG_ENABLE?? &&  BTL_WDOG_ENABLE == true>
                    kickdog();
        </#if>
                    }

    </#if>
                    ${MEM_USED}_RegionUnlock(NVMCTRL_MEMORY_REGION_APPLICATION);
                }

                while(${MEM_USED}_IsBusy() == true)
                {
        <#if BTL_WDOG_ENABLE?? &&  BTL_WDOG_ENABLE == true>
                    kickdog();
        </#if>
                }
            }
<#else>
            // Lock region size is always bigger than the row size
            ${MEM_USED}_RegionUnlock(blProtocol.cmdProtocol.eraseCommand.memAddr);

            while(${MEM_USED}_IsBusy() == true)
            {
            }
</#if>

<#if BTL_FUSE_PROGRAM_ENABLE == true>
            if ((blProtocol.cmdProtocol.eraseCommand.memAddr >= blProtocol.appImageStartAddr) && ((blProtocol.cmdProtocol.eraseCommand.memAddr + ERASE_BLOCK_SIZE) <= blProtocol.appImageEndAddr))
            {
                /* Erase the Current row */
                ${.vars["${MEM_USED?lower_case}"].ERASE_API_NAME}(blProtocol.cmdProtocol.eraseCommand.memAddr);
            }
            else
            {
                if ((blProtocol.cmdProtocol.eraseCommand.memAddr >= ${MEM_USED}_USERROW_START_ADDRESS) && (blProtocol.cmdProtocol.eraseCommand.memAddr < (${MEM_USED}_USERROW_START_ADDRESS + ${MEM_USED}_USERROW_SIZE)))
                {
                    /* Erase the NVM user row */
                    ${.vars["${MEM_USED?lower_case}"].USER_ROW_ERASE_API_NAME}(blProtocol.cmdProtocol.eraseCommand.memAddr);
                }
    <#if .vars["${MEM_USED?lower_case}"].FLASH_BOCORROW_START_ADDRESS??>
                else if ((blProtocol.cmdProtocol.eraseCommand.memAddr >= ${MEM_USED}_BOCORROW_START_ADDRESS) && (blProtocol.cmdProtocol.eraseCommand.memAddr < (${MEM_USED}_BOCORROW_START_ADDRESS + ${MEM_USED}_BOCORROW_SIZE)))
                {
                    /* Erase the NVM BOCOR row */
                    ${.vars["${MEM_USED?lower_case}"].BOCOR_ROW_ERASE_API_NAME}(blProtocol.cmdProtocol.eraseCommand.memAddr);
                }
    </#if>
            }
<#else>
            /* Erase the Current row */
            ${.vars["${MEM_USED?lower_case}"].ERASE_API_NAME}(blProtocol.cmdProtocol.eraseCommand.memAddr);
</#if>

            blProtocol.flashState = BL_FLASH_STATE_ERASE_BUSY_POLL;
            break;

        case BL_FLASH_STATE_WRITE:
<#if BTL_FUSE_PROGRAM_ENABLE == true>
            if (blProtocol.command == BL_COMMAND_DEVCFG_PROGRAM)
            {
                if ((blProtocol.cmdProtocol.programCommand.memAddr >= ${MEM_USED}_USERROW_START_ADDRESS) && (blProtocol.cmdProtocol.programCommand.memAddr < (${MEM_USED}_USERROW_START_ADDRESS + ${MEM_USED}_USERROW_SIZE)))
                {
                    /* Write the NVM user row */
                    ${.vars["${MEM_USED?lower_case}"].USER_ROW_WRITE_API_NAME}((uint32_t*)&blProtocol.cmdProtocol.programCommand.data[blProtocol.nFlashBytesWritten], (blProtocol.cmdProtocol.programCommand.memAddr + blProtocol.nFlashBytesWritten));
                }
    <#if .vars["${MEM_USED?lower_case}"].FLASH_BOCORROW_START_ADDRESS??>
                else if ((blProtocol.cmdProtocol.programCommand.memAddr >= ${MEM_USED}_BOCORROW_START_ADDRESS) && (blProtocol.cmdProtocol.programCommand.memAddr < (${MEM_USED}_BOCORROW_START_ADDRESS + ${MEM_USED}_BOCORROW_SIZE)))
                {
                    /* Write the NVM user row */
                    ${.vars["${MEM_USED?lower_case}"].BOCOR_ROW_WRITE_API_NAME}((uint32_t*)&blProtocol.cmdProtocol.programCommand.data[blProtocol.nFlashBytesWritten], (blProtocol.cmdProtocol.programCommand.memAddr + blProtocol.nFlashBytesWritten));
                }
    </#if>
            }
            else
            {
                ${.vars["${MEM_USED?lower_case}"].WRITE_API_NAME}((uint32_t*)&blProtocol.cmdProtocol.programCommand.data[blProtocol.nFlashBytesWritten], (blProtocol.cmdProtocol.programCommand.memAddr + blProtocol.nFlashBytesWritten));
            }
<#else>
            ${.vars["${MEM_USED?lower_case}"].WRITE_API_NAME}((uint32_t*)&blProtocol.cmdProtocol.programCommand.data[blProtocol.nFlashBytesWritten], (blProtocol.cmdProtocol.programCommand.memAddr + blProtocol.nFlashBytesWritten));
</#if>
            blProtocol.flashState = BL_FLASH_STATE_WRITE_BUSY_POLL;
            break;

        case BL_FLASH_STATE_VERIFY:
            if (bootloader_CRCGenerate(blProtocol.appImageStartAddr, (blProtocol.appImageEndAddr - blProtocol.appImageStartAddr)) != blProtocol.cmdProtocol.verifyCommand.crc)
            {
                SET_BIT(blProtocol.status, BL_STATUS_BIT_CRC_ERROR);
            }
            CLR_BIT(blProtocol.status, BL_STATUS_BIT_BUSY);
            blProtocol.flashState = BL_FLASH_STATE_IDLE;
            break;

        case BL_FLASH_STATE_ERASE_BUSY_POLL:
            if(${MEM_USED}_IsBusy() == false)
            {
                CLR_BIT(blProtocol.status, BL_STATUS_BIT_BUSY);
                blProtocol.flashState = BL_FLASH_STATE_IDLE;
            }
            break;

        case BL_FLASH_STATE_WRITE_BUSY_POLL:
            if(${MEM_USED}_IsBusy() == false)
            {
                blProtocol.nFlashBytesWritten += PAGE_SIZE;

                if (blProtocol.nFlashBytesWritten < blProtocol.cmdProtocol.programCommand.nBytes)
                {
                    blProtocol.flashState = BL_FLASH_STATE_WRITE;
                }
                else
                {
                    CLR_BIT(blProtocol.status, BL_STATUS_BIT_BUSY);
                    blProtocol.flashState = BL_FLASH_STATE_IDLE;
                }
            }
            break;

        case BL_FLASH_STATE_RESET:
            /* Wait for the I2C transfer to complete */
<#if PERIPH_USED?starts_with("TWIHS")>
            while ((${PERIPH_USED}_REGS->TWIHS_SR & TWIHS_SR_SVACC_Msk) == TWIHS_SR_SVACC_Msk);
<#else>
            while (!(${PERIPH_USED}_InterruptFlagsGet() & SERCOM_I2C_SLAVE_INTFLAG_PREC));
</#if>

            bootloader_TriggerReset();
            break;

<#if BTL_DUAL_BANK == true>
        case BL_FLASH_STATE_BKSWAP_RESET:
            /* Wait for the I2C transfer to complete */
            while (!(${PERIPH_USED}_InterruptFlagsGet() & SERCOM_I2C_SLAVE_INTFLAG_PREC));
            ${MEM_USED}_BankSwap();
            break;
</#if>

        case BL_FLASH_STATE_IDLE:
            /* Do nothing */
            break;

        default:
            break;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Global Functions
// *****************************************************************************
// *****************************************************************************

void bootloader_${BTL_TYPE}_Tasks(void)
{
    do
    {
<#if BTL_WDOG_ENABLE?? &&  BTL_WDOG_ENABLE == true>
        kickdog();

</#if>
<#if BTL_CMD_STRETCH_CLK == true>
        if (IS_BIT_SET(blProtocol.status, BL_STATUS_BIT_BUSY) == false)
        {
            BL_I2C_EventsProcess();
        }

<#else>
        BL_I2C_EventsProcess();

</#if>
        BL_I2C_FlashTask();
    } while (i2cBLActive);
}
