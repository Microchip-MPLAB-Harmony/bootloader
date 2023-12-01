/*******************************************************************************
  ${BTL_TYPE} Bootloader Source File

  File Name:
    bootloader_${BTL_TYPE?lower_case}.c

  Summary:
    This file contains source code necessary to execute ${BTL_TYPE} bootloader.

  Description:
    This file contains source code necessary to execute UART bootloader.
    It implements bootloader protocol which uses UART peripheral to download
    application firmware into external media from HOST-PC.
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2023 Microchip Technology Inc. and its subsidiaries.
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
#include "bootloader_storage.h"

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

#define GUARD_OFFSET            0U
#define CMD_OFFSET              2U
#define ADDR_OFFSET             0U
#define SIZE_OFFSET             1U
#define DATA_OFFSET             1U
#define CRC_OFFSET              0U

#define CMD_SIZE                1U
#define GUARD_SIZE              4U
#define SIZE_SIZE               4U
#define OFFSET_SIZE             4U
#define CRC_SIZE                4U
#define HEADER_SIZE             (GUARD_SIZE + SIZE_SIZE + CMD_SIZE)

#define DATA_SIZE               PAGE_SIZE

#define WORDS(x)                ((uint32_t)((x) / sizeof(uint32_t)))

#define BTL_GUARD               (0x5048434DUL)


#define    BL_CMD_UNLOCK       0xa0U
#define    BL_CMD_DATA         0xa1U
#define    BL_CMD_VERIFY       0xa2U
#define    BL_CMD_RESET        0xa3U
#define    BL_CMD_READ_VERSION 0xa6U


enum
{
    BL_RESP_OK          = 0x50,
    BL_RESP_ERROR       = 0x51,
    BL_RESP_INVALID     = 0x52,
    BL_RESP_CRC_OK      = 0x53,
    BL_RESP_CRC_FAIL    = 0x54
};

typedef enum
{
<#if DRIVER_USED != "">
    BOOTLOADER_STATE_INIT = 0U,

    BOOTLOADER_CHECK_IMAGE,
<#else>
    BOOTLOADER_REGISTER_EVENT_HANDLER = 0U,

    BOOTLOADER_WAIT_FOR_DEVICE_ATTACH,
</#if>

    BOOTLOADER_READY_NEW_IMAGE

} BOOTLOADER_STATES;

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

static uint8_t btl_guard[4] = {0x4D, 0x43, 0x48, 0x50};

static uint32_t input_buffer[WORDS(OFFSET_SIZE + DATA_SIZE)];

static uint32_t media_write_data[WORDS(DATA_SIZE)];
static uint32_t image_addr          = 0;

static uint32_t unlock_begin        = 0;
static uint32_t unlock_end          = 0;
static uint32_t data_size           = 0;

static uint8_t  input_command       = 0;

static bool     packet_received     = false;
static bool     media_write_data_ready = false;

static bool     uartBLActive        = false;

static bool     imageStartFlag      = false;

<#if DRIVER_USED != "">
static BOOTLOADER_STATES btl_state = BOOTLOADER_STATE_INIT;
<#else>
static BOOTLOADER_STATES btl_state = BOOTLOADER_REGISTER_EVENT_HANDLER;
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Local Functions
// *****************************************************************************
// *****************************************************************************

/* Function to receive application firmware via UART/USART */
static void input_task(void)
{
    static uint32_t ptr             = 0;
    static uint32_t size            = 0;
    static bool     header_received = false;
    uint8_t         *byte_buf       = (uint8_t *)&input_buffer[0];
    uint8_t         input_data      = 0;

    if (packet_received == true)
    {
        return;
    }

    if (${PERIPH_USED}_ReceiverIsReady() == false)
    {
        return;
    }

    input_data = (uint8_t)${PERIPH_USED}_ReadByte();

    if (header_received == false)
    {
        byte_buf[ptr] = input_data;
        ptr++;

        // Check for each guard byte and discard if mismatch
        if (ptr <= GUARD_SIZE)
        {
            if (input_data != btl_guard[ptr-1U])
            {
                ptr = 0U;
            }
        }
        else if (ptr == HEADER_SIZE)
        {
            if (input_buffer[GUARD_OFFSET] != BTL_GUARD)
            {
                ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
            }
            else
            {
                size            = input_buffer[SIZE_OFFSET];
                input_command   = (uint8_t)input_buffer[CMD_OFFSET];
                header_received = true;
                uartBLActive    = true;
            }

            ptr = 0;
        }
        else
        {
            /* Nothing to do */
        }

    }
    else if (header_received == true)
    {
        if (ptr < size)
        {
            byte_buf[ptr++] = input_data;
        }

        if (ptr == size)
        {
            data_size = size;
            ptr = 0;
            size = 0;
            packet_received = true;
            header_received = false;
        }
    }
    else
    {
        /* Nothing to do */
    }
}

/* Function to process the received command */
static void command_task(void)
{
    uint32_t i;
    uint8_t  *byte_buf_src = (uint8_t *)&input_buffer[0];
    uint8_t  *byte_buf_dst = (uint8_t *)&media_write_data[0];
    uint8_t   remaining_byte = 0U;

    if (BL_CMD_UNLOCK == input_command)
    {
        uint32_t begin  = input_buffer[ADDR_OFFSET];

        uint32_t end    = begin + input_buffer[SIZE_OFFSET];

        imageStartFlag = true;

        if (end > begin)
        {
            unlock_begin = begin;
            unlock_end = end;
            <#if DRIVER_USED != "">
            bootloader_ImageSizeSet(input_buffer[SIZE_OFFSET]);
            </#if>
            ${PERIPH_USED}_WriteByte(BL_RESP_OK);
        }
        else
        {
            unlock_begin = 0;
            unlock_end = 0;
            ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
        }
    }
    else if (BL_CMD_DATA == input_command)
    {
        image_addr = input_buffer[ADDR_OFFSET];
        data_size = data_size - OFFSET_SIZE;

        if (unlock_begin <= image_addr && image_addr < unlock_end)
        {
            for (i = 0; i < WORDS(data_size); i++)
            {
                media_write_data[i] = input_buffer[i + DATA_OFFSET];
            }

            remaining_byte = (uint8_t)(data_size % sizeof(uint32_t));

            if (remaining_byte != 0U)
            {
                for (i = (data_size - remaining_byte); i < data_size; i++)
                {
                    byte_buf_dst[i] = byte_buf_src[i + (DATA_OFFSET * sizeof(uint32_t))];
                }
            }

            media_write_data_ready = true;
        }
        else
        {
            ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
        }
    }
    else if (BL_CMD_READ_VERSION == input_command)
    {
        ${PERIPH_USED}_WriteByte(BL_RESP_OK);

        uint16_t btlVersion = bootloader_GetVersion();
        uint16_t btlVer = ((btlVersion >> 8U) & 0xFFU);

        <#if PERIPH_USED?contains("FLEXCOM") || PERIPH_USED?contains("DBGU")>
        ${PERIPH_USED}_WriteByte((uint8_t)btlVer);
        <#else>
        ${PERIPH_USED}_WriteByte((int)btlVer);
        </#if>
        btlVer = (btlVersion & 0xFFU);
        <#if PERIPH_USED?contains("FLEXCOM") || PERIPH_USED?contains("DBGU")>
        ${PERIPH_USED}_WriteByte((uint8_t)btlVer);
        <#else>
        ${PERIPH_USED}_WriteByte((int)btlVer);
        </#if>
    }
    else if (BL_CMD_VERIFY == input_command)
    {
        if (bootloader_Storage_CRC_Verify(input_buffer[CRC_OFFSET]) == true)
        {
            ${PERIPH_USED}_WriteByte(BL_RESP_CRC_OK);
        }
        else
        {
            ${PERIPH_USED}_WriteByte(BL_RESP_CRC_FAIL);
        }
    }
    else if (BL_CMD_RESET == input_command)
    {
        ${PERIPH_USED}_WriteByte(BL_RESP_OK);

        while(${PERIPH_USED}_TransmitComplete() == false)
		{
            // Wait for transmission complete
		}

        bootloader_TriggerReset();
    }
    else
    {
        ${PERIPH_USED}_WriteByte(BL_RESP_INVALID);
    }

    packet_received = false;
}

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Global Functions
// *****************************************************************************
// *****************************************************************************

void bootloader_${BTL_TYPE}_Tasks(void)
{
    switch (btl_state)
    {
<#if DRIVER_USED != "">
        case BOOTLOADER_STATE_INIT:
        {
            if (bootloader_IsDeviceReady() == true)
            {
                btl_state = BOOTLOADER_CHECK_IMAGE;
            }
            break;
        }
        case BOOTLOADER_CHECK_IMAGE:
        {
            if (bootloader_Trigger() == false)
            {
                bootloader_Storage_Read();
            }
            btl_state = BOOTLOADER_READY_NEW_IMAGE;
            break;
        }
<#else>
        case BOOTLOADER_REGISTER_EVENT_HANDLER:
        {
            SYS_FS_EventHandlerSet(bootloader_SysFsEventHandler, 0);
            btl_state = BOOTLOADER_WAIT_FOR_DEVICE_ATTACH;
            break;
        }
        case BOOTLOADER_WAIT_FOR_DEVICE_ATTACH:
        {
            if (bootloader_IsDeviceAttached() == true)
            {
                if (bootloader_Trigger() == false)
                {
                    bootloader_Storage_Read();
                }
                btl_state = BOOTLOADER_READY_NEW_IMAGE;
            }
            break;
        }
</#if>
        case BOOTLOADER_READY_NEW_IMAGE:
        {
            do
            {
                input_task();

                if (media_write_data_ready)
                {
                    if (bootloader_Storage_Write(imageStartFlag, media_write_data, data_size) == true)
                    {
                        ${PERIPH_USED}_WriteByte(BL_RESP_OK);
                    }
                    else
                    {
                        ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
                    }
                    media_write_data_ready = false;
                    imageStartFlag = false;
                }

                if (packet_received)
                {
                    command_task();
                }
            } while(uartBLActive);
            break;
        }
        default:
        {
            // default
            break;
        }
    }
}
