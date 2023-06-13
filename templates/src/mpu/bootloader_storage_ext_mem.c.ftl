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

static uint8_t CACHE_ALIGN fileBuffer[PAGE_SIZE];
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
    blockNum = btlData.extMemoryMetaDataAddr / btlData.geometry.blockSize;
    pageNum = ((btlData.extMemoryMetaDataAddr / btlData.geometry.pageSize) % (btlData.geometry.blockSize / btlData.geometry.pageSize));

    ${DRIVER_USED}_SkipBlock_PageRead(btlData.handle, blockNum, pageNum, fileBuffer, 0, false);

    imageSize = *((uint32_t *)fileBuffer);

    if (imageSize != 0xFFFFFFFFU)
    {
        blockNum = btlData.extMemoryImageAddr / btlData.geometry.blockSize;
        pageNum = ((btlData.extMemoryImageAddr / btlData.geometry.pageSize) % (btlData.geometry.blockSize / btlData.geometry.pageSize));

        do
        {
            status = ${DRIVER_USED}_SkipBlock_PageRead(btlData.handle, blockNum, pageNum, fileBuffer, 0, false);

            memcpy((void *)btlData.progAddr, fileBuffer, btlData.geometry.pageSize);

            btlData.progAddr += btlData.geometry.pageSize;
            readLen += btlData.geometry.pageSize;
            pageNum++;

            if (pageNum >= (btlData.geometry.blockSize / btlData.geometry.pageSize))
            {
                blockNum++;
                pageNum = 0;
            }

        } while(readLen < imageSize);
    }
<#else>
    (void)${DRIVER_USED}_Read(btlData.handle, fileBuffer, PAGE_SIZE, btlData.extMemoryMetaDataAddr);
    (void)bootloader_WaitForXferComplete();

    imageSize = *((uint32_t *)fileBuffer);

    if (imageSize != 0xFFFFFFFFU)
    {
        memoryAddr = btlData.extMemoryImageAddr;

        do
        {
            status = ${DRIVER_USED}_Read(btlData.handle, fileBuffer, PAGE_SIZE, memoryAddr);
            (void)bootloader_WaitForXferComplete();
            memcpy((void *)btlData.progAddr, fileBuffer, PAGE_SIZE);

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
        ${DRIVER_USED}_SkipBlock_BlockErase(btlData.handle, blockNum, false);
    }

    status = ${DRIVER_USED}_SkipBlock_PageWrite(btlData.handle, blockNum, pageNum, buffer, 0, false);

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
        ${DRIVER_USED}_SkipBlock_PageRead(btlData.handle, blockNum, pageNum, fileBuffer, 0, false);

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

            memcpy(fileBuffer, (uint8_t *)&btlData.extMemoryImageSize, sizeof(btlData.extMemoryImageSize));

            if ((btlData.extMemoryMetaDataAddr % btlData.geometry.blockSize) == 0U)
            {
                ${DRIVER_USED}_SkipBlock_BlockErase(btlData.handle, blockNum, false);
            }
            ${DRIVER_USED}_SkipBlock_PageWrite(btlData.handle, blockNum, pageNum, fileBuffer, 0, false);
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

            memcpy(fileBuffer, (uint8_t *)&btlData.extMemoryImageSize, sizeof(btlData.extMemoryImageSize));

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
