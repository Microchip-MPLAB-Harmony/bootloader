/*******************************************************************************
  Main Source File

  Company:
    Microchip Technology Inc.

  File Name:
    main.c

  Summary:
    This file contains the "main" function for a project.

  Description:
    This file contains the "main" function for a project.  The
    "main" function calls the "SYS_Initialize" function to initialize the appData.state
    machines of all modules in the system
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
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
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stddef.h>                     // Defines NULL
#include <stdbool.h>                    // Defines true
#include <stdlib.h>                     // Defines EXIT_FAILURE
#include <string.h>
#include "definitions.h"                // SYS function prototypes
#include "user.h"

#include APP_HEX_HEADER_FILE

/* Definitions */
#define APP_IMAGE_SIZE                              sizeof(image_pattern)
#define APP_IMAGE_END_ADDR                          (APP_IMAGE_START_ADDR + APP_IMAGE_SIZE)
#define APP_PROTOCOL_HEADER_MAX_SIZE                9
#define LED_ON()                                    LED_Clear()
#define LED_OFF()                                   LED_Set()
#define SWITCH_GET()                                SWITCH_Get()
#define SWITCH_PRESSED                              0

#define APP_BL_STATUS_BIT_BUSY                     	(0x01 << 0)
#define APP_BL_STATUS_BIT_INVALID_COMMAND          	(0x01 << 1)
#define APP_BL_STATUS_BIT_INVALID_MEM_ADDR         	(0x01 << 2)
#define APP_BL_STATUS_BIT_COMMAND_EXECUTION_ERROR  	(0x01 << 3)      //Valid only when APP_BL_STATUS_BIT_BUSY is 0
#define APP_BL_STATUS_BIT_CRC_ERROR                	(0x01 << 4)      
#define APP_BL_STATUS_BIT_ALL                      	(APP_BL_STATUS_BIT_BUSY | APP_BL_STATUS_BIT_INVALID_COMMAND | APP_BL_STATUS_BIT_INVALID_MEM_ADDR | \
                                                    APP_BL_STATUS_BIT_COMMAND_EXECUTION_ERROR | APP_BL_STATUS_BIT_CRC_ERROR)

typedef enum
{    
    APP_BL_COMMAND_UNLOCK = 0xA0,
	APP_BL_COMMAND_ERASE,
    APP_BL_COMMAND_PROGRAM,    
    APP_BL_COMMAND_VERIFY,
    APP_BL_COMMAND_RESET,    
    APP_BL_COMMAND_READ_STATUS,  
    APP_BL_COMMAND_MAX,
}APP_BL_COMMAND;

typedef enum
{
    APP_STATE_INIT,
    APP_STATE_WAIT_SW_PRESS,   
    APP_STATE_SEND_UNLOCK_COMMAND,
    APP_STATE_WAIT_UNLOCK_COMMAND_TRANSFER_COMPLETE,
    APP_STATE_SEND_ERASE_COMMAND,
    APP_STATE_WAIT_ERASE_COMMAND_TRANSFER_COMPLETE,
    APP_STATE_SEND_WRITE_COMMAND,
    APP_STATE_WAIT_WRITE_COMMAND_TRANSFER_COMPLETE,              
    APP_STATE_SEND_VERIFY_COMMAND,
    APP_STATE_WAIT_VERIFY_COMMAND_TRANSFER_COMPLETE,
    APP_STATE_SEND_RESET_COMMAND,
    APP_STATE_CHECK_STATUS,    
    APP_STATE_SUCCESSFUL,
    APP_STATE_ERROR,
    APP_STATE_IDLE,

} APP_STATES;

typedef enum
{
    APP_TRANSFER_STATUS_IN_PROGRESS,
    APP_TRANSFER_STATUS_SUCCESS,
    APP_TRANSFER_STATUS_ERROR,
    APP_TRANSFER_STATUS_IDLE,

} APP_TRANSFER_STATUS;

typedef struct
{
    APP_STATES                      state;
    APP_STATES                      nextState;
    volatile APP_TRANSFER_STATUS    trasnferStatus;    
    uint32_t                        appMemStartAddr;
    uint32_t                        nBytesWritten;
    uint32_t                        nBytesWrittenInErasedPage;
    uint8_t                         status;
    uint8_t                         wrBuffer[APP_PROGRAM_PAGE_SIZE + APP_PROTOCOL_HEADER_MAX_SIZE];    
    
} APP_DATA;

/* Global Data */
APP_DATA                            appData;

/* Call-backs */
void APP_I2CEventHandler(uintptr_t context )
{
    APP_TRANSFER_STATUS* trasnferStatus = (APP_TRANSFER_STATUS*)context;

    if(SERCOM5_I2C_ErrorGet() == SERCOM_I2C_ERROR_NONE)
    {
        if (trasnferStatus)
        {
            *trasnferStatus = APP_TRANSFER_STATUS_SUCCESS;
        }
    }
    else
    {
        if (trasnferStatus)
        {
            *trasnferStatus = APP_TRANSFER_STATUS_ERROR;
        }
    }
}

static void APP_Initialize(void)
{
    appData.appMemStartAddr = APP_IMAGE_START_ADDR;
    appData.nBytesWritten = 0;        
    appData.state = APP_STATE_INIT;
    LED_OFF();
}

static uint32_t APP_CRCGenerate(void)
{
    uint32_t crc  = 0;

    PAC_PeripheralProtectSetup (PAC_PERIPHERAL_DSU, PAC_PROTECTION_CLEAR);

    DSU_CRCCalculate (
		(uint32_t)&image_pattern[0], 
		APP_IMAGE_SIZE, 
		0xffffffff, 
		&crc
	);

    return crc;
}

static uint32_t APP_ImageDataWrite(uint32_t memAddr, uint32_t nBytes)
{
    uint32_t k; 
    uint32_t nTxBytes = 0;       
    uint32_t wrIndex = (memAddr - APP_IMAGE_START_ADDR);
    
    appData.wrBuffer[nTxBytes++] = APP_BL_COMMAND_PROGRAM;
    appData.wrBuffer[nTxBytes++] = (nBytes >> 24);
    appData.wrBuffer[nTxBytes++] = (nBytes >> 16);
    appData.wrBuffer[nTxBytes++] = (nBytes >> 8);
    appData.wrBuffer[nTxBytes++] = (nBytes);   
    appData.wrBuffer[nTxBytes++] = (memAddr >> 24);
    appData.wrBuffer[nTxBytes++] = (memAddr >> 16);
    appData.wrBuffer[nTxBytes++] = (memAddr >> 8);
    appData.wrBuffer[nTxBytes++] = (memAddr);
    

    for (k = 0; k < nBytes; k++, nTxBytes++)
    {
        appData.wrBuffer[nTxBytes] = image_pattern[wrIndex + k];
    }        

    return nTxBytes;
}

static uint32_t APP_UnlockCommandSend(uint32_t appStartAddr, uint32_t appSize)
{
    uint32_t nTxBytes = 0;
    
    appData.wrBuffer[nTxBytes++] = APP_BL_COMMAND_UNLOCK;  
    appData.wrBuffer[nTxBytes++] = (appStartAddr >> 24);
    appData.wrBuffer[nTxBytes++] = (appStartAddr >> 16);
    appData.wrBuffer[nTxBytes++] = (appStartAddr >> 8);
    appData.wrBuffer[nTxBytes++] = (appStartAddr);      
    appData.wrBuffer[nTxBytes++] = (appSize >> 24);
    appData.wrBuffer[nTxBytes++] = (appSize >> 16);
    appData.wrBuffer[nTxBytes++] = (appSize >> 8);
    appData.wrBuffer[nTxBytes++] = (appSize);
    
    return nTxBytes;
}

static uint32_t APP_VerifyCommandSend(uint32_t crc)
{
    uint32_t nTxBytes = 0;
    
    appData.wrBuffer[nTxBytes++] = APP_BL_COMMAND_VERIFY;  
    appData.wrBuffer[nTxBytes++] = (crc >> 24);
    appData.wrBuffer[nTxBytes++] = (crc >> 16);
    appData.wrBuffer[nTxBytes++] = (crc >> 8);
    appData.wrBuffer[nTxBytes++] = (crc);      
    
    return nTxBytes;
}

static uint32_t APP_EraseCommandSend(uint32_t memAddr)
{
    uint32_t nTxBytes = 0;
    
    appData.wrBuffer[nTxBytes++] = APP_BL_COMMAND_ERASE;  
    appData.wrBuffer[nTxBytes++] = (memAddr >> 24);
    appData.wrBuffer[nTxBytes++] = (memAddr >> 16);
    appData.wrBuffer[nTxBytes++] = (memAddr >> 8);
    appData.wrBuffer[nTxBytes++] = (memAddr);      
    
    return nTxBytes;
}

// *****************************************************************************
// *****************************************************************************
// Section: Main Entry Point
// *****************************************************************************
// *****************************************************************************
int main ( void )
{    
    uint32_t nTxBytes;
    uint32_t crc;
    
    APP_Initialize();
    
    /* Initialize all modules */
    SYS_Initialize ( NULL );    

    while(1)
    {
        switch (appData.state)
        {
            case APP_STATE_INIT:
                SERCOM5_I2C_CallbackRegister( APP_I2CEventHandler, (uintptr_t)&appData.trasnferStatus );
                appData.state = APP_STATE_WAIT_SW_PRESS;
                break;                            
                
            case APP_STATE_WAIT_SW_PRESS:
                if (SWITCH_GET() == SWITCH_PRESSED)
                {                    
                    appData.state = APP_STATE_SEND_UNLOCK_COMMAND;
                }
                break;            

            case APP_STATE_SEND_UNLOCK_COMMAND:
                
                nTxBytes = APP_UnlockCommandSend(APP_IMAGE_START_ADDR, APP_IMAGE_SIZE);
                appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                SERCOM5_I2C_Write(APP_I2C_SLAVE_ADDR, &appData.wrBuffer[0], nTxBytes);
                appData.state = APP_STATE_WAIT_UNLOCK_COMMAND_TRANSFER_COMPLETE;               
                break;
                
            case APP_STATE_WAIT_UNLOCK_COMMAND_TRANSFER_COMPLETE:
                if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
                {
                    appData.state = APP_STATE_SEND_ERASE_COMMAND;
                }
                else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
                {
                    appData.state = APP_STATE_ERROR;
                }
                break;
                
            case APP_STATE_SEND_ERASE_COMMAND:
                if ((appData.appMemStartAddr + appData.nBytesWritten) < APP_IMAGE_END_ADDR)
                {
                    nTxBytes = APP_EraseCommandSend((appData.appMemStartAddr + appData.nBytesWritten));
                    if (nTxBytes > 0)
                    {
                        appData.nBytesWrittenInErasedPage = 0;
                        appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                        SERCOM5_I2C_Write(APP_I2C_SLAVE_ADDR, &appData.wrBuffer[0], nTxBytes);
                        appData.state = APP_STATE_WAIT_ERASE_COMMAND_TRANSFER_COMPLETE;                        
                    }
                }
                else
                {
                    /* Firmware programming complete. Now verify CRC by sending verify command */                                
                    appData.state = APP_STATE_SEND_VERIFY_COMMAND;
                }
                break;
                
            case APP_STATE_WAIT_ERASE_COMMAND_TRANSFER_COMPLETE:
                if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
                {
                    /* Read the status of the erase command */
                    appData.wrBuffer[0] = APP_BL_COMMAND_READ_STATUS;
                    appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                    SERCOM5_I2C_WriteRead(APP_I2C_SLAVE_ADDR, &appData.wrBuffer[0], 1,  &appData.status, 1);                    
                    appData.state = APP_STATE_CHECK_STATUS;
                    appData.nextState = APP_STATE_SEND_WRITE_COMMAND;
                }
                else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
                {
                    appData.state = APP_STATE_ERROR;
                }
                
                break;
                
            case APP_STATE_SEND_WRITE_COMMAND:  
                if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
                {
                    nTxBytes = APP_ImageDataWrite((appData.appMemStartAddr + appData.nBytesWritten), APP_PROGRAM_PAGE_SIZE);                                      
                    appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                    SERCOM5_I2C_Write(APP_I2C_SLAVE_ADDR, &appData.wrBuffer[0], nTxBytes);
                    appData.state = APP_STATE_WAIT_WRITE_COMMAND_TRANSFER_COMPLETE;
                }                
                else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
                {
                    appData.state = APP_STATE_ERROR;
                }                                                               
                break;

            case APP_STATE_WAIT_WRITE_COMMAND_TRANSFER_COMPLETE:
                if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
                {
                    appData.nBytesWritten += APP_PROGRAM_PAGE_SIZE;  
                    appData.nBytesWrittenInErasedPage += APP_PROGRAM_PAGE_SIZE;
                    
                    /* Read the status of the write command */
                    appData.wrBuffer[0] = APP_BL_COMMAND_READ_STATUS;
                    appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                    SERCOM5_I2C_WriteRead(APP_I2C_SLAVE_ADDR, &appData.wrBuffer[0], 1,  &appData.status, 1);                    
                    appData.state = APP_STATE_CHECK_STATUS;
                    if (appData.nBytesWrittenInErasedPage == APP_ERASE_PAGE_SIZE)
                    {
                        /* All the pages of the Erased Row are written. Erase next row. */
                        appData.nextState = APP_STATE_SEND_ERASE_COMMAND;
                    }
                    else
                    {
                        /* Continue to write to the Erased Page */
                        appData.nextState = APP_STATE_SEND_WRITE_COMMAND;
                    }
                }
                else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
                {
                    appData.state = APP_STATE_ERROR;
                }
                break;                            
                                     
            case APP_STATE_SEND_VERIFY_COMMAND: 
                crc = APP_CRCGenerate();
                nTxBytes = APP_VerifyCommandSend(crc);                 
                appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                SERCOM5_I2C_Write(APP_I2C_SLAVE_ADDR, &appData.wrBuffer[0], nTxBytes);                    
                appData.state = APP_STATE_WAIT_VERIFY_COMMAND_TRANSFER_COMPLETE;
                break;
                
            case APP_STATE_WAIT_VERIFY_COMMAND_TRANSFER_COMPLETE:
                if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
                {
                    /* Read the status of the verify command */
                    appData.wrBuffer[0] = APP_BL_COMMAND_READ_STATUS;
                    appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                    SERCOM5_I2C_WriteRead(APP_I2C_SLAVE_ADDR, &appData.wrBuffer[0], 1,  &appData.status, 1);        
                    appData.state = APP_STATE_CHECK_STATUS;
                    appData.nextState = APP_STATE_SEND_RESET_COMMAND;
                }
                else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
                {
                    appData.state = APP_STATE_ERROR;
                }
                break;
                
            case APP_STATE_CHECK_STATUS:
                if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
                {
                    if (appData.status != 0)
                    {
                        appData.state = APP_STATE_ERROR;
                    }
                    else
                    {
                        appData.state = appData.nextState;
                    }                    
                }
                else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
                {                     
                    /* Slave is busy. Keep checking the status */
                    appData.wrBuffer[0] = APP_BL_COMMAND_READ_STATUS;
                    appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                    SERCOM5_I2C_WriteRead(APP_I2C_SLAVE_ADDR, &appData.wrBuffer[0], 1,  &appData.status, 1);  
                }
                break;

            case APP_STATE_SEND_RESET_COMMAND:
                
                appData.wrBuffer[0] = APP_BL_COMMAND_RESET;
                appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                SERCOM5_I2C_Write(APP_I2C_SLAVE_ADDR, &appData.wrBuffer[0], 1);                    
                appData.state = APP_STATE_SUCCESSFUL;                        
                break;
                
            case APP_STATE_SUCCESSFUL:
            
                LED_ON();       
                appData.state = APP_STATE_IDLE;
                break;
            
            case APP_STATE_ERROR:
            
                LED_OFF();
                appData.state = APP_STATE_IDLE;
                break;
                
            case APP_STATE_IDLE:
                break;
            
            default:
                break;
        }
    }
}

