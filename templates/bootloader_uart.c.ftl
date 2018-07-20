/**
*
* \brief UART Bootloader
*
* Copyright (c) 2018 Microchip Technology Inc.
*
* SPDX-License-Identifier: Apache-2.0
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License.
* You may obtain a copy of the Licence at
*
 * http://www.apache.org/licenses/LICENSE-2.0
*
 * Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an AS IS BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
*/

#include "definitions.h"
#include <device.h>

#define BL_REQ_PIN            PIN_${BTL_REQ_PIN}

#define PAGE_SIZE             ${.vars["${MEM_USED?lower_case}"].FLASH_PROGRAM_SIZE}
#define ERASE_BLOCK_SIZE      ${.vars["${MEM_USED?lower_case}"].FLASH_ERASE_SIZE}

#define BOOTLOADER_SIZE       ERASE_BLOCK_SIZE
#define APP_START_ADDRESS     (${.vars["${MEM_USED?lower_case}"].FLASH_START_ADDRESS} + BOOTLOADER_SIZE)

#define GUARD_SIZE            4
#define OFFSET_SIZE           4
#define SIZE_SIZE             4
#define CRC_SIZE              4
#define ARB_WORD_SIZE         4
#define DATA_SIZE             PAGE_SIZE

#define WORDS(x)              ((int)((x) / sizeof(uint32_t)))

#define ALIGN_MASK            0xffffff00 // 256 bytes

#define BL_REQUEST            0x5048434D

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

//-----------------------------------------------------------------------------
static uint32_t *ram = (uint32_t *)${BTL_RAM_START};
static uint32_t usart_buffer[WORDS(GUARD_SIZE + OFFSET_SIZE + DATA_SIZE)];
static int usart_command = 0;
static uint32_t flash_data[WORDS(DATA_SIZE)];
static uint32_t flash_addr = 0;
static bool flash_data_ready = false;
static uint32_t unlock_begin = 0;
static uint32_t unlock_end = 0;

//-----------------------------------------------------------------------------
void run_application(void)
{
    uint32_t msp = *(uint32_t *)(APP_START_ADDRESS);
    uint32_t reset_vector = *(uint32_t *)(APP_START_ADDRESS + 4);

    if (0xffffffff == msp)
        return;

    __set_MSP(msp);

    /* Rebase the vector table base address */
    SCB->VTOR = ((uint32_t) APP_START_ADDRESS & SCB_VTOR_TBLOFF_Msk);

    asm("bx %0"::"r" (reset_vector));
}

//-----------------------------------------------------------------------------
bool bootloader_Trigger(void)
{
    // Cheap delay. This should give at leat 1 ms delay.
    for (int i = 0; i < 2000; i++)
        asm("nop");

    if (PIO_PinRead(BL_REQ_PIN) == false)
        return true;

    if (BL_REQUEST == ram[0] && BL_REQUEST == ram[1] &&
        BL_REQUEST == ram[2] && BL_REQUEST == ram[3])
    {
        ram[0] = 0;
        return true;
    }

    return false;
}

//-----------------------------------------------------------------------------
<#if BTL_HW_CRC_GEN == true>
    <#lt>static uint32_t crc_generate(void)
    <#lt>{
    <#lt>    uint32_t addr = unlock_begin;
    <#lt>    uint32_t size = unlock_end - unlock_begin;

    <#lt>    DSU->ADDR.reg = addr;
    <#lt>    DSU->LENGTH.reg = size;
    <#lt>    DSU->DATA.reg = 0xffffffff;
    <#lt>    DSU->STATUSA.reg = DSU->STATUSA.reg;
    <#lt>    DSU->CTRL.reg = DSU_CTRL_CRC;

    <#lt>    while (0 == DSU->STATUSA.bit.DONE);

    <#lt>    if (0 == DSU->STATUSA.bit.BERR)
    <#lt>         return (DSU->DATA.reg);

    <#lt>    return 0;
    <#lt>}
<#else>
    <#lt>static uint32_t crc_generate(void)
    <#lt>{
    <#lt>    uint32_t i, j, value;
    <#lt>    uint32_t size = unlock_end - unlock_begin;
    <#lt>    uint32_t crc = 0xffffffff;
    <#lt>    uint8_t data;
    <#lt>    uint32_t crc_tab[256];

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
    <#lt>        data = *(uint8_t *)(IFLASH_ADDR + unlock_begin + i);
    <#lt>
    <#lt>        crc = crc_tab[(crc ^ data) & 0xff] ^ (crc >> 8);
    <#lt>    }
    <#lt>    return crc;
    <#lt>}
</#if>

//-----------------------------------------------------------------------------
static void usart_task(void)
{
    static int ptr = 0;
    static int command = 0;
    static int size = 0;
    uint8_t *byte_buf = (uint8_t *)usart_buffer;
    int usart_data = 0;

    if (usart_command)
        return;

    if (${PERIPH_USED}_ReceiverIsReady() == false)
        return;

    usart_data = ${PERIPH_USED}_ReadByte();

    if (SYSTICK_TimerPeriodHasExpired())
        command = 0;

    if (0 == command)
    {
        ptr = 0;
        command = usart_data;
        usart_buffer[0] = 0;

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
        byte_buf[ptr++] = usart_data;
    }

    if (ptr == size)
    {
        usart_command = command;
        command = 0;
    }

    SYSTICK_TimerRestart();
}

//-----------------------------------------------------------------------------
static void command_task(void)
{
    if (BL_REQUEST != usart_buffer[0])
    {
        ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
    }
    else if (BL_CMD_UNLOCK == usart_command)
    {
        uint32_t begin = (usart_buffer[1] & ALIGN_MASK);
        uint32_t end = begin + (usart_buffer[2] & ALIGN_MASK);

        if (end > begin && end <= IFLASH_SIZE)
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
    else if (BL_CMD_DATA == usart_command)
    {
        flash_addr = usart_buffer[1];

        if (unlock_begin <= flash_addr && flash_addr < unlock_end)
        {
            for (int i = 0; i < WORDS(DATA_SIZE); i++)
                flash_data[i] = usart_buffer[i + 2];

            flash_data_ready = true;

            ${PERIPH_USED}_WriteByte(BL_RESP_OK);
        }
        else
        {
            ${PERIPH_USED}_WriteByte(BL_RESP_ERROR);
        }
    }
    else if (BL_CMD_VERIFY == usart_command)
    {
        uint32_t crc = usart_buffer[1];
        uint32_t crc_gen = 0;

        crc_gen = crc_generate();

        if (crc == crc_gen)
            ${PERIPH_USED}_WriteByte(BL_RESP_CRC_OK);
        else
            ${PERIPH_USED}_WriteByte(BL_RESP_CRC_FAIL);
    }
    else if (BL_CMD_RESET == usart_command)
    {
        // Unrolling the loop here saves significant amount of Flash
        ram[0] = usart_buffer[1];
        ram[1] = usart_buffer[2];
        ram[2] = usart_buffer[3];
        ram[3] = usart_buffer[4];

        ${PERIPH_USED}_WriteByte(BL_RESP_OK);
        ${PERIPH_USED}_Sync();

        NVIC_SystemReset();
    }
    else
    {
        ${PERIPH_USED}_WriteByte(BL_RESP_INVALID);
    }

    usart_command = 0;
}

//-----------------------------------------------------------------------------
static void flash_task(void)
{
    uint32_t addr = (flash_addr + IFLASH_ADDR);

    // Lock region size is always bigger than the row size
    ${MEM_USED}_RegionUnlock(addr);

    while(${MEM_USED}_IsBusy() == true);

    /* Erase the Current sector */
    if ((flash_addr % ERASE_BLOCK_SIZE) == 0)
    {
        ${MEM_USED}_SectorErase(addr);

        /* Receive Next Bytes while waiting for erase to complete */
        while(${MEM_USED}_IsBusy() == true)
            usart_task();
    }

    ${MEM_USED}_PageWrite(flash_data, addr);

    while(${MEM_USED}_IsBusy() == true);

    flash_data_ready = false;
}

//-----------------------------------------------------------------------------
void bootloader_start(void)
{
    while (1)
    {
        usart_task();
    
        if (flash_data_ready)
            flash_task();
        else if (usart_command)
            command_task();
    }
}

