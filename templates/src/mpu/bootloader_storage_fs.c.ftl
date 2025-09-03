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

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true>
#define DATA_RECORD             0x00
#define END_OF_FILE_RECORD      0x01
#define EXT_SEG_ADRS_RECORD     0x02
#define EXT_LIN_ADRS_RECORD     0x04
#define START_LIN_ADRS_RECORD   0x05

typedef enum {
    HEX_REC_NORMAL,
    HEX_REC_CRC_ERROR,
    HEX_REC_UNKNOW_TYPE
} HEX_RECORD_STATUS;

typedef struct {
    uint8_t RecDataLen;
    uint8_t RecType;
    uint8_t* Data;
    uint32_t Address;
    uint32_t ExtSegAddress;
    uint32_t ExtLinAddress;
} T_HEX_RECORD;

</#if>
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

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true>
/**
 * @brief   Programs a single HEX record to an SD card file.
 * 
 * @param   HexRecord   Pointer to the buffer containing the HEX record(s).
 * @param   totalLen    Total length of the HEX record buffer.
 * @param   sdFile      Pointer to the open SD card file (FIL*).
 * 
 * @return  HEX_RECORD_STATUS   Status of the HEX record processing.
 */
HEX_RECORD_STATUS bootloader_SdProgramHexRecord(uint8_t* HexRecord, uint32_t totalLen, FILE* sdFile)
{
    static T_HEX_RECORD HexRecordSt;   // Static structure to hold parsed HEX record fields
    uint8_t Checksum = 0;              // Variable to calculate and verify checksum
    uint32_t i;
    uint32_t nextRecStartPt = 0;       // Offset to the start of the next record in the buffer

    // Process each HEX record in the buffer
    while(totalLen >= 5U) // A hex record must be at least 5 bytes (length, address(2), type, checksum)
    {
        HexRecord = &HexRecord[nextRecStartPt]; // Move pointer to the start of the next record
        HexRecordSt.RecDataLen = HexRecord[0];  // First byte: data length
        HexRecordSt.RecType = HexRecord[3];     // Fourth byte: record type
        HexRecordSt.Data = &HexRecord[4];       // Data starts at fifth byte

        // Calculate the start point of the next record
        nextRecStartPt = (uint32_t)HexRecordSt.RecDataLen + 5U;

        // Decrement total length by the size of the current record
        totalLen = totalLen - nextRecStartPt;

        // Calculate checksum for the current record (sum of all bytes should be 0)
        Checksum = 0U;
        for(i = 0U; i < ((uint32_t)HexRecordSt.RecDataLen + 5U); i++)
        {
            Checksum += HexRecord[i];
        }

        // If checksum is invalid, return error
        if(Checksum != 0U)
        {
            return HEX_REC_CRC_ERROR;
        }
        else
        {
            // Checksum is valid, process record based on its type
            switch(HexRecordSt.RecType)
            {
                case DATA_RECORD:  // Record Type 00: Data record
                    // Address is bytes 1 and 2, shifted and combined
                    HexRecordSt.Address = ((uint32_t)HexRecord[1] << 8U) + (uint32_t)HexRecord[2];
                    // Add extended linear and segment addresses
                    HexRecordSt.Address = HexRecordSt.Address + HexRecordSt.ExtLinAddress + HexRecordSt.ExtSegAddress;

                    if (SYS_FS_FileWrite((SYS_FS_HANDLE)sdFile, HexRecordSt.Data, HexRecordSt.RecDataLen) == 0xFFFFFFFFU)
                    {
                        return HEX_REC_UNKNOW_TYPE;
                    }
                    break;

                case EXT_SEG_ADRS_RECORD:  // Record Type 02: Extended segment address
                    // Set segment address (bits 4-19)
                    HexRecordSt.ExtSegAddress = ((uint32_t)HexRecordSt.Data[0] << 12U) + ((uint32_t)HexRecordSt.Data[1] << 4U);
                    // Reset linear address
                    HexRecordSt.ExtLinAddress = 0;
                    break;

                case EXT_LIN_ADRS_RECORD:   // Record Type 04: Extended linear address
                    // Set linear address (bits 16-31)
                    HexRecordSt.ExtLinAddress = ((uint32_t)HexRecordSt.Data[0] << 24U) + ((uint32_t)HexRecordSt.Data[1] << 16U);
                    // Reset segment address
                    HexRecordSt.ExtSegAddress = 0;
                    break;

                case END_OF_FILE_RECORD:  // Record Type 01: End of file
                    // No special action needed for SD card, just reset addresses
                    HexRecordSt.ExtSegAddress = 0;
                    HexRecordSt.ExtLinAddress = 0;
                    break;

                case START_LIN_ADRS_RECORD: // Record Type 05: Start linear address (optional, not always used)
                default:
                    // For unknown or unhandled record types, reset addresses
                    HexRecordSt.ExtSegAddress = 0;
                    HexRecordSt.ExtLinAddress = 0;
                    break;
            }
        }
    }

    // Return status based on the last record type processed
    if ( (HexRecordSt.RecType == (uint8_t)DATA_RECORD) || (HexRecordSt.RecType == (uint8_t)EXT_SEG_ADRS_RECORD)
            || (HexRecordSt.RecType == (uint8_t)EXT_LIN_ADRS_RECORD) || (HexRecordSt.RecType == (uint8_t)START_LIN_ADRS_RECORD)
            || (HexRecordSt.RecType == (uint8_t)END_OF_FILE_RECORD))
    {
        return HEX_REC_NORMAL;
    }
    else
    {
        return HEX_REC_UNKNOW_TYPE;
    }
}

</#if>
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
<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == false>
            if (SYS_FS_FileWrite(btlData.fileHandle, buffer, size) != 0xFFFFFFFFU)
<#else>
            if( HEX_REC_NORMAL == bootloader_SdProgramHexRecord(buffer, size, (FILE*)btlData.fileHandle) )
</#if>
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
