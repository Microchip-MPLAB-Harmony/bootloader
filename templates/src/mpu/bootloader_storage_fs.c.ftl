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
#include "system/fs/sys_fs.h"
#include "bootloader_storage.h"

#define BOOTLOADER_MOUNT_NAME   SYS_FS_MEDIA_IDX0_MOUNT_NAME_VOLUME_IDX0
#define BOOTLOADER_DEV_NAME     SYS_FS_MEDIA_IDX0_DEVICE_NAME_VOLUME_IDX0
#define APP_IMAGE_FILE_NAME     "${BTL_APP_IMAGE_PATH}"
#define APP_IMAGE_FILE_PATH     BOOTLOADER_MOUNT_NAME"/"APP_IMAGE_FILE_NAME

typedef struct
{
    /* Programming address */
    uint32_t progAddr;

    /* Stream handle */
    SYS_FS_HANDLE fileHandle;

    /* Stores Application binary file information */
    SYS_FS_FSTAT fileStat;

    /* Flag to indicate device attached */
    bool deviceAttached;

} BOOTLOADER_DATA;

static uint8_t CACHE_ALIGN fileBuffer[PAGE_SIZE];

static BOOTLOADER_DATA btlData =
{
    .deviceAttached = false,
    .progAddr       = APP_START_ADDRESS,
    .fileHandle     = SYS_FS_HANDLE_INVALID
};

void bootloader_SysFsEventHandler(SYS_FS_EVENT event, void * eventData, uintptr_t context)
{
    switch(event)
    {
        case SYS_FS_EVENT_MOUNT:
        {
            btlData.deviceAttached = true;
            break;
        }

        case SYS_FS_EVENT_UNMOUNT:
        {
            btlData.deviceAttached = false;
            break;
        }

        default:
        {
            // default
            break;
        }
    }
}

bool bootloader_IsDeviceAttached(void)
{
    return btlData.deviceAttached;
}

void bootloader_Storage_Read(void)
{
    size_t fileReadLength;
    size_t fileBufferSize;
    size_t fileSize;

    if (btlData.deviceAttached == true)
    {
        if (SYS_FS_FileStat(APP_IMAGE_FILE_PATH, &btlData.fileStat) == SYS_FS_RES_SUCCESS)
        {
            /* Check if the application binary file has any content */
            if (btlData.fileStat.fsize > 0U)
            {
                btlData.fileHandle = SYS_FS_FileOpen(APP_IMAGE_FILE_PATH, (SYS_FS_FILE_OPEN_READ));

                if(btlData.fileHandle != SYS_FS_HANDLE_INVALID)
                {
                    fileSize = btlData.fileStat.fsize;

                    do
                    {
                        if (fileSize >= PAGE_SIZE)
                        {
                            fileBufferSize = PAGE_SIZE;
                        }
                        else
                        {
                            fileBufferSize = fileSize;
                        }

                        fileReadLength = SYS_FS_FileRead(btlData.fileHandle, (void *)fileBuffer, fileBufferSize);

                        /* Reached End of File */
                        if (fileReadLength <= 0U)
                        {
                            (void)SYS_FS_FileClose(btlData.fileHandle);

                            run_Application(APP_START_ADDRESS);
                        }
                        else
                        {
                            (void)memcpy((uint8_t *)btlData.progAddr, fileBuffer, fileReadLength);

                            btlData.progAddr += fileBufferSize;
                            fileSize -= fileBufferSize;
                        }
                    } while(fileReadLength > 0U);
                }
            }
        }
    }
}

bool bootloader_Storage_Write(bool imageStartFlag, void *buffer, size_t size)
{
    bool status = false;
    SYS_FS_FILE_OPEN_ATTRIBUTES attributes = SYS_FS_FILE_OPEN_APPEND;

    if (btlData.deviceAttached == true)
    {
        if (imageStartFlag)
        {
            attributes = SYS_FS_FILE_OPEN_WRITE;
        }
        btlData.fileHandle = SYS_FS_FileOpen(APP_IMAGE_FILE_PATH, attributes);

        if(btlData.fileHandle != SYS_FS_HANDLE_INVALID)
        {
            if (SYS_FS_FileWrite(btlData.fileHandle, buffer, size) != 0xFFFFFFFFU)
            {
                (void)SYS_FS_FileClose(btlData.fileHandle);
                status = true;
            }
        }
    }

    return status;
}

bool bootloader_Storage_CRC_Verify(uint32_t crc)
{
    size_t fileReadLength;
    size_t fileBufferSize;
    size_t fileSize;
    uint32_t crcGenerate = 0xFFFFFFFFU;
    bool status = false;

    if (btlData.deviceAttached == true)
    {
        if (SYS_FS_FileStat(APP_IMAGE_FILE_PATH, &btlData.fileStat) == SYS_FS_RES_SUCCESS)
        {
            /* Check if the application binary file has any content */
            if (btlData.fileStat.fsize > 0U)
            {
                btlData.fileHandle = SYS_FS_FileOpen(APP_IMAGE_FILE_PATH, (SYS_FS_FILE_OPEN_READ));

                if(btlData.fileHandle != SYS_FS_HANDLE_INVALID)
                {
                    fileSize = btlData.fileStat.fsize;

                    do
                    {
                        if (fileSize >= PAGE_SIZE)
                        {
                            fileBufferSize = PAGE_SIZE;
                        }
                        else
                        {
                            fileBufferSize = fileSize;
                        }
                        fileReadLength = SYS_FS_FileRead(btlData.fileHandle, (void *)fileBuffer, fileBufferSize);

                        /* Reached End of File */
                        if (fileReadLength <= 0U)
                        {
                            if (crc == crcGenerate)
                            {
                                status = true;
                            }
                        }
                        else
                        {
                            crcGenerate = bootloader_CRCGenerate(fileBuffer, fileBufferSize, crcGenerate);
                            fileSize -= fileBufferSize;
                        }
                    } while(fileReadLength > 0U);
                }
            }
        }
    }

    return status;
}
