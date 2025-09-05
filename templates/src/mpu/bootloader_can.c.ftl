/*******************************************************************************
  ${BTL_TYPE} Bootloader Source File

  File Name:
    bootloader_${BTL_TYPE?lower_case}.c

  Summary:
    This file contains source code necessary to execute ${BTL_TYPE} bootloader.

  Description:
    This file contains source code necessary to execute CAN bootloader.
    It implements bootloader protocol which uses CAN peripheral to download
    application firmware into external media from embedded Host.
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2025 Microchip Technology Inc. and its subsidiaries.
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
#include "bootloader_storage.h"

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

#define ADDR_OFFSET              1U
#define SIZE_OFFSET              2U
#define CRC_OFFSET               1U

#define HEADER_CMD_OFFSET        0U
#define HEADER_SEQ_OFFSET        1U
#define HEADER_MAGIC_OFFSET      2U
#define HEADER_SIZE_OFFSET       3U

#define CRC_SIZE                 4U
#define HEADER_SIZE              4U
#define OFFSET_SIZE              4U
#define SIZE_SIZE                4U
#define MAX_DATA_SIZE            60U

#define HEADER_MAGIC              0xE2U
#define ${PERIPH_NAME}_FILTER_ID  0x45AUL

/* Standard identifier id[28:18]*/
#define WRITE_ID(id)             ((id) << (18U))
#define READ_ID(id)              ((id) >> (18U))

#define    BL_CMD_UNLOCK         (0xa0U)
#define    BL_CMD_DATA           (0xa1U)
#define    BL_CMD_VERIFY         (0xa2U)
#define    BL_CMD_RESET          (0xa3U)
#define    BL_CMD_READ_VERSION   (0xa6U)


enum
{
    BL_RESP_OK          = 0x50,
    BL_RESP_ERROR       = 0x51,
    BL_RESP_INVALID     = 0x52,
    BL_RESP_CRC_OK      = 0x53,
    BL_RESP_CRC_FAIL    = 0x54,
    BL_RESP_SEQ_ERROR   = 0x55
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

static uint8_t  media_write_data[PAGE_SIZE];
static uint32_t media_ptr;
static uint32_t image_addr;
static uint32_t image_size;
static bool     imageStartFlag      = false;

<#if DRIVER_USED != "">
static BOOTLOADER_STATES btl_state = BOOTLOADER_STATE_INIT;
<#else>
static BOOTLOADER_STATES btl_state = BOOTLOADER_REGISTER_EVENT_HANDLER;
</#if>

static uint32_t unlock_begin;
static uint32_t unlock_end;

<#if core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true >
static uint8_t CACHE_ALIGN __attribute__((__section__(".region_sram"))) ${PERIPH_USED?lower_case}MessageRAM[${PERIPH_USED}_MESSAGE_RAM_CONFIG_SIZE];
<#else>
static uint8_t CACHE_ALIGN ${PERIPH_USED?lower_case}MessageRAM[${PERIPH_USED}_MESSAGE_RAM_CONFIG_SIZE];
</#if>
static uint8_t rxFiFo0[${PERIPH_USED}_RX_FIFO0_SIZE];
static uint8_t txFiFo[${PERIPH_USED}_TX_FIFO_BUFFER_SIZE];
static uint8_t data_seq;

static bool canBLInitDone      = false;

static bool canBLActive        = false;

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


/* Function to process command from the received message */
static void process_command(uint8_t *rx_message, uint8_t rx_messageLength)
{
    uint32_t command = rx_message[HEADER_CMD_OFFSET];
    uint32_t size = rx_message[HEADER_SIZE_OFFSET];
    uint32_t *data = (uint32_t *)(uintptr_t)rx_message;
    ${PERIPH_NAME}_TX_BUFFER *txBuffer = NULL;

    (void) memset(txFiFo, 0, ${PERIPH_USED}_TX_FIFO_BUFFER_ELEMENT_SIZE);
    txBuffer = (${PERIPH_NAME}_TX_BUFFER *)(uintptr_t)txFiFo;
    txBuffer->id = WRITE_ID(${PERIPH_NAME}_FILTER_ID);
    txBuffer->dlc = 1U;
    txBuffer->fdf = 1U;
    txBuffer->brs = 1U;

    if ((rx_messageLength < HEADER_SIZE) || (size > MAX_DATA_SIZE) ||
        (rx_messageLength < (HEADER_SIZE + size)) || (HEADER_MAGIC != rx_message[HEADER_MAGIC_OFFSET]))
    {
        txBuffer->data[0] = BL_RESP_ERROR;
        (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
    }
    else if (BL_CMD_UNLOCK == command)
    {
        uint32_t begin  = data[ADDR_OFFSET];

        uint32_t end    = begin + data[SIZE_OFFSET];

        imageStartFlag = true;

        if ((end > begin) && (size == (OFFSET_SIZE + SIZE_SIZE)))
        {
            unlock_begin = begin;
            unlock_end = end;
            <#if DRIVER_USED != "">
            bootloader_ImageSizeSet(data[SIZE_OFFSET]);
            </#if>
            txBuffer->data[0] = BL_RESP_OK;
           (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
        else
        {
            unlock_begin = 0;
            unlock_end = 0;
            txBuffer->data[0] = BL_RESP_ERROR;
            (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
        data_seq = 0;
        media_ptr = 0;
        image_addr = unlock_begin;
        image_size = unlock_end;
    }
    else if (BL_CMD_DATA == command)
    {
        if (rx_message[HEADER_SEQ_OFFSET] != data_seq)
        {
            txBuffer->data[0] = BL_RESP_SEQ_ERROR;
            (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
        else
        {
            for (uint8_t i = 0; i < size; i++)
            {
                if (0U == image_size)
                {
                    txBuffer->data[0] = BL_RESP_ERROR;
                    (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
                    return;
                }

                media_write_data[media_ptr] = rx_message[HEADER_SIZE + i];
                media_ptr++;

                if ((media_ptr == PAGE_SIZE) || ((image_addr + media_ptr) == unlock_end))
                {
                    if (bootloader_Storage_Write(imageStartFlag, (void *)media_write_data, media_ptr) == true)
                    {
                        txBuffer->data[0] = BL_RESP_OK;
                    }
                    else
                    {
                        txBuffer->data[0] = BL_RESP_ERROR;
                    }

                    imageStartFlag = false;
                    image_addr += media_ptr;
                    image_size -= media_ptr;
                    media_ptr = 0;
                }
                else
                {
                    txBuffer->data[0] = BL_RESP_OK;
                }
            }
            data_seq++;
            (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
    }
    else if (BL_CMD_READ_VERSION == command)
    {
        uint16_t btlVersion = bootloader_GetVersion();

        txBuffer->data[0] = BL_RESP_OK;

        txBuffer->data[1] = (uint8_t)((btlVersion >> 8) & 0xFFU);
        txBuffer->data[2] = (uint8_t)(btlVersion & 0xFFU);

        (void) ${PERIPH_USED}_MessageTransmitFifo(3U, txBuffer);
    }
    else if (BL_CMD_VERIFY == command)
    {
        if (size != CRC_SIZE)
        {
            txBuffer->data[0] = BL_RESP_ERROR;
           (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }

        if (bootloader_Storage_CRC_Verify(data[CRC_OFFSET]) == true)
        {
            txBuffer->data[0] = BL_RESP_CRC_OK;
            (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
        else
        {
            txBuffer->data[0] = BL_RESP_CRC_FAIL;
            (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        }
    }
    else if (BL_CMD_RESET == command)
    {
        if (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_TFE_MASK))
        {
            ${PERIPH_USED}_InterruptClear(${PERIPH_NAME}_INTERRUPT_TFE_MASK);
        }

        txBuffer->data[0] = BL_RESP_OK;
        (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
        while (${PERIPH_USED}_InterruptGet(${PERIPH_NAME}_INTERRUPT_TFE_MASK) == false)
        {
           /* Do Nothing */
        }

        bootloader_TriggerReset();
    }
    else
    {
        txBuffer->data[0] = BL_RESP_INVALID;
        (void) ${PERIPH_USED}_MessageTransmitFifo(1U, txBuffer);
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
                canBLActive = true;

                if (numberOfMessage > (${PERIPH_USED}_RX_FIFO0_SIZE / ${PERIPH_USED}_RX_FIFO0_ELEMENT_SIZE))
                {
                    numberOfMessage = ${PERIPH_USED}_RX_FIFO0_SIZE / ${PERIPH_USED}_RX_FIFO0_ELEMENT_SIZE;
                }

                (void) memset(rxFiFo0, 0, ((uint32_t)numberOfMessage * ${PERIPH_USED}_RX_FIFO0_ELEMENT_SIZE));

                if (${PERIPH_USED}_MessageReceiveFifo(${PERIPH_NAME}_RX_FIFO_0, numberOfMessage, (void *)rxFiFo0) == true)
                {
                    for (count = 0U; count < numberOfMessage; count++)
                    {
                        rxBuf = (${PERIPH_NAME}_RX_BUFFER *)(uintptr_t)(&rxFiFo0[count * ${PERIPH_USED}_RX_FIFO0_ELEMENT_SIZE]);
                        process_command(rxBuf->data, CANDlcToLengthGet(rxBuf->dlc));
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

void bootloader_${BTL_TYPE}_Tasks(void)
{
    if (canBLInitDone == false)
    {
        /* Set ${PERIPH_USED} Message RAM Configuration */
        ${PERIPH_USED}_MessageRAMConfigSet(${PERIPH_USED?lower_case}MessageRAM);

        canBLInitDone = true;
    }

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
                ${PERIPH_USED}_task();

            } while(canBLActive);
            break;
        }
        default:
        {
            // default
            break;
        }
    }

}
