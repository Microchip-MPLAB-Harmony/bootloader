/*******************************************************************************
  CAN Bootloader Source File

  File Name:
    bootloader.c

  Summary:
    This file contains source code necessary to execute CAN bootloader.

  Description:
    This file contains source code necessary to execute CAN bootloader.
    It implements bootloader protocol which uses CAN peripheral to download
    application firmware into internal flash from HOST.
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

#include "definitions.h"
#include <device.h>

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

#define FLASH_START              (${.vars["${MEM_USED?lower_case}"].FLASH_START_ADDRESS}UL)
#define FLASH_LENGTH             (${.vars["${MEM_USED?lower_case}"].FLASH_SIZE}UL)
#define PAGE_SIZE                (${.vars["${MEM_USED?lower_case}"].FLASH_PROGRAM_SIZE}UL)
#define ERASE_BLOCK_SIZE         (${.vars["${MEM_USED?lower_case}"].FLASH_ERASE_SIZE}UL)

#define BOOTLOADER_SIZE          ${BTL_SIZE}

#define APP_START_ADDRESS        (0x${core.APP_START_ADDRESS}UL)

#define ADDR_OFFSET              1
#define SIZE_OFFSET              2
#define CRC_OFFSET               1

#define HEADER_CMD_OFFSET        0
#define HEADER_SEQ_OFFSET        1
#define HEADER_MAGIC_OFFSET      2
#define HEADER_SIZE_OFFSET       3

#define CRC_SIZE                 4
#define HEADER_SIZE              4
#define OFFSET_SIZE              4
#define SIZE_SIZE                4
#define MAX_DATA_SIZE            60

#define HEADER_MAGIC             0xE2
#define ${PERIPH_NAME}_FILTER_ID 0x45A

#define WORDS(x)                 ((int)((x) / sizeof(uint32_t)))

#define OFFSET_ALIGN_MASK        (~ERASE_BLOCK_SIZE + 1)
#define SIZE_ALIGN_MASK          (~PAGE_SIZE + 1)

enum
{
    BL_CMD_UNLOCK       = 0xa0,
    BL_CMD_DATA         = 0xa1,
    BL_CMD_VERIFY       = 0xa2,
    BL_CMD_RESET        = 0xa3,
<#if BTL_DUAL_BANK == true>
    BL_CMD_BKSWAP_RESET = 0xa4,
</#if>
};

enum
{
    BL_RESP_OK          = 0x50,
    BL_RESP_ERROR       = 0x51,
    BL_RESP_INVALID     = 0x52,
    BL_RESP_CRC_OK      = 0x53,
    BL_RESP_CRC_FAIL    = 0x54,
    BL_RESP_SEQ_ERROR   = 0x55
};

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

static uint8_t  flash_data[PAGE_SIZE];
static uint32_t flash_addr;
static uint32_t flash_size;
static uint32_t flash_ptr;

static uint32_t unlock_begin;
static uint32_t unlock_end;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
static uint8_t CACHE_ALIGN __attribute__((space(data), section (".${PERIPH_USED?lower_case}_message_ram"))) ${PERIPH_USED?lower_case}MessageRAM[${PERIPH_USED}_MESSAGE_RAM_CONFIG_SIZE];
<#else>
static uint8_t CACHE_ALIGN ${PERIPH_USED?lower_case}MessageRAM[${PERIPH_USED}_MESSAGE_RAM_CONFIG_SIZE];
</#if>
static uint8_t rx_message[HEADER_SIZE + MAX_DATA_SIZE];
static uint8_t data_seq;

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

    <#lt>    PAC_PeripheralProtectSetup (PAC_PERIPHERAL_DSU, PAC_PROTECTION_SET);

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
    <#lt>        data = *(uint8_t *)(unlock_begin + i);
    <#lt>
    <#lt>        crc = crc_tab[(crc ^ data) & 0xff] ^ (crc >> 8);
    <#lt>    }
    <#lt>    return crc;
    <#lt>}
</#if>

/* Function to program received application firmware data into internal flash */
static void flash_write(void)
{
    if (0 == (flash_addr % ERASE_BLOCK_SIZE))
	{
		/* Lock region size is always bigger than the row size */
		${MEM_USED}_RegionUnlock(flash_addr);

		while(${MEM_USED}_IsBusy() == true);

		/* Erase the Current sector */
		${.vars["${MEM_USED?lower_case}"].ERASE_API_NAME}(flash_addr);

		while(${MEM_USED}_IsBusy() == true);
	}

    /* Write Page */
    ${.vars["${MEM_USED?lower_case}"].WRITE_API_NAME}((uint32_t *)&flash_data[0], flash_addr);

    while(${MEM_USED}_IsBusy() == true);
}

/* Function to process command from the received message */
static void process_command(uint8_t *rx_message, uint8_t rx_messageLength)
{
    uint32_t command = rx_message[HEADER_CMD_OFFSET];
    uint32_t size = rx_message[HEADER_SIZE_OFFSET];
    uint32_t *data = (uint32_t *)rx_message;
    uint8_t tx_message = 0;

    if ((rx_messageLength < HEADER_SIZE) || (size > MAX_DATA_SIZE) ||
        (rx_messageLength < (HEADER_SIZE + size)) || (HEADER_MAGIC != rx_message[HEADER_MAGIC_OFFSET]))
    {
        tx_message = BL_RESP_ERROR;
        ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
    }
    else if (BL_CMD_UNLOCK == command)
    {
        uint32_t begin  = (data[ADDR_OFFSET] & OFFSET_ALIGN_MASK);

        uint32_t end    = begin + (data[SIZE_OFFSET] & SIZE_ALIGN_MASK);

        if (end > begin && end <= (FLASH_START + FLASH_LENGTH) && size == (OFFSET_SIZE + SIZE_SIZE))
        {
            unlock_begin = begin;
            unlock_end = end;
            tx_message = BL_RESP_OK;
            ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
        }
        else
        {
            unlock_begin = 0;
            unlock_end = 0;
            tx_message = BL_RESP_ERROR;
            ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
        }
        data_seq = 0;
        flash_ptr = 0;
        flash_addr = unlock_begin;
        flash_size = unlock_end;
    }
    else if (BL_CMD_DATA == command)
    {
        if (rx_message[HEADER_SEQ_OFFSET] != data_seq)
        {
            tx_message = BL_RESP_SEQ_ERROR;
            ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
        }
        else
        {
            for (uint8_t i = 0; i < size; i++)
            {
                if (0 == flash_size)
                {
                    tx_message = BL_RESP_ERROR;
                    ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
                    return;
                }

                flash_data[flash_ptr++] = rx_message[HEADER_SIZE + i];

                if (flash_ptr == PAGE_SIZE)
                {
                    flash_write();

                    flash_ptr = 0;
                    flash_addr += PAGE_SIZE;
                    flash_size -= PAGE_SIZE;
                }
            }
            data_seq++;
            tx_message = BL_RESP_OK;
            ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
        }
    }
    else if (BL_CMD_VERIFY == command)
    {
        uint32_t crc        = data[CRC_OFFSET];
        uint32_t crc_gen    = 0;

        if (size != CRC_SIZE)
        {
            tx_message = BL_RESP_ERROR;
            ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
        }

        crc_gen = crc_generate();

        if (crc == crc_gen)
        {
            tx_message = BL_RESP_CRC_OK;
            ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
        }
        else
        {
            tx_message = BL_RESP_CRC_FAIL;
            ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
        }
    }
<#if BTL_DUAL_BANK == true>
    else if (BL_CMD_BKSWAP_RESET == command)
    {
        tx_message = BL_RESP_OK;

        if (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_TFE_MASK))
        {
            ${PERIPH_USED}_InterruptClear(${PERIPH_NAME}_INTERRUPT_TFE_MASK);
        }
        ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
        while (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_TFE_MASK) == false);

        ${MEM_USED}_BankSwap();
    }
</#if>
    else if (BL_CMD_RESET == command)
    {
        tx_message = BL_RESP_OK;

        if (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_TFE_MASK))
        {
            ${PERIPH_USED}_InterruptClear(${PERIPH_NAME}_INTERRUPT_TFE_MASK);
        }
        ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
        while (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_TFE_MASK) == false);

        NVIC_SystemReset();
    }
    else
    {
        tx_message = BL_RESP_INVALID;
        ${PERIPH_USED}_MessageTransmit(${PERIPH_NAME}_FILTER_ID, 1, &tx_message, ${PERIPH_NAME}_MODE_FD_WITH_BRS, ${PERIPH_NAME}_MSG_ATTR_TX_FIFO_DATA_FRAME);
    }
}

/* Function to receive application firmware via ${PERIPH_USED} */
static void ${PERIPH_USED}_task(void)
{
    uint32_t                   status = 0;
    uint32_t                   rx_messageID = 0;
    uint8_t                    rx_messageLength = 0;
    ${PERIPH_NAME}_MSG_RX_FRAME_ATTRIBUTE msgFrameAttr = ${PERIPH_NAME}_MSG_RX_DATA_FRAME;

    if (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_RF0N_MASK))
    {
        ${PERIPH_USED}_InterruptClear(${PERIPH_NAME}_INTERRUPT_RF0N_MASK);

        /* Check ${PERIPH_USED} Status */
        status = ${PERIPH_USED}_ErrorGet();
        <#if PERIPH_NAME == "CAN">
        if (((status & ${PERIPH_NAME}_PSR_LEC_Msk) == ${PERIPH_NAME}_ERROR_NONE) || ((status & ${PERIPH_NAME}_PSR_LEC_Msk) == ${PERIPH_NAME}_ERROR_LEC_NC))
        <#else>
        if (((status & ${PERIPH_NAME}_PSR_LEC_Msk) == ${PERIPH_NAME}_ERROR_NONE) || ((status & ${PERIPH_NAME}_PSR_LEC_Msk) == ${PERIPH_NAME}_ERROR_LEC_NO_CHANGE))
        </#if>
        {
            memset(rx_message, 0x00, sizeof(rx_message));

            /* Receive FIFO 0 New Message */
            if (${PERIPH_USED}_MessageReceive(&rx_messageID, &rx_messageLength, rx_message, 0, ${PERIPH_NAME}_MSG_ATTR_RX_FIFO0, &msgFrameAttr) == true)
            {
                process_command(rx_message, rx_messageLength);
                (void)rx_messageID;
            }
        }
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
    uint32_t reset_vector   = *(uint32_t *)(APP_START_ADDRESS + 4);

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

void bootloader_Tasks(void)
{
    /* Set ${PERIPH_USED} Message RAM Configuration */
    ${PERIPH_USED}_MessageRAMConfigSet(${PERIPH_USED?lower_case}MessageRAM);

    while (1)
    {
        ${PERIPH_USED}_task();
    }
}
