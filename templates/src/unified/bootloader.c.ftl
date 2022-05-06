/*******************************************************************************
  Company:
    Microchip Technology Inc.

  File Name:
    bootloader.c

  Summary:
    Interface for the Bootloader library.

  Description:
    This file contains the interface definition for the Bootloader library.
*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
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

#include <string.h>
#include "device.h"
#include "bootloader/bootloader_${BTL_TYPE?lower_case}.h"
#include "bootloader/datastream/datastream.h"
#include "bootloader/bootloader_nvm_interface.h"

#define BOOTLOADER_BUFFER_SIZE  512

#define SOH                     01 // Start Of Header
#define EOT                     04 // End Of transmission
#define DLE                     16 // Data Escape Sequence

typedef enum
{
    READ_BOOT_INFO = 1,
    ERASE_FLASH,
    PROGRAM_FLASH,
    READ_CRC,
    JMP_TO_APP
} BOOTLOADER_COMMANDS;

typedef enum
{
    /* If we need to program, then open the datastream. */
    BOOTLOADER_OPEN_DATASTREAM = 0,

    /* The Bootloader gets a command from the host application. */
    BOOTLOADER_GET_COMMAND,

    /* The Bootloader processes the command from the host application. */
    BOOTLOADER_PROCESS_COMMAND,

    /* The Bootloader sends data back to the host application. */
    BOOTLOADER_SEND_RESPONSE,

    /* The Bootloader waits in this state for the driver to finish
       sending/receiving the message. */
    BOOTLOADER_WAIT_FOR_DONE,

    /* Close the datastream */
    BOOTLOADER_CLOSE_DATASTREAM,

    /* The Bootloader enters the user application. */
    BOOTLOADER_ENTER_APPLICATION,

    /* This state indicates an error has occurred. */
    BOOTLOADER_ERROR,

} BOOTLOADER_STATES;

typedef union
{
    uint8_t buffer[BOOTLOADER_BUFFER_SIZE + BOOTLOADER_BUFFER_SIZE];

    struct
    {
        /* Buffer to hold the data received */
        uint8_t inputBuff[BOOTLOADER_BUFFER_SIZE];
        /* Buffer to hold the data to be processed */
        uint8_t procBuff[BOOTLOADER_BUFFER_SIZE];
    } buffers;
} BOOTLOADER_BUFFER;

typedef struct
{
    /* Bootloader current state */
    BOOTLOADER_STATES currentState;

    /* Bootloader previous state */
    BOOTLOADER_STATES prevState;

    /* Datastream buffer size */
    uint32_t buffSize;

    /* Command buffer length */
    uint32_t cmdBuffLen;

    /* Stream handle */
    DATASTREAM_HANDLE streamHandle;

    /* Datastream status */
    DRV_CLIENT_STATUS datastreamStatus;

    /* Flag to indicate the host message is been processed */
    bool usrBufferEventComplete;

} BOOTLOADER_DATA;

BOOTLOADER_BUFFER CACHE_ALIGN dataBuff;

BOOTLOADER_DATA btlData =
{
    .currentState = BOOTLOADER_OPEN_DATASTREAM,
    .usrBufferEventComplete = false
};

static const uint16_t crc_table[16] =
{
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
    0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef
};

static uint32_t bootloader_CalculateCrc(uint8_t *data, uint32_t len)
{
    uint32_t i;
    uint16_t crc = 0;

    while(len--)
    {
        i = (crc >> 12) ^ (*data >> 4);
        crc = crc_table[i & 0x0F] ^ (crc << 4);
        i = (crc >> 12) ^ (*data >> 0);
        crc = crc_table[i & 0x0F] ^ (crc << 4);
        data++;
    }

    return (crc & 0xFFFF);
}

static void bootloader_BufferEventHandler
(
    DATASTREAM_BUFFER_EVENT buffEvent,
    DATASTREAM_HANDLE handle,
    uintptr_t context
)
{
    uint16_t crc;
    uint32_t i = 0;

    while (i < context)
    {
        if (buffEvent != DATASTREAM_BUFFER_EVENT_COMPLETE)
        {
             break;
        }

        if (btlData.prevState != BOOTLOADER_GET_COMMAND)
        {
            /* SEND RESPONSE */
            btlData.usrBufferEventComplete = true;
            return;
        }

        /* Process the received packet */
        switch (dataBuff.buffers.inputBuff[i])
        {
            case SOH:   // Start of header
            {
                btlData.cmdBuffLen = 0;
                break;
            }

            case EOT:   // End of transmission
            {
                // Calculate CRC and see if this is valid
                if (btlData.cmdBuffLen > 2)
                {
                    crc = dataBuff.buffers.procBuff[btlData.cmdBuffLen-2];
                    crc += ((dataBuff.buffers.procBuff[btlData.cmdBuffLen-1])<<8);

                    if (bootloader_CalculateCrc(dataBuff.buffers.procBuff, btlData.cmdBuffLen-2) == crc)
                    {
                        // CRC matches so frame is valid.
                        btlData.usrBufferEventComplete = true;
                        return;
                    }
                }
                break;
            }

            case DLE:   // Escape sequence
            {
                // Increment index for actual data and fall through to default case.
                i++;
            }

            default:
            {
                dataBuff.buffers.procBuff[btlData.cmdBuffLen++] = dataBuff.buffers.inputBuff[i];
                break;
            }
        }
        i++;
    }

    /* We don't have a complete command yet. Continue reading. */
    DATASTREAM_Data_Read(btlData.streamHandle, dataBuff.buffers.inputBuff, btlData.buffSize);
}

static void bootloader_ProcessBuffer( BOOTLOADER_DATA *handle )
{
    uint8_t Cmd;
    uint32_t Address;
    uint32_t Length;
    uint16_t crc;
    uint16_t btlVersion;

    /* First, check that we have a valid command. */
    Cmd = dataBuff.buffers.procBuff[0];

    /* Build the response frame from the command. */
    dataBuff.buffers.inputBuff[0] = dataBuff.buffers.procBuff[0];
    handle->buffSize = 0;

    switch (Cmd)
    {
        case READ_BOOT_INFO:
        {
            btlVersion = bootloader_GetVersion();

            /* Major Number */
            dataBuff.buffers.inputBuff[1] = (uint8_t)(btlVersion >> 8);

            /* Minor Number */
            dataBuff.buffers.inputBuff[2] = (uint8_t)(btlVersion & 0xFF);

            handle->buffSize = 2 + 1;
            handle->currentState = BOOTLOADER_SEND_RESPONSE;
            break;
        }

        case ERASE_FLASH:
        {
            bootloader_NvmAppErase();
            handle->currentState = BOOTLOADER_SEND_RESPONSE;
            handle->buffSize = 1;
            break;
        }

        case PROGRAM_FLASH:
        {
            if(bootloader_NvmProgramHexRecord(&dataBuff.buffers.procBuff[1], handle->cmdBuffLen-3) != HEX_REC_NORMAL)
            {
                break;
            }
            handle->buffSize = 1;
            handle->currentState = BOOTLOADER_SEND_RESPONSE;
            break;
        }

        case READ_CRC:
        {
            memcpy(&Address, &dataBuff.buffers.procBuff[1], sizeof(Address));
            memcpy(&Length, &dataBuff.buffers.procBuff[5], sizeof(Length));
            crc = bootloader_CalculateCrc((uint8_t *)(Address), Length);
            memcpy(&dataBuff.buffers.inputBuff[1], &crc, 2);

            handle->buffSize = 1 + 2;
            handle->currentState = BOOTLOADER_SEND_RESPONSE;
            break;
        }

        case JMP_TO_APP:
        {
            handle->buffSize = 1;
            handle->prevState = BOOTLOADER_ENTER_APPLICATION;
            handle->currentState = BOOTLOADER_SEND_RESPONSE;

            break;
        }

        default:
            break;
    }
}

void bootloader_${BTL_TYPE}_Tasks( void )
{
    uint32_t BuffLen=0;
    uint32_t i;
    uint16_t crc;

    switch ( btlData.currentState )
    {
        case BOOTLOADER_OPEN_DATASTREAM:
        {
            btlData.streamHandle = DATASTREAM_HANDLE_INVALID;

            btlData.streamHandle = DATASTREAM_Open(
                    DRV_IO_INTENT_READWRITE | DRV_IO_INTENT_NONBLOCKING);

            if (btlData.streamHandle != DRV_HANDLE_INVALID )
            {
                DATASTREAM_BufferEventHandlerSet(btlData.streamHandle,
                        bootloader_BufferEventHandler, APP_USR_CONTEXT);

                btlData.currentState = BOOTLOADER_GET_COMMAND;
            }
            break;
        }

        case BOOTLOADER_GET_COMMAND:
        {
            btlData.datastreamStatus = DRV_CLIENT_STATUS_ERROR;

            /* Get the datastream driver status */
            btlData.datastreamStatus = DATASTREAM_ClientStatus( btlData.streamHandle );

            /* Check if client is ready or not */
            if ( btlData.datastreamStatus == DRV_CLIENT_STATUS_READY )
            {
                btlData.buffSize = BOOTLOADER_BUFFER_SIZE;

                 DATASTREAM_Data_Read( btlData.streamHandle, dataBuff.buffers.inputBuff, btlData.buffSize);

                /* Set the App. state to wait for done */
                btlData.prevState    = BOOTLOADER_GET_COMMAND;
                btlData.currentState = BOOTLOADER_WAIT_FOR_DONE;
            }
            break;
        }

        case BOOTLOADER_WAIT_FOR_DONE:
        {
            /* check if the datastream buffer event is complete or not */
            if (btlData.usrBufferEventComplete == true)
            {
                btlData.usrBufferEventComplete = false;

                /* Get the next App. State */
                if (btlData.prevState == BOOTLOADER_GET_COMMAND)
                {
                    btlData.currentState = BOOTLOADER_PROCESS_COMMAND;
                }
                else if (btlData.prevState == BOOTLOADER_ENTER_APPLICATION)
                {
                    btlData.currentState = BOOTLOADER_ENTER_APPLICATION;
                }
                else
                {
                    btlData.currentState = BOOTLOADER_GET_COMMAND;
                }
            }
            break;
        }

        case BOOTLOADER_PROCESS_COMMAND:
        {
            bootloader_ProcessBuffer(&btlData);
            break;
        }

        case BOOTLOADER_SEND_RESPONSE:
        {
            if(btlData.buffSize)
            {
                /* Calculate the CRC of the response*/
                crc = bootloader_CalculateCrc(dataBuff.buffers.inputBuff, btlData.buffSize);

                dataBuff.buffers.inputBuff[btlData.buffSize++] = (uint8_t)crc;

                dataBuff.buffers.inputBuff[btlData.buffSize++] = (crc>>8);

                dataBuff.buffers.procBuff[BuffLen++] = SOH;

                for (i = 0; i < btlData.buffSize; i++)
                {
                    if ((dataBuff.buffers.inputBuff[i] == EOT) || (dataBuff.buffers.inputBuff[i] == SOH)
                        || (dataBuff.buffers.inputBuff[i] == DLE))
                    {
                        dataBuff.buffers.procBuff[BuffLen++] = DLE;
                    }

                    dataBuff.buffers.procBuff[BuffLen++] = dataBuff.buffers.inputBuff[i];
                }

                dataBuff.buffers.procBuff[BuffLen++] = EOT;
                btlData.buffSize = 0;

                DATASTREAM_Data_Write( btlData.streamHandle, dataBuff.buffers.procBuff, BuffLen);

                if (btlData.prevState != BOOTLOADER_ENTER_APPLICATION)
                {
                    btlData.prevState = BOOTLOADER_SEND_RESPONSE;
                }

                btlData.currentState = BOOTLOADER_WAIT_FOR_DONE;
            }
            break;
        }

        case BOOTLOADER_ENTER_APPLICATION:
        {
<#if BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true >
    <#if BTL_LIVE_UPDATE_RESET?? && BTL_LIVE_UPDATE_RESET == true >
            bootloader_SwapAndReset();
    <#else>
            /* Waiting for New Update */
            btlData.currentState = BOOTLOADER_GET_COMMAND;
    </#if>
<#else>
            bootloader_TriggerReset();
</#if>
            break;
        }

        case BOOTLOADER_ERROR:
        default:
            btlData.currentState = BOOTLOADER_ERROR;
            break;
    }

    /* Maintain Device Drivers */
    DATASTREAM_Tasks();
}