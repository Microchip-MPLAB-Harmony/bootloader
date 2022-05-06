/*******************************************************************************
  ${BTL_TYPE} Bootloader Source File

  File Name:
    bootloader_${BTL_TYPE?lower_case}.c

  Summary:
    This file contains source code necessary to execute ${BTL_TYPE} bootloader.

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
#include "bootloader_common.h"
#include <device.h>

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

#define GUARD_OFFSET            0
#define CMD_OFFSET              2
#define ADDR_OFFSET             0
#define SIZE_OFFSET             1
#define DATA_OFFSET             1
#define CRC_OFFSET              0

#define CMD_SIZE                1
#define GUARD_SIZE              4
#define SIZE_SIZE               4
#define OFFSET_SIZE             4
#define CRC_SIZE                4
#define HEADER_SIZE             (GUARD_SIZE + SIZE_SIZE + CMD_SIZE)
#define DATA_SIZE               ERASE_BLOCK_SIZE

#define WORDS(x)                ((int)((x) / sizeof(uint32_t)))

#define OFFSET_ALIGN_MASK       (~ERASE_BLOCK_SIZE + 1)
#define SIZE_ALIGN_MASK         (~PAGE_SIZE + 1)

#define BTL_GUARD               (0x5048434DUL)

/* Compare Value to achieve a 100Ms Delay */
#define TIMER_COMPARE_VALUE     (CORE_TIMER_FREQUENCY / 10)

<#if BTL_FUSE_PROGRAM_ENABLE == true>
    <#lt>#define DEVCFG_ADDRESS          ${BTL_DEVCFG_ADDRESS}
    <#lt>#define DEVCFG_PAGE_ADDRESS     (DEVCFG_ADDRESS & OFFSET_ALIGN_MASK)
</#if>

enum
{
    BL_CMD_UNLOCK       = 0xa0,
    BL_CMD_DATA         = 0xa1,
    BL_CMD_VERIFY       = 0xa2,
    BL_CMD_RESET        = 0xa3,
<#if BTL_DUAL_BANK == true>
    BL_CMD_BKSWAP_RESET = 0xa4,
</#if>
<#if BTL_FUSE_PROGRAM_ENABLE == true>
    BL_CMD_DEVCFG_DATA  = 0xa5,
</#if>
    BL_CMD_READ_VERSION = 0xa6,
};

enum
{
    BL_RESP_OK          = 0x50,
    BL_RESP_ERROR       = 0x51,
    BL_RESP_INVALID     = 0x52,
    BL_RESP_CRC_OK      = 0x53,
    BL_RESP_CRC_FAIL    = 0x54,
};

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

static uint8_t btl_guard[4] = {0x4D, 0x43, 0x48, 0x50};

static uint32_t CACHE_ALIGN input_buffer[WORDS(OFFSET_SIZE + DATA_SIZE)];

static uint32_t CACHE_ALIGN flash_data[WORDS(DATA_SIZE)];

static uint32_t flash_addr          = 0;

static uint32_t unlock_begin        = 0;
static uint32_t unlock_end          = 0;
static uint32_t data_size           = 0;

static uint8_t  input_command       = 0;

static bool     packet_received     = false;
static bool     flash_data_ready    = false;

static bool     uartBLInitDone      = false;

static bool     uartBLActive        = false;

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

    input_data = ${PERIPH_USED}_ReadByte();

    /* Check if 100 ms have elapsed */
    if (CORETIMER_CompareHasExpired())
    {
        header_received = false;
        ptr = 0;
    }

    if (header_received == false)
    {
        byte_buf[ptr++] = input_data;

        // Check for each guard byte and discard if mismatch
        if (ptr <= GUARD_SIZE)
        {
            if (input_data != btl_guard[ptr-1])
            {
                ptr = 0;
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

                /* Disable global interrupts */
                __builtin_disable_interrupts();
            }

            ptr = 0;
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

    CORETIMER_Start();
}

/* Function to process the received command */
static void command_task(void)
{
    uint32_t i;

    if (BL_CMD_UNLOCK == input_command)
    {
        uint32_t begin  = (input_buffer[ADDR_OFFSET] & OFFSET_ALIGN_MASK);

        uint32_t end    = begin + (input_buffer[SIZE_OFFSET] & SIZE_ALIGN_MASK);

        if (end > begin && end <= (FLASH_START + FLASH_LENGTH))
        {
            unlock_begin = begin;
            unlock_end = end;
            ${PERIPH_USED}_WriteByte(BL_RESP_OK);
        }
        else
        {
            unlock_begin = 0;
            unlock_end = 0;
            ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
        }
    }
<#if BTL_FUSE_PROGRAM_ENABLE == true>
    else if ((BL_CMD_DATA == input_command) || (BL_CMD_DEVCFG_DATA == input_command))
    {
        flash_addr = (input_buffer[ADDR_OFFSET] & OFFSET_ALIGN_MASK);

        if (((BL_CMD_DATA == input_command) && (unlock_begin <= flash_addr && flash_addr < unlock_end))
            || ((BL_CMD_DEVCFG_DATA == input_command) && (flash_addr >= DEVCFG_PAGE_ADDRESS))
           )
        {
            for (i = 0; i < WORDS(DATA_SIZE); i++)
            {
                flash_data[i] = input_buffer[i + DATA_OFFSET];
            }

            flash_data_ready = true;
        }
        else
        {
            ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
        }
    }
<#else>
    else if (BL_CMD_DATA == input_command)
    {
        flash_addr = (input_buffer[ADDR_OFFSET] & OFFSET_ALIGN_MASK);

        if (unlock_begin <= flash_addr && flash_addr < unlock_end)
        {
            for (i = 0; i < WORDS(DATA_SIZE); i++)
            {
                flash_data[i] = input_buffer[i + DATA_OFFSET];
            }

            flash_data_ready = true;
        }
        else
        {
            ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
        }
    }
</#if>
    else if (BL_CMD_READ_VERSION == input_command)
    {
        ${PERIPH_USED}_WriteByte(BL_RESP_OK);

        uint16_t btlVersion = bootloader_GetVersion();

        ${PERIPH_USED}_WriteByte(((btlVersion >> 8) & 0xFF));
        ${PERIPH_USED}_WriteByte((btlVersion & 0xFF));
    }
    else if (BL_CMD_VERIFY == input_command)
    {
        uint32_t crc        = input_buffer[CRC_OFFSET];
        uint32_t crc_gen    = 0;

        crc_gen = bootloader_CRCGenerate(unlock_begin, (unlock_end - unlock_begin));

        if (crc == crc_gen)
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

        while(${PERIPH_USED}_TransmitComplete() == false);

        bootloader_TriggerReset();
    }
<#if BTL_DUAL_BANK == true>
    else if (BL_CMD_BKSWAP_RESET == input_command)
    {
        bootloader_UpdateUpperFlashSerial();

        ${PERIPH_USED}_WriteByte(BL_RESP_OK);

        while(${PERIPH_USED}_TransmitComplete() == false);

        bootloader_TriggerReset();
    }
</#if>
    else
    {
        ${PERIPH_USED}_WriteByte(BL_RESP_INVALID);
    }

    packet_received = false;
}

/* Function to program received application firmware data into internal flash */
static void flash_task(void)
{
    uint32_t addr       = flash_addr;
    uint32_t bytes_written   = 0;
    uint32_t write_idx  = 0;

    // data_size = Actual data bytes to write + Address 4 Bytes
    uint32_t bytes_to_write = (data_size - 4);

<#if BTL_DUAL_BANK == true>
    if (addr == LOWER_FLASH_SERIAL_SECTOR)
    {
        /* Send error response if active Flash Panels (Lower Flash)
         * Serial Sector is being erased.
         */
        flash_data_ready = false;

        ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);

        return;
    }
    else if (addr == UPPER_FLASH_SERIAL_SECTOR)
    {
        bootloader_SetUpperFlashSerialErased(true);
    }
</#if>

<#if BTL_FUSE_PROGRAM_ENABLE == true>
    <#if (__PROCESSOR?matches("PIC32MX.*") == false) || (__PROCESSOR?matches("PIC32MZ.[0-9]*W") == false)>
        <#lt>    if (flash_addr >= DEVCFG_PAGE_ADDRESS)
        <#lt>    {
        <#lt>        ${MEM_USED}_BootFlashWriteProtectDisable(NVM_LOWER_BOOT_WRITE_PROTECT_3);
        <#lt>    }

    </#if>
</#if>
    /* Erase the Current sector */
    ${.vars["${MEM_USED?lower_case}"].ERASE_API_NAME}(addr);

    /* Wait for erase to complete */
    while(${MEM_USED}_IsBusy() == true);

    for (bytes_written = 0; bytes_written < bytes_to_write; bytes_written += PAGE_SIZE)
    {
        ${.vars["${MEM_USED?lower_case}"].WRITE_API_NAME}(&flash_data[write_idx], addr);

        while(${MEM_USED}_IsBusy() == true);

        addr += PAGE_SIZE;
        write_idx += WORDS(PAGE_SIZE);
    }

    flash_data_ready = false;

    ${PERIPH_USED}_WriteByte(BL_RESP_OK);
}

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Global Functions
// *****************************************************************************
// *****************************************************************************

void bootloader_${BTL_TYPE}_Tasks(void)
{
    if (uartBLInitDone == false)
    {
        CORETIMER_CompareSet(TIMER_COMPARE_VALUE);

        uartBLInitDone = true;
    }

    do
    {
<#if BTL_WDOG_ENABLE?? &&  BTL_WDOG_ENABLE == true>
        kickdog();

</#if>
        input_task();

        if (flash_data_ready)
        {
            flash_task();
        }
        else if (packet_received)
        {
            command_task();
        }
    } while (uartBLActive);
}
