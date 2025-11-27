/*******************************************************************************
  Company:
    Microchip Technology Inc.

  File Name:
    bootloader_storage.c

  Summary:
    Storage for the Bootloader library.

  Description:
    This file contains the Storage definition for the Bootloader library.
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

#include <string.h>
#include "configuration.h"
#include "bootloader/bootloader_${BTL_TYPE?lower_case}.h"
#include "bootloader_storage.h"
<#if OTA_BOOTLOADER_ENABLE?? && OTA_BOOTLOADER_ENABLE == true>
#include "ota_service_control_block.h"

#define BUFFER_SIZE(x, y)                ((y) > (x)? ((((y) % (x)) != 0U)?((((y) / (x)) + 1U) * (x)) : (((y) / (x)) * (x))) : (x))
#define OTA_CONTROL_BLOCK_SIZE           sizeof(OTA_CONTROL_BLOCK)
#define OTA_CONTROL_BLOCK_PAGE_SIZE      ${DRIVER_USED}_PAGE_SIZE
#define OTA_CONTROL_BLOCK_BUFFER_SIZE    BUFFER_SIZE(OTA_CONTROL_BLOCK_PAGE_SIZE, OTA_CONTROL_BLOCK_SIZE)

static uint32_t ctrlBlkSize = OTA_CONTROL_BLOCK_BUFFER_SIZE;
<#if DRIVER_USED == "DRV_NAND_FLASH">
#define OTA_CTRL_SPARE_SIZE    224U
static uint8_t CACHE_ALIGN controlBlockBuffer[OTA_CONTROL_BLOCK_BUFFER_SIZE + OTA_CTRL_SPARE_SIZE];
<#else>
static uint8_t CACHE_ALIGN controlBlockBuffer[OTA_CONTROL_BLOCK_BUFFER_SIZE];
</#if>
static OTA_CONTROL_BLOCK *controlBlock = (OTA_CONTROL_BLOCK *)controlBlockBuffer;
</#if>

<#if DRIVER_USED != "DRV_NAND_FLASH">
typedef enum
{
    /* Transfer being processed */
    BTL_MEM_TRANSFER_BUSY,

    /* Transfer is successfully completed */
    BTL_MEM_TRANSFER_COMPLETED,

    /* Transfer had error*/
    BTL_MEM_TRANSFER_ERROR_UNKNOWN

} BTL_MEM_TRANSFER_STATUS;
</#if>

typedef struct
{
    bool deviceReady;

    DRV_HANDLE handle;

    /* External Memory image address */
    uint32_t extMemoryImageAddr;

    /* External Memory image size */
    uint32_t extMemoryImageSize;

    /* External Memory metadata address */
    uint32_t extMemoryMetaDataAddr;

    ${DRIVER_USED}_GEOMETRY geometry;

    /* Programming address */
    uint32_t progAddr;

} BOOTLOADER_DATA;

<#if DRIVER_USED == "DRV_NAND_FLASH">
#define SPARE_SIZE    224U
static uint8_t CACHE_ALIGN fileBuffer[PAGE_SIZE + SPARE_SIZE];
<#else>
static uint8_t CACHE_ALIGN fileBuffer[PAGE_SIZE];
</#if>
static uint32_t memoryAddr;

static BOOTLOADER_DATA btlData =
{
    .deviceReady = false,
    .extMemoryImageAddr  = ${BTL_EXT_MEM_IMG_ADDR}U,
    .extMemoryMetaDataAddr = ${BTL_EXT_MEM_METADATA_ADDR}U,
    .progAddr       = APP_START_ADDRESS,
};

<#if DRIVER_USED != "DRV_NAND_FLASH">
static bool bootloader_WaitForXferComplete(void)
{
    bool status = false;

    BTL_MEM_TRANSFER_STATUS transferStatus = BTL_MEM_TRANSFER_ERROR_UNKNOWN;

    do
    {
        transferStatus = (BTL_MEM_TRANSFER_STATUS)${DRIVER_USED}_TransferStatusGet(btlData.handle);

    } while (transferStatus == BTL_MEM_TRANSFER_BUSY);

    if(transferStatus == BTL_MEM_TRANSFER_COMPLETED)
    {
        status = true;
    }

    return status;
}
</#if>

bool bootloader_IsDeviceReady(void)
{
    btlData.deviceReady = false;

    if (${DRIVER_USED}_Status(${DRIVER_USED}_INDEX) == SYS_STATUS_READY)
    {
        btlData.handle = ${DRIVER_USED}_Open((SYS_MODULE_INDEX)${DRIVER_USED}_INDEX, DRV_IO_INTENT_READWRITE);

        if (btlData.handle != DRV_HANDLE_INVALID)
        {
            if (${DRIVER_USED}_GeometryGet(btlData.handle, (void *)&btlData.geometry) == true)
            {
                btlData.deviceReady = true;
            }
        }
    }
    return btlData.deviceReady;
}

void bootloader_ImageSizeSet(uint32_t size)
{
    btlData.extMemoryImageSize = size;
}

<#if OTA_BOOTLOADER_ENABLE?? && OTA_BOOTLOADER_ENABLE == true>
bool OTA_SERVICE_FH_CtrlBlkRead(OTA_CONTROL_BLOCK *controlBlock, uint32_t length)
{
    uint32_t count;
<#if DRIVER_USED == "DRV_NAND_FLASH">
    uint32_t pageNum;
    uint32_t blockNum;
</#if>
    uint32_t appMetaDataAddress;
    bool     status = false;
    uint8_t  *ptrBuffer = (uint8_t *)controlBlock;

    if ((ptrBuffer != NULL) && (length == ctrlBlkSize))
    {
        appMetaDataAddress  = btlData.extMemoryMetaDataAddr;

        for (count = 0U; count < length; count += OTA_CONTROL_BLOCK_PAGE_SIZE)
        {
<#if DRIVER_USED == "DRV_NAND_FLASH">
            blockNum = appMetaDataAddress / btlData.geometry.blockSize;
            pageNum = ((appMetaDataAddress / btlData.geometry.pageSize) % (btlData.geometry.blockSize / btlData.geometry.pageSize));

            if (${DRIVER_USED}_SkipBlock_PageRead(btlData.handle, (uint16_t)blockNum, (uint16_t)pageNum, ptrBuffer, NULL, false) != true)
            {
                status = false;
                break;
            }

            status = true;
<#else>
            if (${DRIVER_USED}_Read(btlData.handle, ptrBuffer, OTA_CONTROL_BLOCK_PAGE_SIZE, appMetaDataAddress) != true)
            {
                status = false;
                break;
            }

            (void)bootloader_WaitForXferComplete();
            status = true;
</#if>
            appMetaDataAddress += OTA_CONTROL_BLOCK_PAGE_SIZE;
            ptrBuffer += OTA_CONTROL_BLOCK_PAGE_SIZE;
        }
    }

    return status;
}
</#if>

void bootloader_Storage_Read(void)
{
<#if DRIVER_USED == "DRV_NAND_FLASH">
    uint32_t pageNum;
    uint32_t blockNum;
</#if>
    uint32_t readLen = 0U;
    uint32_t imageSize;
    bool status = false;

<#if DRIVER_USED == "DRV_NAND_FLASH">
<#if OTA_BOOTLOADER_ENABLE?? && OTA_BOOTLOADER_ENABLE == true>
    (void)OTA_SERVICE_FH_CtrlBlkRead(controlBlock, ctrlBlkSize);
    imageSize = controlBlock->appImageInfo[0].imageSize;
<#else>
    blockNum = btlData.extMemoryMetaDataAddr / btlData.geometry.blockSize;
    pageNum = ((btlData.extMemoryMetaDataAddr / btlData.geometry.pageSize) % (btlData.geometry.blockSize / btlData.geometry.pageSize));

    (void)${DRIVER_USED}_SkipBlock_PageRead(btlData.handle, (uint16_t)blockNum, (uint16_t)pageNum, fileBuffer, NULL, false);

    imageSize = *((uint32_t *)(uintptr_t)fileBuffer);
</#if>

    if (imageSize != 0xFFFFFFFFU)
    {
        blockNum = btlData.extMemoryImageAddr / btlData.geometry.blockSize;
        pageNum = ((btlData.extMemoryImageAddr / btlData.geometry.pageSize) % (btlData.geometry.blockSize / btlData.geometry.pageSize));

        do
        {
            (void)${DRIVER_USED}_SkipBlock_PageRead(btlData.handle, (uint16_t)blockNum, (uint16_t)pageNum, fileBuffer, NULL, false);

            (void)memcpy((uint8_t *)btlData.progAddr, fileBuffer, btlData.geometry.pageSize);

            btlData.progAddr += btlData.geometry.pageSize;
            readLen += btlData.geometry.pageSize;
            pageNum++;

            if (pageNum >= (btlData.geometry.blockSize / btlData.geometry.pageSize))
            {
                blockNum++;
                pageNum = 0;
            }

        } while(readLen < imageSize);
        status = true;
    }
<#else>
<#if OTA_BOOTLOADER_ENABLE?? && OTA_BOOTLOADER_ENABLE == true>
    (void)OTA_SERVICE_FH_CtrlBlkRead(controlBlock, ctrlBlkSize);
    imageSize = controlBlock->appImageInfo[0].imageSize;
<#else>
    (void)${DRIVER_USED}_Read(btlData.handle, fileBuffer, PAGE_SIZE, btlData.extMemoryMetaDataAddr);
    (void)bootloader_WaitForXferComplete();

    imageSize = *((uint32_t *)(uintptr_t)fileBuffer);
</#if>

    if (imageSize != 0xFFFFFFFFU)
    {
        memoryAddr = btlData.extMemoryImageAddr;

        do
        {
            status = ${DRIVER_USED}_Read(btlData.handle, fileBuffer, PAGE_SIZE, memoryAddr);
            (void)bootloader_WaitForXferComplete();
            (void)memcpy((uint8_t *)btlData.progAddr, fileBuffer, PAGE_SIZE);

            btlData.progAddr += PAGE_SIZE;
            readLen += PAGE_SIZE;
            memoryAddr += PAGE_SIZE;

        } while(readLen < imageSize);
    }
</#if>
    if (status == true)
    {
        run_Application(APP_START_ADDRESS);
    }
}

bool bootloader_Storage_Write(bool imageStartFlag, void *buffer, size_t size)
{
<#if DRIVER_USED == "DRV_NAND_FLASH">
    uint32_t pageNum;
    uint32_t blockNum;
</#if>
    bool status = false;

    if (imageStartFlag)
    {
        memoryAddr = btlData.extMemoryImageAddr;
    }

<#if DRIVER_USED == "DRV_NAND_FLASH">
    blockNum = memoryAddr / btlData.geometry.blockSize;

    pageNum = ((memoryAddr / btlData.geometry.pageSize) % (btlData.geometry.blockSize / btlData.geometry.pageSize));

    if ((memoryAddr % btlData.geometry.blockSize) == 0U)
    {
        (void)${DRIVER_USED}_SkipBlock_BlockErase(btlData.handle, (uint16_t)blockNum, false);
    }

    status = ${DRIVER_USED}_SkipBlock_PageWrite(btlData.handle, (uint16_t)blockNum, (uint16_t)pageNum, buffer, NULL, false);

    memoryAddr += btlData.geometry.pageSize;
<#else>
    if ((memoryAddr % btlData.geometry.erase_blockSize) == 0U)
    {
        if (${DRIVER_USED}_SectorErase(btlData.handle, memoryAddr) == true)
        {
            (void)bootloader_WaitForXferComplete();
        }
    }

    status = ${DRIVER_USED}_PageWrite(btlData.handle, buffer, memoryAddr);
    if (status == true)
    {
        (void)bootloader_WaitForXferComplete();
    }

    memoryAddr += PAGE_SIZE;
</#if>

    return status;
}

bool bootloader_Storage_CRC_Verify(uint32_t crc)
{
<#if DRIVER_USED == "DRV_NAND_FLASH">
    uint32_t pageNum;
    uint32_t blockNum;
</#if>
    uint32_t readLen = 0U;
    uint32_t imageBufferSize;
    uint32_t imageSize;
    uint32_t crcGenerate = 0xFFFFFFFFU;
    bool status = false;

<#if DRIVER_USED == "DRV_NAND_FLASH">
    blockNum = btlData.extMemoryImageAddr / btlData.geometry.blockSize;
    pageNum = ((btlData.extMemoryImageAddr / btlData.geometry.pageSize) % (btlData.geometry.blockSize / btlData.geometry.pageSize));

    imageSize = btlData.extMemoryImageSize;
    do
    {
        (void)${DRIVER_USED}_SkipBlock_PageRead(btlData.handle, (uint16_t)blockNum, (uint16_t)pageNum, fileBuffer, NULL, false);

        if (imageSize >= btlData.geometry.pageSize)
        {
            imageBufferSize = btlData.geometry.pageSize;
        }
        else
        {
            imageBufferSize = imageSize;
        }
        crcGenerate = bootloader_CRCGenerate(fileBuffer, imageBufferSize, crcGenerate);

        readLen += btlData.geometry.pageSize;
        pageNum++;
        imageSize -= imageBufferSize;

        if ((imageSize == 0U) && (crc == crcGenerate))
        {
            status = true;
            blockNum = btlData.extMemoryMetaDataAddr / btlData.geometry.blockSize;
            pageNum = ((btlData.extMemoryMetaDataAddr / btlData.geometry.pageSize) % (btlData.geometry.blockSize / btlData.geometry.pageSize));

            (void)memcpy(fileBuffer, (uint8_t *)&btlData.extMemoryImageSize, sizeof(btlData.extMemoryImageSize));

            if ((btlData.extMemoryMetaDataAddr % btlData.geometry.blockSize) == 0U)
            {
                (void)${DRIVER_USED}_SkipBlock_BlockErase(btlData.handle, (uint16_t)blockNum, false);
            }
            (void)${DRIVER_USED}_SkipBlock_PageWrite(btlData.handle, (uint16_t)blockNum, (uint16_t)pageNum, fileBuffer, NULL, false);
            break;
        }

        if (pageNum >= (btlData.geometry.blockSize / btlData.geometry.pageSize))
        {
            blockNum++;
            pageNum = 0;
        }

    } while(readLen < btlData.extMemoryImageSize);
<#else>
    memoryAddr = btlData.extMemoryImageAddr;

    imageSize = btlData.extMemoryImageSize;
    do
    {
        (void)${DRIVER_USED}_Read(btlData.handle, fileBuffer, PAGE_SIZE, memoryAddr);
        (void)bootloader_WaitForXferComplete();

        if (imageSize >= PAGE_SIZE)
        {
            imageBufferSize = PAGE_SIZE;
        }
        else
        {
            imageBufferSize = imageSize;
        }
        crcGenerate = bootloader_CRCGenerate(fileBuffer, imageBufferSize, crcGenerate);

        readLen += PAGE_SIZE;
        memoryAddr += PAGE_SIZE;
        imageSize -= imageBufferSize;

        if ((imageSize == 0U) && (crc == crcGenerate))
        {
            status = true;
            memoryAddr = btlData.extMemoryMetaDataAddr;

            (void)memcpy(fileBuffer, (uint8_t *)&btlData.extMemoryImageSize, sizeof(btlData.extMemoryImageSize));

            if ((memoryAddr % btlData.geometry.erase_blockSize) == 0U)
            {
                if (${DRIVER_USED}_SectorErase(btlData.handle, memoryAddr) == true)
                {
                    (void)bootloader_WaitForXferComplete();
                }
            }

            (void)${DRIVER_USED}_PageWrite(btlData.handle, fileBuffer, memoryAddr);
            (void)bootloader_WaitForXferComplete();
            break;
        }
    } while(readLen < btlData.extMemoryImageSize);
</#if>

    return status;
}
