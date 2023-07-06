/*******************************************************************************
  OTA Bootloader Source File

  File Name:
    bootloader_ota.c

  Summary:
    This file contains source code necessary to execute OTA bootloader.

  Description:
    This file contains source code necessary to execute OTA bootloader.
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

#include "ota_service_control_block.h"
<#if HarmonyCore??>
    <#if HarmonyCore.ENABLE_DRV_COMMON == true ||
         HarmonyCore.ENABLE_SYS_COMMON == true ||
         HarmonyCore.ENABLE_APP_FILE == true >
        <#lt>#include "configuration.h"
    </#if>
</#if>
#include "definitions.h"

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

#define DATA_SIZE                        PAGE_SIZE
#define BUFFER_SIZE(x, y)                ((y) > (x)? ((((y) % (x)) != 0U)?((((y) / (x)) + 1U) * (x)) : (((y) / (x)) * (x))) : (x))
#define OTA_CONTROL_BLOCK_SIZE           sizeof(OTA_CONTROL_BLOCK)

<#if DRIVER_USED == NVM_MEM_USED>
#define OTA_CONTROL_BLOCK_PAGE_SIZE      PAGE_SIZE
<#else>
  <#if .vars["${DRIVER_USED?lower_case}"].EEPROM_PAGE_SIZE??>
    <#lt>#define OTA_CONTROL_BLOCK_PAGE_SIZE      ${DRIVER_USED}_EEPROM_PAGE_SIZE
  <#else>
    <#lt>#define OTA_CONTROL_BLOCK_PAGE_SIZE      ${DRIVER_USED}_PAGE_SIZE
  </#if>
</#if>

#define OTA_CONTROL_BLOCK_BUFFER_SIZE    BUFFER_SIZE(OTA_CONTROL_BLOCK_PAGE_SIZE, OTA_CONTROL_BLOCK_SIZE)

<#if DRIVER_USED != NVM_MEM_USED>
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

typedef enum
{
    BTL_STATE_INIT = 0,

    BTL_STATE_GET_METADATA,

    BTL_STATE_CHECK_META_DATA_UPDATE,

    BTL_STATE_READ_APP_IMAGE,

    BTL_STATE_PROGRAM_FLASH,

    BTL_STATE_VERIFY_SIGNATURE,

    BTL_STATE_UPDATE_META_DATA,

    BTL_STATE_RUN_APPLICATION,

    BTL_STATE_ERROR

} BTL_STATES;

<#if DRIVER_USED != NVM_MEM_USED>
typedef struct
{
    uint32_t read_blockSize;
    uint32_t read_numBlocks;
    uint32_t numReadRegions;

    uint32_t write_blockSize;
    uint32_t write_numBlocks;
    uint32_t numWriteRegions;

    uint32_t erase_blockSize;
    uint32_t erase_numBlocks;
    uint32_t numEraseRegions;

    uint32_t blockStartAddress;
} BTL_MEM_GEOMETRY;
</#if>

typedef struct
{
    BTL_STATES state;

<#if DRIVER_USED != NVM_MEM_USED>
    uintptr_t handle;

    BTL_MEM_GEOMETRY geometry;

    uint32_t read_index;

    uint32_t write_index;

</#if>
    uint32_t appJumpAddress;

    OTA_CONTROL_BLOCK *controlBlock;
} BTL_DATA;

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

static uint8_t CACHE_ALIGN controlBlockBuffer[OTA_CONTROL_BLOCK_BUFFER_SIZE];
<#if DRIVER_USED != NVM_MEM_USED>
static uint8_t CACHE_ALIGN flash_data[DATA_SIZE];
</#if>
static uint32_t ctrlBlkSize = OTA_CONTROL_BLOCK_BUFFER_SIZE;

static BTL_DATA btlData =
{
    .state              = BTL_STATE_INIT,
<#if __PROCESSOR?matches("PIC32M.*") == false>
    .appJumpAddress     = APP_START_ADDRESS,
<#else>
    .appJumpAddress     = APP_JUMP_ADDRESS,
</#if>
    .controlBlock       = (OTA_CONTROL_BLOCK *)controlBlockBuffer,
};

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Local Functions
// *****************************************************************************
// *****************************************************************************

<#if DRIVER_USED != NVM_MEM_USED>
static bool bootloader_${BTL_TYPE}_WaitForXferComplete(void)
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

static void bootloader_${BTL_TYPE}_FlashWrite(void *data, uint32_t address)
{
    uint32_t *buffer = (uint32_t *)data;

    if (0U == (address % ERASE_BLOCK_SIZE))
    {
<#if core.CoreArchitecture != "MIPS">
        // Lock region size is always bigger than the row size
        ${MEM_USED}_RegionUnlock(address);

        while(${MEM_USED}_IsBusy() == true)
        {

        }
</#if>

        /* Erase the Current sector */
        (void)${.vars["${MEM_USED?lower_case}"].ERASE_API_NAME}(address);

        while(${MEM_USED}_IsBusy() == true)
        {

        }
    }

    (void)${.vars["${MEM_USED?lower_case}"].WRITE_API_NAME}(buffer, address);

    while(${MEM_USED}_IsBusy() == true)
    {

    }
}
</#if>

static bool bootloader_${BTL_TYPE}_CtrlBlkRead(OTA_CONTROL_BLOCK *controlBlock, uint32_t length)
{
<#if DRIVER_USED != NVM_MEM_USED>
    uint32_t count;
    uint32_t blockSize;
    uint32_t otaMemoryStart;
    uint32_t otaMemorySize;
</#if>
    uint32_t appMetaDataAddress;
    bool     status = false;
    uint8_t  *ptrBuffer = (uint8_t *)controlBlock;

    if ((ptrBuffer != NULL) && (length == ctrlBlkSize))
    {
<#if DRIVER_USED != NVM_MEM_USED>
        otaMemoryStart    = btlData.geometry.blockStartAddress;

        otaMemorySize     = (btlData.geometry.read_blockSize * btlData.geometry.read_numBlocks);

<#if OTA_MEM_ERASE_ENABLE?? && OTA_MEM_ERASE_ENABLE == true>
        blockSize = btlData.geometry.erase_blockSize;
<#else>
        blockSize = btlData.geometry.write_blockSize;
</#if>

        appMetaDataAddress  = ((otaMemoryStart + otaMemorySize) - BUFFER_SIZE(blockSize, ctrlBlkSize));

        for (count = 0; count < length; count += OTA_CONTROL_BLOCK_PAGE_SIZE)
        {
            if (${DRIVER_USED}_Read(btlData.handle, ptrBuffer, OTA_CONTROL_BLOCK_PAGE_SIZE, appMetaDataAddress) != true)
            {
                status = false;
                break;
            }

            status = bootloader_${BTL_TYPE}_WaitForXferComplete();
            appMetaDataAddress += OTA_CONTROL_BLOCK_PAGE_SIZE;
            ptrBuffer += OTA_CONTROL_BLOCK_PAGE_SIZE;
        }
<#else>
        appMetaDataAddress  = (FLASH_END_ADDRESS - ctrlBlkSize);
        (void)${MEM_USED}_Read((void *)ptrBuffer, ctrlBlkSize, appMetaDataAddress);
        status = true;
</#if>
    }

    return status;
}

static bool bootloader_${BTL_TYPE}_CtrlBlkWrite(OTA_CONTROL_BLOCK *controlBlock, uint32_t length)
{
    uint32_t count;
<#if DRIVER_USED != NVM_MEM_USED>
    uint32_t blockSize;
    uint32_t otaMemoryStart;
    uint32_t otaMemorySize;
</#if>
    uint32_t appMetaDataAddress;
    bool     status = false;
    uint8_t  *ptrBuffer = (uint8_t *)controlBlock;

    if ((ptrBuffer != NULL) && (length == ctrlBlkSize))
    {
<#if DRIVER_USED != NVM_MEM_USED>
        otaMemoryStart    = btlData.geometry.blockStartAddress;

        otaMemorySize     = (btlData.geometry.read_blockSize * btlData.geometry.read_numBlocks);

<#if OTA_MEM_ERASE_ENABLE?? && OTA_MEM_ERASE_ENABLE == true>
        blockSize = btlData.geometry.erase_blockSize;
<#else>
        blockSize = btlData.geometry.write_blockSize;
</#if>

        appMetaDataAddress  = ((otaMemoryStart + otaMemorySize) - BUFFER_SIZE(blockSize, ctrlBlkSize));

<#if OTA_MEM_ERASE_ENABLE?? && OTA_MEM_ERASE_ENABLE == true>
        (void)${DRIVER_USED}_SectorErase(btlData.handle, appMetaDataAddress);

        status = bootloader_${BTL_TYPE}_WaitForXferComplete();
</#if>

        for (count = 0; count < length; count += OTA_CONTROL_BLOCK_PAGE_SIZE)
        {
            if (${DRIVER_USED}_PageWrite(btlData.handle, ptrBuffer, appMetaDataAddress) != true)
            {
                status = false;
                break;
            }

            status = bootloader_${BTL_TYPE}_WaitForXferComplete();
            appMetaDataAddress += OTA_CONTROL_BLOCK_PAGE_SIZE;
            ptrBuffer += OTA_CONTROL_BLOCK_PAGE_SIZE;
        }
<#else>
        appMetaDataAddress  = (FLASH_END_ADDRESS - ctrlBlkSize);

        <#if core.CoreArchitecture != "MIPS">
        // Lock region size is always bigger than the row size
        ${MEM_USED}_RegionUnlock(appMetaDataAddress);

        while(${MEM_USED}_IsBusy() == true)
        {

        }
        </#if>

        /* Erase the Current sector */
        (void)${.vars["${MEM_USED?lower_case}"].ERASE_API_NAME}(appMetaDataAddress);

        while(${MEM_USED}_IsBusy() == true)
        {

        }

        for (count = 0; count < length; count += OTA_CONTROL_BLOCK_PAGE_SIZE)
        {
            (void)${.vars["${MEM_USED?lower_case}"].WRITE_API_NAME}((void *)ptrBuffer, appMetaDataAddress);

            while(${MEM_USED}_IsBusy() == true)
            {

            }
            appMetaDataAddress += OTA_CONTROL_BLOCK_PAGE_SIZE;
            ptrBuffer += OTA_CONTROL_BLOCK_PAGE_SIZE;
        }

        status = true;
</#if>
    }

    return status;
}

<#if (core.CoreArchitecture == "MIPS") && (DRIVER_USED == NVM_MEM_USED)>
static void bootloader_${BTL_TYPE}_ProgramFlashSwapBank(T_FLASH_BANK flash_bank)
{
    /* NVMOP can be written only when WREN is zero. So, clear WREN */
    NVMCONCLR = _NVMCON_WREN_MASK;

    /* Write the unlock key sequence */
    NVMKEY = 0x0U;
    NVMKEY = 0xAA996655U;
    NVMKEY = 0x556699AAU;

    if (flash_bank == PROGRAM_FLASH_BANK_1)
    {
        /* Map Program Flash Memory Bank 1 to lower region */
        NVMCONCLR = _NVMCON_PFSWAP_MASK;
    }
    else if (flash_bank == PROGRAM_FLASH_BANK_2)
    {
        /* Map Program Flash Memory Bank 2 to lower region */
        NVMCONSET = _NVMCON_PFSWAP_MASK;
    }
    else
    {
        /* Do nothing */
    }
}

static uint32_t bootloader_${BTL_TYPE}_FlashSerialGet(T_FLASH_BANK flash_bank)
{
    uint32_t serialNum;
    uint32_t *ptrSerialNum;

    if (flash_bank == PROGRAM_FLASH_BANK_1)
    {
        ptrSerialNum = (uint32_t *)KVA0_TO_KVA1((INACTIVE_BANK_START - ctrlBlkSize));
    }
    else
    {
        ptrSerialNum = (uint32_t *)KVA0_TO_KVA1((FLASH_END_ADDRESS - ctrlBlkSize));
    }
    serialNum = *ptrSerialNum;

    if (serialNum == 0xFFFFFFFFU)
    {
        serialNum = 0U;
    }

    return serialNum;
}
</#if>

static bool bootloader_${BTL_TYPE}_CheckForUpdate(OTA_CONTROL_BLOCK *controlBlock)
{
    bool status = false;

<#if DRIVER_USED != NVM_MEM_USED>
    if ((controlBlock->versionNum != 0xFU) && (controlBlock->ActiveImageNum < ${NUM_OF_APP_IMAGE}U))
<#else>
    if ((controlBlock->versionNum != 0xFU) && (controlBlock->ActiveImageNum < 1U))
</#if>
    {
        if (controlBlock->appImageInfo[controlBlock->ActiveImageNum].status == OTA_CB_STATUS_VALID)
        {
            btlData.appJumpAddress  = controlBlock->appImageInfo[controlBlock->ActiveImageNum].jumpAddress;
        }

        if (controlBlock->blockUpdated == 1U)
        {
            status = true;
        }
<#if (core.CoreArchitecture == "MIPS") && (DRIVER_USED == NVM_MEM_USED)>
        else
        {
            uint32_t serialNum1;
            uint32_t serialNum2;

            /* Map Program Flash Bank 1 to lower region after a reset */
            bootloader_${BTL_TYPE}_ProgramFlashSwapBank(PROGRAM_FLASH_BANK_1);

            serialNum1 = bootloader_${BTL_TYPE}_FlashSerialGet(PROGRAM_FLASH_BANK_1);
            serialNum2 = bootloader_${BTL_TYPE}_FlashSerialGet(PROGRAM_FLASH_BANK_2);

            if (serialNum2 > serialNum1)
            {
                /* Map Program Flash Bank 2 to lower region */
                bootloader_${BTL_TYPE}_ProgramFlashSwapBank(PROGRAM_FLASH_BANK_2);
            }
        }
</#if>
    }

    return status;
}

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Global Functions
// *****************************************************************************
// *****************************************************************************

void bootloader_${BTL_TYPE}_Tasks (void)
{
    /* Check the application's current state. */
    switch (btlData.state)
    {
        case BTL_STATE_INIT:
        {
<#if DRIVER_USED != NVM_MEM_USED>
            if (${DRIVER_USED}_Status(${DRIVER_USED}_INDEX) == SYS_STATUS_READY)
            {
                btlData.handle = ${DRIVER_USED}_Open(${DRIVER_USED}_INDEX, DRV_IO_INTENT_READWRITE);

                if (btlData.handle != DRV_HANDLE_INVALID)
                {
                    if (${DRIVER_USED}_GeometryGet(btlData.handle, (void *)&btlData.geometry) != true)
                    {
                        btlData.state = BTL_STATE_ERROR;
                        break;
                    }
                    btlData.state = BTL_STATE_GET_METADATA;
                }
            }
<#else>
            btlData.state = BTL_STATE_GET_METADATA;
</#if>
            break;
        }

        case BTL_STATE_GET_METADATA:
        {
            if (bootloader_${BTL_TYPE}_CtrlBlkRead(btlData.controlBlock, ctrlBlkSize) == true)
            {
                btlData.state = BTL_STATE_CHECK_META_DATA_UPDATE;
            }
            else
            {
                btlData.state = BTL_STATE_RUN_APPLICATION;
            }

            break;
        }

        case BTL_STATE_CHECK_META_DATA_UPDATE:
        {
            if (bootloader_${BTL_TYPE}_CheckForUpdate(btlData.controlBlock) == true)
            {
<#if DRIVER_USED != NVM_MEM_USED>
                btlData.state = BTL_STATE_READ_APP_IMAGE;
<#else>
                btlData.state = BTL_STATE_UPDATE_META_DATA;
</#if>
            }
            else
            {
                if (bootloader_Trigger() == true)
                {
                    btlData.state = BTL_STATE_GET_METADATA;
                }
                else
                {
                    btlData.state = BTL_STATE_RUN_APPLICATION;
                }
            }

            break;
        }

<#if DRIVER_USED != NVM_MEM_USED>
        case BTL_STATE_READ_APP_IMAGE:
        {
            (void)memset((void *)flash_data, 0xFF, DATA_SIZE);

            if (${DRIVER_USED}_Read(btlData.handle, &flash_data[0], DATA_SIZE, (btlData.controlBlock->appImageInfo[btlData.controlBlock->ActiveImageNum].loadAddress + btlData.read_index)) == false)
            {
                btlData.state = BTL_STATE_ERROR;
                break;
            }

            if (bootloader_${BTL_TYPE}_WaitForXferComplete() == true)
            {
                btlData.state = BTL_STATE_PROGRAM_FLASH;
            }
            else
            {
                btlData.state = BTL_STATE_ERROR;
            }

            break;
        }

        case BTL_STATE_PROGRAM_FLASH:
        {
            bootloader_${BTL_TYPE}_FlashWrite(&flash_data[0], (btlData.controlBlock->appImageInfo[btlData.controlBlock->ActiveImageNum].programAddress + btlData.write_index));

            btlData.write_index += DATA_SIZE;
            btlData.read_index += DATA_SIZE;

            if (btlData.read_index >= btlData.controlBlock->appImageInfo[btlData.controlBlock->ActiveImageNum].imageSize)
            {
                btlData.state = BTL_STATE_VERIFY_SIGNATURE;
            }
            else
            {
                btlData.state = BTL_STATE_READ_APP_IMAGE;
            }

            break;
        }

        case BTL_STATE_VERIFY_SIGNATURE:
        {
            uint32_t crc32;
            uint32_t *received_crc32 = (void *)btlData.controlBlock->appImageInfo[btlData.controlBlock->ActiveImageNum].signature;
            crc32 = bootloader_CRCGenerate(btlData.controlBlock->appImageInfo[btlData.controlBlock->ActiveImageNum].programAddress, btlData.controlBlock->appImageInfo[btlData.controlBlock->ActiveImageNum].imageSize);

            if (crc32 == *received_crc32)
            {
                btlData.state = BTL_STATE_UPDATE_META_DATA;
            }
            else
            {
                btlData.state = BTL_STATE_ERROR;
            }

            break;
        }
</#if>
        case BTL_STATE_UPDATE_META_DATA:
        {
            if (bootloader_${BTL_TYPE}_CtrlBlkRead(btlData.controlBlock, ctrlBlkSize) == true)
            {
<#if (core.CoreArchitecture == "MIPS") && (DRIVER_USED == NVM_MEM_USED)>
                uint32_t serialNum = bootloader_${BTL_TYPE}_FlashSerialGet(PROGRAM_FLASH_BANK_1);
                btlData.controlBlock->serialNum = (serialNum + 1U);
</#if>
                btlData.controlBlock->blockUpdated = 0U;
                btlData.controlBlock->appImageInfo[btlData.controlBlock->ActiveImageNum].imageType = OTA_CB_IMAGETYPE_ACTIVE;
                btlData.controlBlock->appImageInfo[btlData.controlBlock->ActiveImageNum].status = OTA_CB_STATUS_VALID;

                (void)bootloader_${BTL_TYPE}_CtrlBlkWrite(btlData.controlBlock, ctrlBlkSize);
            }

<#if DRIVER_USED != NVM_MEM_USED>
            bootloader_TriggerReset();
<#else>
        <#if core.CoreArchitecture == "MIPS" >
            /* Reset */
            bootloader_TriggerReset();
        <#else>
            /* Swap bank and Reset */
            ${MEM_USED}_BankSwap();
        </#if>
</#if>

            break;
        }

        case BTL_STATE_RUN_APPLICATION:
        {
            run_Application(btlData.appJumpAddress);

            break;
        }

        case BTL_STATE_ERROR:
        default:
        {
            // Do nothing
            break;
        }
    }
}
