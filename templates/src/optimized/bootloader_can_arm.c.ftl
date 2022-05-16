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

/* Standard identifier id[28:18]*/
#define WRITE_ID(id)             (id << 18U)
#define READ_ID(id)              (id >> 18U)

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
static uint8_t rxFiFo0[${PERIPH_USED}_RX_FIFO0_SIZE];
static uint8_t txFiFo[${PERIPH_USED}_TX_FIFO_BUFFER_SIZE];
static uint8_t data_seq;

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Local Functions
// *****************************************************************************
// *****************************************************************************

/* Data length code to Message Length */
static uint8_t CANDlcToLengthGet(uint8_t dlc)
{
    uint8_t msgLength[] = {0U, 1U, 2U, 3U, 4U, 5U, 6U, 7U, 8U, 12U, 16U, 20U, 24U, 32U, 48U, 64U};
    return msgLength[dlc];
}

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
    ${PERIPH_NAME}_TX_BUFFER *txBuffer = NULL;

    memset(txFiFo, 0U, ${PERIPH_USED}_TX_FIFO_BUFFER_ELEMENT_SIZE);
    txBuffer = (${PERIPH_NAME}_TX_BUFFER *)txFiFo;
    txBuffer->id = WRITE_ID(${PERIPH_NAME}_FILTER_ID);
    txBuffer->dlc = 1U;
    txBuffer->fdf = 1U;
    txBuffer->brs = 1U;

    if ((rx_messageLength < HEADER_SIZE) || (size > MAX_DATA_SIZE) ||
        (rx_messageLength < (HEADER_SIZE + size)) || (HEADER_MAGIC != rx_message[HEADER_MAGIC_OFFSET]))
    {
        txBuffer->data[0] = BL_RESP_ERROR;
        ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
    }
    else if (BL_CMD_UNLOCK == command)
    {
        uint32_t begin  = (data[ADDR_OFFSET] & OFFSET_ALIGN_MASK);

        uint32_t end    = begin + (data[SIZE_OFFSET] & SIZE_ALIGN_MASK);

        if (end > begin && end <= (FLASH_START + FLASH_LENGTH) && size == (OFFSET_SIZE + SIZE_SIZE))
        {
            unlock_begin = begin;
            unlock_end = end;
            txBuffer->data[0] = BL_RESP_OK;
            ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
        else
        {
            unlock_begin = 0;
            unlock_end = 0;
            txBuffer->data[0] = BL_RESP_ERROR;
            ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
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
            txBuffer->data[0] = BL_RESP_SEQ_ERROR;
            ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
        else
        {
            for (uint8_t i = 0; i < size; i++)
            {
                if (0 == flash_size)
                {
                    txBuffer->data[0] = BL_RESP_ERROR;
                    ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
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
            txBuffer->data[0] = BL_RESP_OK;
            ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
    }
    else if (BL_CMD_VERIFY == command)
    {
        uint32_t crc        = data[CRC_OFFSET];
        uint32_t crc_gen    = 0;

        if (size != CRC_SIZE)
        {
            txBuffer->data[0] = BL_RESP_ERROR;
            ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }

        crc_gen = crc_generate();

        if (crc == crc_gen)
        {
            txBuffer->data[0] = BL_RESP_CRC_OK;
            ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
        else
        {
            txBuffer->data[0] = BL_RESP_CRC_FAIL;
            ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
    }
<#if BTL_DUAL_BANK == true>
    else if (BL_CMD_BKSWAP_RESET == command)
    {
        if (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_TFE_MASK))
        {
            ${PERIPH_USED}_InterruptClear(${PERIPH_NAME}_INTERRUPT_TFE_MASK);
        }

        txBuffer->data[0] = BL_RESP_OK;
        ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        while (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_TFE_MASK) == false);

        ${MEM_USED}_BankSwap();
    }
</#if>
    else if (BL_CMD_RESET == command)
    {
        if (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_TFE_MASK))
        {
            ${PERIPH_USED}_InterruptClear(${PERIPH_NAME}_INTERRUPT_TFE_MASK);
        }

        txBuffer->data[0] = BL_RESP_OK;
        ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        while (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_TFE_MASK) == false);

        NVIC_SystemReset();
    }
    else
    {
        txBuffer->data[0] = BL_RESP_INVALID;
        ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
    }
}

/* Function to receive application firmware via ${PERIPH_USED} */
static void ${PERIPH_USED}_task(void)
{
    uint32_t                   status = 0U;
    uint8_t                    numberOfMessage = 0U;
    uint8_t                    count = 0U;
    ${PERIPH_NAME}_RX_BUFFER   *rxBuf = NULL;

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
            numberOfMessage = ${PERIPH_USED}_RxFifoFillLevelGet(${PERIPH_NAME}_RX_FIFO_0);
            if (numberOfMessage != 0U)
            {
                memset(rxFiFo0, 0U, (numberOfMessage * ${PERIPH_USED}_RX_FIFO0_ELEMENT_SIZE));
                if (${PERIPH_USED}_MessageReceiveFifo(${PERIPH_NAME}_RX_FIFO_0, numberOfMessage, (${PERIPH_NAME}_RX_BUFFER *)rxFiFo0) == true)
                {
                    rxBuf = (${PERIPH_NAME}_RX_BUFFER *)rxFiFo0;
                    for (count = 0U; count < numberOfMessage; count++)
                    {
                        process_command(rxBuf->data, CANDlcToLengthGet(rxBuf->dlc));
                        rxBuf += ${PERIPH_USED}_RX_FIFO0_ELEMENT_SIZE;
                    }
                }
            }
        }
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Global Functions
// *****************************************************************************
// *****************************************************************************

void bootloader_Tasks(void)
{
    /* Set ${PERIPH_USED} Message RAM Configuration */
    ${PERIPH_USED}_MessageRAMConfigSet(${PERIPH_USED?lower_case}MessageRAM);

    while (1)
    {
        ${PERIPH_USED}_task();
    }
}
