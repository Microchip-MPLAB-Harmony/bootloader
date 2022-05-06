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

<#if BTL_FUSE_PROGRAM_ENABLE == true>
    <#lt>#define DEVCFG_ADDRESS                          ${BTL_DEVCFG_ADDRESS}
    <#lt>#define DEVCFG_PAGE_ADDRESS                     (DEVCFG_ADDRESS & (~ERASE_BLOCK_SIZE + 1))
</#if>

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

static volatile BL_PROTOCOL                 i2cBLData;

static bool i2cBLInitDone      = false;

static bool i2cBLActive        = false;

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
            ${PERIPH_USED}_WriteByte(i2cBLData.status);

            /* Clear all status bits except the busy bit */
            CLR_BIT(i2cBLData.status, (BL_STATUS_BIT_ALL & ~(BL_STATUS_BIT_BUSY)));

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

static bool BL_I2C_CommandParser(uint8_t rdByte)
{
    switch(i2cBLData.rdState)
    {
        case BL_I2C_READ_COMMAND:
            i2cBLData.command = rdByte;
            /* Set default value of index to 3. Over-write below if needed */
            i2cBLData.index = 3;

            i2cBLData.nCmdArgWords = 0;

            if ((i2cBLData.command < BL_COMMAND_UNLOCK) || (i2cBLData.command >= BL_COMMAND_MAX))
            {
                SET_BIT(i2cBLData.status, BL_STATUS_BIT_INVALID_COMMAND);
                return false;
            }
            else if (i2cBLData.command == BL_COMMAND_RESET)
            {
                i2cBLData.flashState = BL_FLASH_STATE_RESET;
            }
<#if BTL_DUAL_BANK == true>
            else if (i2cBLData.command == BL_COMMAND_BKSWAP_RESET)
            {
                i2cBLData.flashState = BL_FLASH_STATE_BKSWAP_RESET;
            }
</#if>
            else if ((i2cBLData.command == BL_COMMAND_READ_STATUS) || (i2cBLData.command == BL_COMMAND_READ_VERSION))
            {
                /* Do Nothing */
            }
            else
            {
                /* All commands transition to the BL_I2C_READ_COMMAND_ARGUMENTS state */
                i2cBLData.rdState = BL_I2C_READ_COMMAND_ARGUMENTS;
            }
            break;
        case BL_I2C_READ_COMMAND_ARGUMENTS:
            ((uint8_t*)&i2cBLData.cmdProtocol.cmdArg[i2cBLData.nCmdArgWords])[i2cBLData.index--] = rdByte;

            if (i2cBLData.index < 0)
            {
                /* Program enters here after receiving each word of the command argument */
                i2cBLData.nCmdArgWords++;

<#if BTL_FUSE_PROGRAM_ENABLE == true>
                if ((i2cBLData.command == BL_COMMAND_UNLOCK) || (i2cBLData.command == BL_COMMAND_PROGRAM) || (i2cBLData.command == BL_COMMAND_DEVCFG_PROGRAM))
<#else>
                if ((i2cBLData.command == BL_COMMAND_UNLOCK) || (i2cBLData.command == BL_COMMAND_PROGRAM))
</#if>
                {
                    if (i2cBLData.nCmdArgWords < 2)
                    {
                        i2cBLData.index = 3;
                    }
                }
            }

            if (i2cBLData.index < 0)
            {
                /* Set default state to BL_I2C_READ_COMMAND. Over-write below if needed */
                i2cBLData.rdState = BL_I2C_READ_COMMAND;

                if (i2cBLData.command == BL_COMMAND_UNLOCK)
                {
                    /* Since this is the first command, clear any previously set status bits (host may be retrying and status may be set from previous communication) */
                    CLR_BIT(i2cBLData.status, BL_STATUS_BIT_ALL);

                    /* Save application start address and size for future reference */
                    if ((i2cBLData.cmdProtocol.unlockCommand.appImageStartAddr + i2cBLData.cmdProtocol.unlockCommand.appImageSize) > (FLASH_START + FLASH_LENGTH))
                    {
                        SET_BIT(i2cBLData.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }
                    else
                    {
                        i2cBLData.appImageStartAddr = i2cBLData.cmdProtocol.unlockCommand.appImageStartAddr;
                        i2cBLData.appImageEndAddr = i2cBLData.cmdProtocol.unlockCommand.appImageStartAddr + i2cBLData.cmdProtocol.unlockCommand.appImageSize;
                    }
                }
                else if (i2cBLData.command == BL_COMMAND_PROGRAM)
                {
                    if ((i2cBLData.cmdProtocol.programCommand.memAddr < i2cBLData.appImageStartAddr) || (i2cBLData.cmdProtocol.programCommand.nBytes > BL_BUFFER_SIZE)
                     || ((i2cBLData.cmdProtocol.programCommand.memAddr + i2cBLData.cmdProtocol.programCommand.nBytes) > i2cBLData.appImageEndAddr))
                    {
                        SET_BIT(i2cBLData.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }
                    else
                    {
                        i2cBLData.index = 0;
                        i2cBLData.rdState = BL_I2C_READ_PROGRAM_DATA;
                    }
                }
                else if (i2cBLData.command == BL_COMMAND_ERASE)
                {
<#if BTL_DUAL_BANK == true>
                    if (i2cBLData.cmdProtocol.eraseCommand.memAddr == LOWER_FLASH_SERIAL_SECTOR)
                    {
                        /* Send error response if active Flash Panels (Lower Flash)
                         * Serial Sector is being erased.
                         */
                        SET_BIT(i2cBLData.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }

</#if>
<#if BTL_FUSE_PROGRAM_ENABLE == true>
                    if (((i2cBLData.cmdProtocol.eraseCommand.memAddr >= i2cBLData.appImageStartAddr) && ((i2cBLData.cmdProtocol.eraseCommand.memAddr + ERASE_BLOCK_SIZE) <= i2cBLData.appImageEndAddr))
                        || (i2cBLData.cmdProtocol.eraseCommand.memAddr >= DEVCFG_PAGE_ADDRESS)
                       )
<#else>
                    if ((i2cBLData.cmdProtocol.eraseCommand.memAddr >= i2cBLData.appImageStartAddr) && ((i2cBLData.cmdProtocol.eraseCommand.memAddr + ERASE_BLOCK_SIZE) <= i2cBLData.appImageEndAddr))
</#if>
                    {
                        SET_BIT(i2cBLData.status, BL_STATUS_BIT_BUSY);
                        i2cBLData.flashState = BL_FLASH_STATE_ERASE;
                    }
                    else
                    {
                        SET_BIT(i2cBLData.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }
                }
<#if BTL_FUSE_PROGRAM_ENABLE == true>
                else if (i2cBLData.command == BL_COMMAND_DEVCFG_PROGRAM)
                {
                    if ((i2cBLData.cmdProtocol.programCommand.memAddr >= DEVCFG_PAGE_ADDRESS)
                          && (i2cBLData.cmdProtocol.programCommand.nBytes <= BL_BUFFER_SIZE))
                    {
                        i2cBLData.index = 0;
                        i2cBLData.rdState = BL_I2C_READ_PROGRAM_DATA;
                    }
                    else
                    {
                        SET_BIT(i2cBLData.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }
                }
</#if>
                else if (i2cBLData.command == BL_COMMAND_VERIFY)
                {
                   SET_BIT(i2cBLData.status, BL_STATUS_BIT_BUSY);
                   i2cBLData.flashState = BL_FLASH_STATE_VERIFY;
                }
            }
            break;
        case BL_I2C_READ_PROGRAM_DATA:
            i2cBLData.cmdProtocol.programCommand.data[i2cBLData.index++] = rdByte;
            if (i2cBLData.index >= i2cBLData.cmdProtocol.programCommand.nBytes)
            {
                SET_BIT(i2cBLData.status, BL_STATUS_BIT_BUSY);
                i2cBLData.nFlashBytesWritten = 0;
                i2cBLData.flashState = BL_FLASH_STATE_WRITE;
                i2cBLData.rdState = BL_I2C_READ_COMMAND;
            }
            break;
        default:
            break;
    }
    return true;
}

static bool BL_I2C_EventHandler( I2C_SLAVE_TRANSFER_EVENT event, uintptr_t contextHandle )
{
    bool isSendACK = true;

    switch(event)
    {
        case I2C_SLAVE_TRANSFER_EVENT_ADDR_MATCH:
            i2cBLActive   = true;

            /* Reset the I2C read state machine */
            i2cBLData.rdState = BL_I2C_READ_COMMAND;

            if (IS_BIT_SET(i2cBLData.status, BL_STATUS_BIT_BUSY))
            {
                isSendACK = false;
            }
            break;

        case I2C_SLAVE_TRANSFER_EVENT_RX_READY:

            if (BL_I2C_CommandParser(${PERIPH_USED}_ReadByte()) == false)
            {
                isSendACK = false;
            }

            break;

        case I2C_SLAVE_TRANSFER_EVENT_TX_READY:
            BL_I2C_SendResponse(i2cBLData.command);

            break;

        case I2C_SLAVE_TRANSFER_EVENT_ERROR:
            SET_BIT(i2cBLData.status, BL_STATUS_BIT_COMM_ERROR);
            break;

        default:
            break;
    }

    return isSendACK;
}

static void BL_I2C_FlashTask(void)
{
    switch(i2cBLData.flashState)
    {
        case BL_FLASH_STATE_ERASE:
<#if BTL_FUSE_PROGRAM_ENABLE == true>
    <#if (__PROCESSOR?matches("PIC32MX.*") == false) || (__PROCESSOR?matches("PIC32MZ.[0-9]*W") == false)>
            if (i2cBLData.cmdProtocol.eraseCommand.memAddr >= DEVCFG_PAGE_ADDRESS)
            {
                ${MEM_USED}_BootFlashWriteProtectDisable(NVM_LOWER_BOOT_WRITE_PROTECT_3);
            }

    </#if>
</#if>
<#if BTL_DUAL_BANK == true>
            if (i2cBLData.cmdProtocol.eraseCommand.memAddr == UPPER_FLASH_SERIAL_SECTOR)
            {
                bootloader_SetUpperFlashSerialErased(true);
            }

</#if>
            ${.vars["${MEM_USED?lower_case}"].ERASE_API_NAME}(i2cBLData.cmdProtocol.eraseCommand.memAddr);
            i2cBLData.flashState = BL_FLASH_STATE_ERASE_BUSY_POLL;

            break;

        case BL_FLASH_STATE_WRITE:
            ${.vars["${MEM_USED?lower_case}"].WRITE_API_NAME}((uint32_t*)&i2cBLData.cmdProtocol.programCommand.data[i2cBLData.nFlashBytesWritten], (i2cBLData.cmdProtocol.programCommand.memAddr + i2cBLData.nFlashBytesWritten));
            i2cBLData.flashState = BL_FLASH_STATE_WRITE_BUSY_POLL;
            break;

        case BL_FLASH_STATE_VERIFY:
            if (bootloader_CRCGenerate(i2cBLData.appImageStartAddr, (i2cBLData.appImageEndAddr - i2cBLData.appImageStartAddr)) != i2cBLData.cmdProtocol.verifyCommand.crc)
            {
                SET_BIT(i2cBLData.status, BL_STATUS_BIT_CRC_ERROR);
            }
            CLR_BIT(i2cBLData.status, BL_STATUS_BIT_BUSY);
            i2cBLData.flashState = BL_FLASH_STATE_IDLE;
            break;

        case BL_FLASH_STATE_ERASE_BUSY_POLL:
            if(${MEM_USED}_IsBusy() == false)
            {
                CLR_BIT(i2cBLData.status, BL_STATUS_BIT_BUSY);
                i2cBLData.flashState = BL_FLASH_STATE_IDLE;
            }
            break;

        case BL_FLASH_STATE_WRITE_BUSY_POLL:
            if(${MEM_USED}_IsBusy() == false)
            {
                i2cBLData.nFlashBytesWritten += PAGE_SIZE;

                if (i2cBLData.nFlashBytesWritten < i2cBLData.cmdProtocol.programCommand.nBytes)
                {
                    i2cBLData.flashState = BL_FLASH_STATE_WRITE;
                }
                else
                {
                    CLR_BIT(i2cBLData.status, BL_STATUS_BIT_BUSY);
                    i2cBLData.flashState = BL_FLASH_STATE_IDLE;
                }
            }
            break;

        case BL_FLASH_STATE_RESET:
            /* Wait for the I2C transfer to complete */
            while (${PERIPH_USED}_IsBusy());

            bootloader_TriggerReset();
            break;
<#if BTL_DUAL_BANK == true>

        case BL_FLASH_STATE_BKSWAP_RESET:
            /* Wait for the I2C transfer to complete */
            while (${PERIPH_USED}_IsBusy());

            bootloader_UpdateUpperFlashSerial();

            bootloader_TriggerReset();
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
    if (i2cBLInitDone == false)
    {
        i2cBLData.flashState = BL_FLASH_STATE_IDLE;

        ${PERIPH_USED}_CallbackRegister(BL_I2C_EventHandler, (uintptr_t)0);

        i2cBLInitDone = true;
    }

    do
    {
<#if BTL_WDOG_ENABLE?? &&  BTL_WDOG_ENABLE == true>
        kickdog();

</#if>
        BL_I2C_FlashTask();
    } while (i2cBLActive);
}
