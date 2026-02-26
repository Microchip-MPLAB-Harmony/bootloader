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

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && (DRIVER_USED == "DRV_NAND_FLASH" || DRIVER_USED == "DRV_SST26")>
#define APP_PARTITION_SIZE                      (0x100000U) /* (1024 * 1024) */

// Magic value used to validate the metadata content "BOOT"
#define METADATA_MAGIC_VALUE    0x424F4F54u

/* metadata used to identify a valid application image */
typedef struct
{
    /* magic value, should be BOOT */
    uint32_t magic;
    
    /* image size, should not exceed APP_PARTITION_SIZE*/
    uint32_t img_size;
    
    /* computed image entry point, fetched from hex record file*/
    uint32_t img_entry;
} BOOTLOADER_IMAGE_META_DATA;

typedef struct
{
    uint8_t RecDataLen;
    uint32_t Address;
    uint8_t RecType;
    uint8_t* Data;
    uint8_t CheckSum;
    uint32_t ExtSegAddress;
    uint32_t ExtLinAddress;
} T_HEX_RECORD;
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
<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true>
static uint8_t eof_processed = 0u;
</#if>

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
<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && DRIVER_USED == "DRV_NAND_FLASH">
    BOOTLOADER_IMAGE_META_DATA meta_data = {.magic = 0xFFFFFFFF, .img_size = 0xFFFFFFFF};
<#else>
    uint32_t imageSize = 0xFFFFFFFFU;
</#if>
    bool status = false;

<#if DRIVER_USED == "DRV_NAND_FLASH">
<#if OTA_BOOTLOADER_ENABLE?? && OTA_BOOTLOADER_ENABLE == true>
    (void)OTA_SERVICE_FH_CtrlBlkRead(controlBlock, ctrlBlkSize);
    imageSize = controlBlock->appImageInfo[0].imageSize;
<#else>
    blockNum = btlData.extMemoryMetaDataAddr / btlData.geometry.blockSize;
    pageNum = ((btlData.extMemoryMetaDataAddr / btlData.geometry.pageSize) % (btlData.geometry.blockSize / btlData.geometry.pageSize));

    (void)${DRIVER_USED}_SkipBlock_PageRead(btlData.handle, (uint16_t)blockNum, (uint16_t)pageNum, fileBuffer, NULL, false);

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true>
    meta_data = *((BOOTLOADER_IMAGE_META_DATA *)(uintptr_t)fileBuffer);
    if (meta_data.magic != METADATA_MAGIC_VALUE)
    {
        return;
    }
<#else>
    imageSize = *((uint32_t *)(uintptr_t)fileBuffer);
</#if>
</#if>

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true>
    if (meta_data.img_size < APP_PARTITION_SIZE)
<#else>
    if (imageSize != 0xFFFFFFFFU)
</#if>
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

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true>
        } while(readLen < meta_data.img_size);
<#else>
        } while(readLen < imageSize);
</#if>
        status = true;
    }
<#else>
<#if OTA_BOOTLOADER_ENABLE?? && OTA_BOOTLOADER_ENABLE == true>
    (void)OTA_SERVICE_FH_CtrlBlkRead(controlBlock, ctrlBlkSize);
    imageSize = controlBlock->appImageInfo[0].imageSize;
<#else>
    (void)${DRIVER_USED}_Read(btlData.handle, fileBuffer, PAGE_SIZE, btlData.extMemoryMetaDataAddr);
    (void)bootloader_WaitForXferComplete();

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && DRIVER_USED == "DRV_SST26">
    BOOTLOADER_IMAGE_META_DATA *meta = (BOOTLOADER_IMAGE_META_DATA *)fileBuffer;
    if (meta->magic == METADATA_MAGIC_VALUE)
    {
        // Proceed with image loading
        imageSize = meta->img_size;
    }
<#else>
    imageSize = *((uint32_t *)(uintptr_t)fileBuffer);
</#if>
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

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && DRIVER_USED == "DRV_NAND_FLASH">
static bool bootloader_Storage_Write(uint32_t addr, void *buffer, size_t size)
<#else>
<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && DRIVER_USED == "DRV_SST26">
static bool bootloader_Storage_Write(uint32_t memoryAddr, void *buffer, size_t size)
<#else>
bool bootloader_Storage_Write(bool imageStartFlag, void *buffer, size_t size)
</#if>
</#if>
{
<#if DRIVER_USED == "DRV_NAND_FLASH">
    uint32_t pageNum;
    uint32_t blockNum;
</#if>
    bool status = false;

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && DRIVER_USED == "DRV_NAND_FLASH">
    memoryAddr = addr;
<#else>
<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && DRIVER_USED == "DRV_SST26">
<#else>
    if (imageStartFlag)
    {
        memoryAddr = btlData.extMemoryImageAddr;
    }
</#if>
</#if>
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

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && DRIVER_USED == "DRV_NAND_FLASH">
/*
 * Erase image application partition and metadata partition
 * Should be invoked from host target only via bootloader erase command
 */
bool bootloader_Storage_Erase(void)
{
    if (btlData.geometry.blockSize == 0U) {
        return true;
    }

    const uint32_t bs = btlData.geometry.blockSize;
    bool ok = false;
    
    /* erase image application partition */
    uint32_t start = (uint32_t)btlData.extMemoryImageAddr;
    uint32_t end = start + APP_PARTITION_SIZE - 1U; // last byte in range

    uint32_t first_block = (uint32_t)(start / bs);
    uint32_t last_block  = (uint32_t)(end / bs);

    for (uint32_t blk = first_block; blk <= last_block; ++blk) {

        ok = DRV_NAND_FLASH_SkipBlock_BlockErase(btlData.handle, (uint16_t)blk, false);
        if (!ok) {
            return false;
        }
    }
    
    /* erase metadata partition, it is just one block */
    start = (uint32_t)btlData.extMemoryMetaDataAddr;
    first_block = (uint32_t)(start / bs);
    
    ok = DRV_NAND_FLASH_SkipBlock_BlockErase(btlData.handle, (uint16_t)first_block, false);
    if (!ok) {
        return false;
    }
    
    return true;
}
</#if>

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && DRIVER_USED == "DRV_SST26">
/*
 * Erase image application partition and metadata partition
 * Should be invoked from host target only via bootloader erase command
 */
bool bootloader_Storage_Erase(void)
{
    return true;
}
</#if>

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && (DRIVER_USED == "DRV_NAND_FLASH" || DRIVER_USED == "DRV_SST26")>
#include <inttypes.h> /* for PRIX32 to have a correct format to print uint32_t */

/* flush helper works in OFFSET space (relative to image_base_abs) */
static void flush_page_if_dirty(uint32_t image_base_abs,
                                uint32_t *cur_page_base_off,
                                uint8_t  *page_valid,
                                uint8_t  *page_dirty)
{
    if ((*page_valid != 0U) && (*page_dirty != 0U))
    {
        const uint32_t addr = image_base_abs + *cur_page_base_off;

        bootloader_Storage_Write(addr, fileBuffer, PAGE_SIZE);
        *page_dirty = 0u;
    }
}

/*
 * Parse hex record file sent line by line from host using bootloader program command
 * compute data offset inside nand flash page based on 16 LSB of the absolute address from hex file -
 * base address inside NAND flash memory
 * fill a page buffer till full and program a page at once
 * at the end program all data received in the page buffer
 * compute metadata and write into NAND flash
 */
HEX_RECORD_STATUS bootloader_Storage_ProgramHexRecord(uint8_t *HexBuf, size_t totalLen)
{
    /* ---- persistent state (session) ---- */
    static uint8_t  s_inited        = 0u;
    static uint32_t extLinAddr      = 0;  /* <<16 */
    static uint32_t extSegAddr      = 0;  /* <<4  */
    static uint32_t min_written_abs = 0xFFFFFFFFu;
    static uint32_t max_written_abs = 0u;
    static uint32_t entry_point     = 0u;
    static uint8_t  entry_seen      = 0u;

    /* Track current NAND page using FULL offset (no 16-bit wrap) */
    static uint32_t cur_page_base_off = 0u;  /* bytes from image_base_abs */
    static uint8_t  page_valid        = 0u;
    static uint8_t  page_dirty        = 0u;

    /* Total DATA bytes actually stored in the slot */
    static uint32_t total_size        = 0u;

    const uint32_t image_base_abs = btlData.extMemoryImageAddr;

    if (s_inited == 0U) {
        
        s_inited            = 1u;
        extLinAddr          = 0;
        extSegAddr          = 0;
        min_written_abs     = 0xFFFFFFFFu;
        max_written_abs     = 0u;
        entry_point         = 0u;
        entry_seen          = 0u;
        cur_page_base_off   = 0u;
        page_valid          = 0u;
        page_dirty          = 0u;
        total_size          = 0u;
        memset(fileBuffer, 0xFF, PAGE_SIZE);
    }

    /* Require exactly one full record per call */
    if (totalLen < 5u){
        return HEX_REC_UNKNOW_TYPE;
    }
    
    const uint8_t  reclen  = HexBuf[0];
    const uint8_t  addr_hi = HexBuf[1];
    const uint8_t  addr_lo = HexBuf[2];
    const uint8_t  rectype = HexBuf[3];
    const size_t   rec_bytes = (size_t)reclen + 5u;
    
    if (totalLen != rec_bytes) {
        return HEX_REC_UNKNOW_TYPE;
    }

    /* Verify Intel-HEX checksum */
    uint8_t sum = 0;
    for (size_t i = 0; i < rec_bytes; i++) {
        sum = (uint8_t)(sum + HexBuf[i]);
    }
    
    if (sum != 0u) {
        return HEX_REC_CRC_ERROR;
    }
    
    const uint8_t *data = &HexBuf[4];

    switch (rectype)
    {

        case DATA_RECORD:
        {
            const uint32_t offs16 = ((uint32_t)addr_hi << 8) | (uint32_t)addr_lo;
            uint32_t abs          = (extLinAddr + extSegAddr + offs16);

            size_t remaining = reclen;
            size_t idx       = 0;

            while (remaining) {
                const uint32_t seg_start_abs = abs;
                uint32_t can                 = (uint32_t)remaining;

                /* Compute NAND offset inside slot; this is what we should gate on */
                uint32_t off = (uint32_t)(seg_start_abs - image_base_abs) & 0xFFFFU;   /* unsigned wrap-safe */

                /* If below slot, skip forward until we reach slot start */
                if (seg_start_abs < image_base_abs) {
                    uint32_t skip = image_base_abs - seg_start_abs;
                    if (skip > can) { skip = can; }
                    abs       += skip;
                    idx       += skip;
                    remaining -= skip;
                    continue;
                }

                /* If at/after slot end, no more data from this line fits */
                if (off >= APP_PARTITION_SIZE) {
                    /* nothing in this or following bytes belongs to the slot */
                    break;
                }

                /* Limit so we don?t cross slot end */
                uint32_t room = APP_PARTITION_SIZE - off;
                if (can > room)
                    {can = room;}

                /* Paging in OFFSET space */
                const uint32_t page_base_off = off & ~((uint32_t)PAGE_SIZE - 1U);
                const uint32_t in_page_off = off & ((uint32_t)PAGE_SIZE - 1U);

                /* New page? ? flush previous first */
                if ((page_valid == 0U) || (page_base_off != cur_page_base_off)) {
                    
                    flush_page_if_dirty(image_base_abs, &cur_page_base_off, &page_valid, &page_dirty);
                    memset(fileBuffer, 0xFF, PAGE_SIZE);
                    cur_page_base_off = page_base_off;
                    page_valid        = 1u;
                    page_dirty        = 0u;
                }

                /* Copy that fits in this page */
                uint32_t fit = PAGE_SIZE - in_page_off;
                if (fit > can) {
                    fit = can;
                }

                memcpy(&fileBuffer[in_page_off], &data[idx], fit);
                page_dirty  = 1u;
                total_size += fit;

                if (seg_start_abs < min_written_abs) {
                    min_written_abs = seg_start_abs;
                }
                
                if ((seg_start_abs + fit) > max_written_abs) {
                    max_written_abs = (seg_start_abs + fit);
                }

                abs       += fit;
                idx       += fit;
                remaining -= fit;

                /* Full page ? flush now */
                if (in_page_off + fit == PAGE_SIZE) {
                    
                    flush_page_if_dirty(image_base_abs, &cur_page_base_off, &page_valid, &page_dirty);
                    page_valid = 0u;                 /* force reopen next fragment */
                    memset(fileBuffer, 0xFF, PAGE_SIZE);
                    
                }
            }
            break;
        } 

        /* address context handling */
        case EXT_SEG_ADRS_RECORD:
        {
            
            if (reclen != 2u) {
                return HEX_REC_UNKNOW_TYPE;
            }
            
            extSegAddr = ((((uint32_t)data[0] << 8) | 
                    (uint32_t)data[1]) << 4);
            extLinAddr = 0;
            break;
        } 

        case EXT_LIN_ADRS_RECORD:
        {
            
            if (reclen != 2u) {
                return HEX_REC_UNKNOW_TYPE;
            }
            
            extLinAddr = ((((uint32_t)data[0] << 8) | 
                    (uint32_t)data[1]) << 16);
            extSegAddr = 0;
            break;
        } 

        case START_LIN_ADRS_RECORD:
        { /* Start Linear Address */
            
            if (reclen != 4u) {
                return HEX_REC_UNKNOW_TYPE;
            }
            
            entry_point = ((uint32_t)data[0] << 24) |
                          ((uint32_t)data[1] << 16) |
                          ((uint32_t)data[2] << 8)  |
                           (uint32_t)data[3];
            entry_seen = 1u;
            break;
        }

        /* end of the file - write all accumulated so far in the page buffer
         * compute metadata and write it at requested offset into NAND flash
         * reset for next session, just in case, not recommended anyway
         */
        case END_OF_FILE_RECORD:
        {
            if (eof_processed == 0U) {
                /* Flush trailing partial page */
                flush_page_if_dirty(image_base_abs, &cur_page_base_off, 
                        &page_valid, &page_dirty);

                if (min_written_abs == 0xFFFFFFFFu) {

                    min_written_abs = image_base_abs;
                    max_written_abs = image_base_abs;

                }

                if (entry_seen == 0U) {
                    entry_point = min_written_abs;
                }

                BOOTLOADER_IMAGE_META_DATA meta;
                meta.magic     = METADATA_MAGIC_VALUE;
                meta.img_size  = total_size;    /* bytes actually stored */
                meta.img_entry = entry_point;

                memset(fileBuffer, 0xFF, PAGE_SIZE);
                (void)memcpy(fileBuffer, &meta, sizeof(meta));

                bootloader_Storage_Write(btlData.extMemoryMetaDataAddr, fileBuffer, PAGE_SIZE);

                /* reset for next session */
                s_inited = 0u;
                eof_processed = 1u;
                return HEX_REC_NORMAL;
            }
            else{
                // Ignore subsequent EOF records
                return HEX_REC_NORMAL;
            }
        }

        default:
            return HEX_REC_UNKNOW_TYPE;
    }

    return HEX_REC_NORMAL;
}
</#if>

