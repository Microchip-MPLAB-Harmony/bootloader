/*******************************************************************************
  UART Bootloader Source File

  File Name:
    bootloader.c

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

#define BL_REQ_PIN              PIN_${BTL_REQ_PIN}

#define FLASH_START             (${.vars["${MEM_USED?lower_case}"].FLASH_START_ADDRESS}UL)
#define FLASH_LENGTH            (${.vars["${MEM_USED?lower_case}"].FLASH_SIZE}UL)
#define PAGE_SIZE               (${.vars["${MEM_USED?lower_case}"].FLASH_PROGRAM_SIZE}UL)
#define ERASE_BLOCK_SIZE        (${.vars["${MEM_USED?lower_case}"].FLASH_ERASE_SIZE}UL)
#define PAGES_IN_ERASE_BLOCK    (ERASE_BLOCK_SIZE / PAGE_SIZE)

#define BOOTLOADER_SIZE         ERASE_BLOCK_SIZE
#define APP_START_ADDRESS       (0x${core.APP_START_ADDRESS}UL)

#define GUARD_SIZE              4
#define OFFSET_SIZE             4
#define SIZE_SIZE               4
#define CRC_SIZE                4
#define ARB_WORD_SIZE           4
#define DATA_SIZE               ERASE_BLOCK_SIZE

#define WORDS(x)                ((int)((x) / sizeof(uint32_t)))

#define OFFSET_ALIGN_MASK       (~ERASE_BLOCK_SIZE + 1)
#define SIZE_ALIGN_MASK         (~PAGE_SIZE + 1)

#define BL_REQUEST              (0x5048434DUL)

enum
{
  BL_CMD_UNLOCK    = 0xa0,
  BL_CMD_DATA      = 0xa1,
  BL_CMD_VERIFY    = 0xa2,
  BL_CMD_RESET     = 0xa3,
};

enum
{
  BL_RESP_OK       = 0x50,
  BL_RESP_ERROR    = 0x51,
  BL_RESP_INVALID  = 0x52,
  BL_RESP_CRC_OK   = 0x53,
  BL_RESP_CRC_FAIL = 0x54,
};

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

static uint32_t input_buffer[WORDS(GUARD_SIZE + OFFSET_SIZE + DATA_SIZE)];

static uint32_t flash_data[WORDS(DATA_SIZE)];
static uint32_t flash_addr          = 0;

static uint32_t *sram                = (uint32_t *)${BTL_RAM_START};

static uint32_t unlock_begin        = 0;
static uint32_t unlock_end          = 0;

static bool     flash_data_ready    = false;
static int      input_command       = 0;

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Local Functions
// *****************************************************************************
// *****************************************************************************

<#if BTL_HW_CRC_GEN == true>
    <#lt>/* Function to Generate CRC using the device service unit peripheral on programmed data */
    <#lt>static uint32_t crc_generate(void)
    <#lt>{
    <#lt>    uint32_t addr = unlock_begin;
    <#lt>    uint32_t size = unlock_end - unlock_begin;
    <#lt>    uint32_t crc  = 0;

    <#lt>    PAC_PeripheralProtectSetup (PAC_PERIPHERAL_DSU, PAC_PROTECTION_CLEAR);

    <#lt>    DSU_CRCCalculate (addr, size, 0xffffffff, &crc);

    <#lt>    return crc;
    <#lt>}
<#else>
    <#lt>/* Function to Generate CRC by reading the firmware programmed into internal flash */
    <#lt>static uint32_t crc_generate(void)
    <#lt>{
    <#lt>    uint32_t   i, j, value;
    <#lt>    uint32_t   crc_tab[256];
    <#lt>    uint32_t   size    = unlock_end - unlock_begin;
    <#lt>    uint32_t   crc     = 0xffffffff;
    <#lt>    uint8_t    data;

    <#lt>    for (i = 0; i < 256; i++)
    <#lt>    {
    <#lt>        value = i;

    <#lt>        for (j = 0; j < 8; j++)
    <#lt>        {
    <#lt>            if (value & 1)
    <#lt>            {
    <#lt>                value = (value >> 1) ^ 0xEDB88320;
    <#lt>            }
    <#lt>            else
    <#lt>            {
    <#lt>                value >>= 1;
    <#lt>            }
    <#lt>        }
    <#lt>        crc_tab[i] = value;
    <#lt>    }

    <#lt>    for (i = 0; i < size; i++)
    <#lt>    {
    <#lt>        data = *(uint8_t *)(FLASH_START + unlock_begin + i);
    <#lt>
    <#lt>        crc = crc_tab[(crc ^ data) & 0xff] ^ (crc >> 8);
    <#lt>    }
    <#lt>    return crc;
    <#lt>}
</#if>

/* Function to receive application firmware via UART/USART */
static void input_task(void)
{
    static int  ptr         = 0;
    static int  command     = 0;
    static int  size        = 0;
    uint8_t     *byte_buf   = (uint8_t *)input_buffer;
    int         input_data  = 0;

    if (input_command)
    {
        return;
    }

    if (${PERIPH_USED}_ReceiverIsReady() == false)
    {
        return;
    }

    input_data = ${PERIPH_USED}_ReadByte();

    /* Check if 100 ms have elapsed */
    if (SYSTICK_TimerPeriodHasExpired())
    {
        command = 0;
    }

    if (0 == command)
    {
        ptr = 0;
        command = input_data;
        input_buffer[0] = 0;

        switch(command)
        {
            case BL_CMD_UNLOCK:
                size = GUARD_SIZE + OFFSET_SIZE + SIZE_SIZE;
                break;
            case BL_CMD_DATA:
                size = GUARD_SIZE + OFFSET_SIZE + DATA_SIZE;
                break;
            case BL_CMD_VERIFY:
                size = GUARD_SIZE + CRC_SIZE;
                break;
            case BL_CMD_RESET:
                size = GUARD_SIZE + ARB_WORD_SIZE * 4;
                break;
            default:
                size = 0;
                break;
        }
    }
    else if (ptr < size)
    {
        byte_buf[ptr++] = input_data;
    }

    if (ptr == size)
    {
        input_command = command;
        command = 0;
    }

    SYSTICK_TimerRestart();
}

/* Function to process the received command */
static void command_task(void)
{
    if (BL_REQUEST != input_buffer[0])
    {
        ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
    }
    else if (BL_CMD_UNLOCK == input_command)
    {
        uint32_t begin  = (input_buffer[1] & OFFSET_ALIGN_MASK);
        uint32_t end    = begin + (input_buffer[2] & SIZE_ALIGN_MASK);

        if (end > begin && end <= FLASH_LENGTH)
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
    else if (BL_CMD_DATA == input_command)
    {
        flash_addr = (input_buffer[1] & OFFSET_ALIGN_MASK);

        if (unlock_begin <= flash_addr && flash_addr < unlock_end)
        {
            for (int i = 0; i < WORDS(DATA_SIZE); i++)
                flash_data[i] = input_buffer[i + 2];

            flash_data_ready = true;

            ${PERIPH_USED}_WriteByte(BL_RESP_OK);
        }
        else
        {
            ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
        }
    }
    else if (BL_CMD_VERIFY == input_command)
    {
        uint32_t crc        = input_buffer[1];
        uint32_t crc_gen    = 0;

        crc_gen = crc_generate();

        if (crc == crc_gen)
            ${PERIPH_USED}_WriteByte(BL_RESP_CRC_OK);
        else
            ${PERIPH_USED}_WriteByte(BL_RESP_CRC_FAIL);
    }
    else if (BL_CMD_RESET == input_command)
    {
        // Unrolling the loop here saves significant amount of Flash
        sram[0] = input_buffer[1];
        sram[1] = input_buffer[2];
        sram[2] = input_buffer[3];
        sram[3] = input_buffer[4];

        ${PERIPH_USED}_WriteByte(BL_RESP_OK);

        while(${PERIPH_USED}_TransmitComplete() == false);

        NVIC_SystemReset();
    }
    else
    {
        ${PERIPH_USED}_WriteByte(BL_RESP_INVALID);
    }

    input_command = 0;
}

/* Function to program received application firmware data into internal flash */
static void flash_task(void)
{
    uint32_t addr       = (flash_addr + FLASH_START);
    uint32_t page       = 0;
    uint32_t write_idx  = 0;

    // Lock region size is always bigger than the row size
    ${MEM_USED}_RegionUnlock(addr);

    while(${MEM_USED}_IsBusy() == true)
        input_task();

    /* Erase the Current sector */
    ${.vars["${MEM_USED?lower_case}"].ERASE_API_NAME}(addr);

    /* Receive Next Bytes while waiting for erase to complete */
    while(${MEM_USED}_IsBusy() == true)
        input_task();

    for (page = 0; page < PAGES_IN_ERASE_BLOCK; page++)
    {
        ${.vars["${MEM_USED?lower_case}"].WRITE_API_NAME}(&flash_data[write_idx], addr);

        while(${MEM_USED}_IsBusy() == true)
            input_task();

        addr += PAGE_SIZE;
        write_idx += WORDS(PAGE_SIZE);
    }

    flash_data_ready = false;
}

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Global Functions
// *****************************************************************************
// *****************************************************************************

void run_Application(void)
{
    uint32_t msp            = *(uint32_t *)(APP_START_ADDRESS);
    uint32_t reset_vector   = *(uint32_t *)(APP_START_ADDRESS + 4);

    if (0xffffffff == msp)
    {
        return;
    }

    __set_MSP(msp);

    /* Rebase the vector table base address */
    SCB->VTOR = ((uint32_t) APP_START_ADDRESS & SCB_VTOR_TBLOFF_Msk);

    asm("bx %0"::"r" (reset_vector));
}

bool bootloader_Trigger(void)
{
    uint32_t i;

    // Cheap delay. This should give at leat 1 ms delay.
    for (i = 0; i < 2000; i++)
    {
        asm("nop");
    }

    if (${core.PORT_API_PREFIX}_PinRead(BL_REQ_PIN) == false)
    {
        return true;
    }

    if (BL_REQUEST == sram[0] && BL_REQUEST == sram[1] &&
        BL_REQUEST == sram[2] && BL_REQUEST == sram[3])
    {
        sram[0] = 0;
        return true;
    }

    return false;
}

void bootloader_Start(void)
{
    while (1)
    {
        input_task();

        if (flash_data_ready)
            flash_task();
        else if (input_command)
            command_task();
    }
}
