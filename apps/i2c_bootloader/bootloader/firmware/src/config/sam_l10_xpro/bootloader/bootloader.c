/*******************************************************************************
  UART Bootloader Source File

  File Name:
    bootloader_i2c.c

  Summary:
    This file contains source code necessary to execute UART bootloader.

  Description:
    This file contains source code necessary to execute UART bootloader.
    It implements bootloader protocol which uses UART peripheral to download
    application firmware into internal flash from HOST-PC.
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
#include <device.h>

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

#define FLASH_START                             (0x00000000UL)
#define FLASH_LENGTH                            (0x10000UL)
#define PAGE_SIZE                               (64UL)
#define ERASE_BLOCK_SIZE                        (256UL)
#define PAGES_IN_ERASE_BLOCK                    (ERASE_BLOCK_SIZE / PAGE_SIZE)

#define BOOTLOADER_SIZE                         2048

#define SET_BIT(reg, bits)                      (reg |= (bits))
#define CLR_BIT(reg, bits)                      (reg &= ~(bits))
#define IS_BIT_SET(reg, bit)                    ((reg & bit)? true:false)

#define BL_APP_START_ADDRESS                    (0x800UL)
#define BL_BUFFER_SIZE                          ERASE_BLOCK_SIZE

#define BL_STATUS_BIT_BUSY                      (0x01 << 0)
#define BL_STATUS_BIT_INVALID_COMMAND           (0x01 << 1)
#define BL_STATUS_BIT_INVALID_MEM_ADDR          (0x01 << 2)
#define BL_STATUS_BIT_COMMAND_EXECUTION_ERROR   (0x01 << 3)      //Valid only when BL_STATUS_BIT_BUSY is 0
#define BL_STATUS_BIT_CRC_ERROR                 (0x01 << 4)
#define BL_STATUS_BIT_ALL                       (BL_STATUS_BIT_BUSY | BL_STATUS_BIT_INVALID_COMMAND | BL_STATUS_BIT_INVALID_MEM_ADDR | \
                                                 BL_STATUS_BIT_COMMAND_EXECUTION_ERROR | BL_STATUS_BIT_CRC_ERROR)

typedef enum
{
    BL_COMMAND_UNLOCK = 0xA0,
    BL_COMMAND_ERASE,
    BL_COMMAND_PROGRAM,
    BL_COMMAND_VERIFY,
    BL_COMMAND_RESET,
    BL_COMMAND_READ_STATUS,
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

static BL_PROTOCOL                          blProtocol;

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Local Functions
// *****************************************************************************
// *****************************************************************************

/* Function to Generate CRC using the device service unit peripheral on programmed data */
static uint32_t BL_CRCGenerate(void)
{
    uint32_t crc  = 0;

    PAC_PeripheralProtectSetup (PAC_PERIPHERAL_DSU, PAC_PROTECTION_CLEAR);

    DSU_CRCCalculate (
       blProtocol.appImageStartAddr,
       (blProtocol.appImageEndAddr - blProtocol.appImageStartAddr),
       0xffffffff,
       &crc
   );

    return crc;
}

/* Function to program received application firmware data into internal flash */

static bool BL_I2CMasterWriteHandler(uint8_t rdByte)
{
    switch(blProtocol.rdState)
    {
        case BL_I2C_READ_COMMAND:
            blProtocol.command = rdByte;
            /* Set default value of index to 3. Over-write below if needed */
            blProtocol.index = 3;

            blProtocol.nCmdArgWords = 0;

            if (blProtocol.command >= BL_COMMAND_MAX)
            {
                SET_BIT(blProtocol.status, BL_STATUS_BIT_INVALID_COMMAND);
                return false;
            }
            else if (blProtocol.command == BL_COMMAND_RESET)
            {
                blProtocol.flashState = BL_FLASH_STATE_RESET;
            }
            else if (blProtocol.command == BL_COMMAND_READ_STATUS)
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

                if ((blProtocol.command == BL_COMMAND_UNLOCK) || (blProtocol.command == BL_COMMAND_PROGRAM))
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
                    /* Save application start address and size for future reference */
                    if ((blProtocol.cmdProtocol.unlockCommand.appImageStartAddr + blProtocol.cmdProtocol.unlockCommand.appImageSize) < FLASH_LENGTH)
                    {
                        blProtocol.appImageStartAddr = blProtocol.cmdProtocol.unlockCommand.appImageStartAddr;
                        blProtocol.appImageEndAddr = blProtocol.cmdProtocol.unlockCommand.appImageStartAddr + blProtocol.cmdProtocol.unlockCommand.appImageSize;
                    }
                    else
                    {
                        SET_BIT(blProtocol.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
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
                    if ((blProtocol.cmdProtocol.eraseCommand.memAddr < blProtocol.appImageStartAddr) ||
                    ((blProtocol.cmdProtocol.eraseCommand.memAddr + ERASE_BLOCK_SIZE) > blProtocol.appImageEndAddr))
                    {
                        SET_BIT(blProtocol.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }
                    else
                    {
                        SET_BIT(blProtocol.status, BL_STATUS_BIT_BUSY);
                        blProtocol.flashState = BL_FLASH_STATE_ERASE;
                    }
                }
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

static void BL_I2C_EventsProcess(void)
{
    static bool isFirstRxByte;
    static bool transferDir;
    SERCOM_I2C_SLAVE_INTFLAG intFlags = SERCOM1_I2C_InterruptFlagsGet();

    if (intFlags & SERCOM_I2C_SLAVE_INTFLAG_AMATCH)
    {
        isFirstRxByte = true;

        transferDir = SERCOM1_I2C_TransferDirGet();

        /* Reset the I2C read state machine */
        blProtocol.rdState = BL_I2C_READ_COMMAND;

        if (IS_BIT_SET(blProtocol.status, BL_STATUS_BIT_BUSY))
        {
            SERCOM1_I2C_CommandSet(SERCOM_I2C_SLAVE_COMMAND_SEND_NAK);
        }
        else
        {
            SERCOM1_I2C_CommandSet(SERCOM_I2C_SLAVE_COMMAND_SEND_ACK);
        }
    }
    else if (intFlags & SERCOM_I2C_SLAVE_INTFLAG_DRDY)
    {
        if (transferDir == SERCOM_I2C_SLAVE_TRANSFER_DIR_WRITE)
        {
            if (BL_I2CMasterWriteHandler(SERCOM1_I2C_ReadByte()) == true)
            {
                SERCOM1_I2C_CommandSet(SERCOM_I2C_SLAVE_COMMAND_SEND_ACK);
            }
            else
            {
                SERCOM1_I2C_CommandSet(SERCOM_I2C_SLAVE_COMMAND_SEND_NAK);
            }
        }
        else
        {
            if ((isFirstRxByte == true) || (SERCOM1_I2C_LastByteAckStatusGet() == SERCOM_I2C_SLAVE_ACK_STATUS_RECEIVED_ACK))
            {
                SERCOM1_I2C_WriteByte(blProtocol.status);

                /* Clear all status bits except the busy bit */
                CLR_BIT(blProtocol.status, (BL_STATUS_BIT_ALL & ~(BL_STATUS_BIT_BUSY)));

                isFirstRxByte = false;

                SERCOM1_I2C_CommandSet(SERCOM_I2C_SLAVE_COMMAND_RECEIVE_ACK_NAK);
            }
            else
            {
                SERCOM1_I2C_CommandSet(SERCOM_I2C_SLAVE_COMMAND_WAIT_FOR_START);
            }
        }

    }
    else if (intFlags & SERCOM_I2C_SLAVE_INTFLAG_PREC)
    {
        SERCOM1_I2C_InterruptFlagsClear(SERCOM_I2C_SLAVE_INTFLAG_PREC);
    }
}

static void BL_FlashSM(void)
{
    switch(blProtocol.flashState)
    {
        case BL_FLASH_STATE_ERASE:
            // Lock region size is always bigger than the row size
            NVMCTRL_RegionUnlock(blProtocol.cmdProtocol.eraseCommand.memAddr);

            while(NVMCTRL_IsBusy() == true);

            /* Erase the Current row */
            NVMCTRL_RowErase(blProtocol.cmdProtocol.eraseCommand.memAddr);

            blProtocol.flashState = BL_FLASH_STATE_ERASE_BUSY_POLL;
            break;

        case BL_FLASH_STATE_WRITE:
            NVMCTRL_PageWrite((uint32_t*)&blProtocol.cmdProtocol.programCommand.data[blProtocol.nFlashBytesWritten], (blProtocol.cmdProtocol.programCommand.memAddr + blProtocol.nFlashBytesWritten));
            blProtocol.flashState = BL_FLASH_STATE_WRITE_BUSY_POLL;
            break;

        case BL_FLASH_STATE_VERIFY:
            if (BL_CRCGenerate() != blProtocol.cmdProtocol.verifyCommand.crc)
            {
                SET_BIT(blProtocol.status, BL_STATUS_BIT_CRC_ERROR);
            }
            CLR_BIT(blProtocol.status, BL_STATUS_BIT_BUSY);
            blProtocol.flashState = BL_FLASH_STATE_IDLE;
            break;

        case BL_FLASH_STATE_ERASE_BUSY_POLL:
            if(NVMCTRL_IsBusy() == false)
            {
                CLR_BIT(blProtocol.status, BL_STATUS_BIT_BUSY);
                blProtocol.flashState = BL_FLASH_STATE_IDLE;
            }
            break;

        case BL_FLASH_STATE_WRITE_BUSY_POLL:
            if(NVMCTRL_IsBusy() == false)
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
            while (!(SERCOM1_I2C_InterruptFlagsGet() & SERCOM_I2C_SLAVE_INTFLAG_PREC));
            NVIC_SystemReset();
            break;


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

void run_Application(void)
{
    uint32_t msp            = *(uint32_t *)(BL_APP_START_ADDRESS);
    uint32_t reset_vector   = *(uint32_t *)(BL_APP_START_ADDRESS + 4);

    if (msp == 0xffffffff)
    {
        return;
    }

    __set_MSP(msp);

    asm("bx %0"::"r" (reset_vector));
}

bool __WEAK bootloader_Trigger(void)
{
    /* Function can be overriden with custom implementation */
    return false;
}

void bootloader_Start(void)
{
    blProtocol.flashState = BL_FLASH_STATE_IDLE;

    while (1)
    {
        BL_I2C_EventsProcess();
        BL_FlashSM();
    }
}
