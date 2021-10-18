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

#define SET_BIT(reg, bits)                      (reg |= (bits))
#define CLR_BIT(reg, bits)                      (reg &= ~(bits))
#define IS_BIT_SET(reg, bit)                    ((reg & bit)? true:false)

#define FLASH_START             				(${.vars["${MEM_USED?lower_case}"].FLASH_START_ADDRESS}UL)
#define FLASH_LENGTH            				(${.vars["${MEM_USED?lower_case}"].FLASH_SIZE}UL)
#define PAGE_SIZE               				(${.vars["${MEM_USED?lower_case}"].FLASH_PROGRAM_SIZE}UL)
#define ERASE_BLOCK_SIZE        				(${.vars["${MEM_USED?lower_case}"].FLASH_ERASE_SIZE}UL)
#define PAGES_IN_ERASE_BLOCK    				(ERASE_BLOCK_SIZE / PAGE_SIZE)
#define BOOTLOADER_SIZE         				${BTL_SIZE}
#define APP_START_ADDRESS       				(PA_TO_KVA0(0x${core.APP_START_ADDRESS}UL))
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
    BL_COMMAND_ERASE = 0xA1,
    BL_COMMAND_PROGRAM = 0xA2,
    BL_COMMAND_VERIFY = 0xA3,
    BL_COMMAND_RESET = 0xA4,
    BL_COMMAND_READ_STATUS = 0xA5,
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

static volatile BL_PROTOCOL                 i2cBLData;

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Local Functions
// *****************************************************************************
// *****************************************************************************
/* Trigger a reset */
static void BL_TriggerReset(void)
{    
    /* Perform system unlock sequence */ 
    SYSKEY = 0x00000000;
    SYSKEY = 0xAA996655;
    SYSKEY = 0x556699AA;

    RSWRSTSET = _RSWRST_SWRST_MASK;
    (void)RSWRST;
}

/* Function to Generate CRC by reading the firmware programmed into internal flash */
static uint32_t BL_CRCGenerate(uint32_t start_addr, uint32_t size)
{
    uint32_t   i, j, value;
    uint32_t   crc_tab[256];
    uint32_t   crc     = 0xffffffff;
    uint8_t    data;

    for (i = 0; i < 256; i++)
    {
        value = i;

        for (j = 0; j < 8; j++)
        {
            if (value & 1)
            {
                value = (value >> 1) ^ 0xEDB88320;
            }
            else
            {
                value >>= 1;
            }
        }
        crc_tab[i] = value;
    }

    for (i = 0; i < size; i++)
    {
        data = *(uint8_t *)KVA0_TO_KVA1((start_addr + i));

        crc = crc_tab[(crc ^ data) & 0xff] ^ (crc >> 8);
    }
    return crc;
}

static bool I2C_BL_CommandParser(uint8_t rdByte)
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
            else if (i2cBLData.command == BL_COMMAND_READ_STATUS)
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

                if ((i2cBLData.command == BL_COMMAND_UNLOCK) || (i2cBLData.command == BL_COMMAND_PROGRAM))
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
                    if ((i2cBLData.cmdProtocol.eraseCommand.memAddr < i2cBLData.appImageStartAddr) ||
                    ((i2cBLData.cmdProtocol.eraseCommand.memAddr + ERASE_BLOCK_SIZE) > i2cBLData.appImageEndAddr))
                    {
                        SET_BIT(i2cBLData.status, BL_STATUS_BIT_INVALID_MEM_ADDR);
                        return false;
                    }
                    else
                    {
                        SET_BIT(i2cBLData.status, BL_STATUS_BIT_BUSY);
                        i2cBLData.flashState = BL_FLASH_STATE_ERASE;
                    }
                }
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

static bool I2CEventHandler( I2C_SLAVE_TRANSFER_EVENT event, uintptr_t contextHandle )
{
	bool isSendACK = true;
	
	switch(event)
    {
        case I2C_SLAVE_TRANSFER_EVENT_ADDR_MATCH:

			/* Reset the I2C read state machine */
			i2cBLData.rdState = BL_I2C_READ_COMMAND;

			if (IS_BIT_SET(i2cBLData.status, BL_STATUS_BIT_BUSY))
			{
				isSendACK = false;
			}			
            break;

        case I2C_SLAVE_TRANSFER_EVENT_RX_READY:
		
			if (I2C_BL_CommandParser(${PERIPH_USED}_ReadByte()) == false)
            {
                isSendACK = false;
			}	
		            
            break;

        case I2C_SLAVE_TRANSFER_EVENT_TX_READY:
			${PERIPH_USED}_WriteByte(i2cBLData.status);

			/* Clear all status bits except the busy bit */
			CLR_BIT(i2cBLData.status, (BL_STATUS_BIT_ALL & ~(BL_STATUS_BIT_BUSY)));
            			
            break;
        
        default:
            break;
    }      
	
	return isSendACK;
}

static void I2C_BL_FlashSM(void)
{
    switch(i2cBLData.flashState)
    {
        case BL_FLASH_STATE_ERASE:            
            NVM_PageErase(i2cBLData.cmdProtocol.eraseCommand.memAddr);
            i2cBLData.flashState = BL_FLASH_STATE_ERASE_BUSY_POLL;
			
            break;

        case BL_FLASH_STATE_WRITE:
			NVM_RowWrite((uint32_t*)&i2cBLData.cmdProtocol.programCommand.data[i2cBLData.nFlashBytesWritten], (i2cBLData.cmdProtocol.programCommand.memAddr + i2cBLData.nFlashBytesWritten));
            i2cBLData.flashState = BL_FLASH_STATE_WRITE_BUSY_POLL;
            break;

        case BL_FLASH_STATE_VERIFY:			
			if (BL_CRCGenerate(i2cBLData.appImageStartAddr, (i2cBLData.appImageEndAddr - i2cBLData.appImageStartAddr)) != i2cBLData.cmdProtocol.verifyCommand.crc)
            {
                SET_BIT(i2cBLData.status, BL_STATUS_BIT_CRC_ERROR);
            }
            CLR_BIT(i2cBLData.status, BL_STATUS_BIT_BUSY);
            i2cBLData.flashState = BL_FLASH_STATE_IDLE;
            break;

        case BL_FLASH_STATE_ERASE_BUSY_POLL:
			if(NVM_IsBusy() == false)
            {
                CLR_BIT(i2cBLData.status, BL_STATUS_BIT_BUSY);
                i2cBLData.flashState = BL_FLASH_STATE_IDLE;
            }
            break;

        case BL_FLASH_STATE_WRITE_BUSY_POLL:
			if(NVM_IsBusy() == false)
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
            BL_TriggerReset();
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
    uint32_t msp            = *(uint32_t *)(APP_START_ADDRESS);

    void (*fptr)(void);

    /* Set default to APP_RESET_ADDRESS */
    fptr = (void (*)(void))APP_START_ADDRESS;

    if (msp == 0xffffffff)
    {
        return;
    }

    fptr();
}

bool __WEAK bootloader_Trigger(void)
{
    /* Function can be overriden with custom implementation */
    return false;
}

void bootloader_Tasks(void)
{
    i2cBLData.flashState = BL_FLASH_STATE_IDLE;
	
	${PERIPH_USED}_CallbackRegister(I2CEventHandler, (uintptr_t)0);

    while (1)
    {        
        I2C_BL_FlashSM();
    }
}
