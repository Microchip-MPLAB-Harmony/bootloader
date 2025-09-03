/*******************************************************************************
  Bootloader Storage Header File

  File Name:
    bootloader_storage.h

  Summary:
    This file contains storage definitions and functions.

  Description:
    This file contains storage definitions and functions.
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

#ifndef BOOTLOADER_STORAGE_H
#define BOOTLOADER_STORAGE_H

#include "definitions.h"
#include <device.h>

<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && (DRIVER_USED == "DRV_NAND_FLASH" || DRIVER_USED == "DRV_SST26")>
#define DATA_RECORD             0
#define END_OF_FILE_RECORD      1
#define EXT_SEG_ADRS_RECORD     2
#define EXT_LIN_ADRS_RECORD     4
#define START_LIN_ADRS_RECORD   5

typedef enum
{
    // indicates that the CRC value between the calculated value and the
    // value received from data stream did not match
    HEX_REC_CRC_ERROR   = -10,

    // programming error
    HEX_REC_PGM_ERROR   = -5,

    // An unspecified hex record tyype is received
    HEX_REC_UNKNOW_TYPE = -1,

    // the record type is a valid hex record
    HEX_REC_NORMAL      = 0,
} HEX_RECORD_STATUS;

</#if>
<#if DRIVER_USED != "">
void bootloader_ImageSizeSet(uint32_t size);
bool bootloader_IsDeviceReady(void);
<#else>
void bootloader_SysFsEventHandler(SYS_FS_EVENT event, void * eventData, uintptr_t context);
bool bootloader_IsDeviceAttached(void);
</#if>
void bootloader_Storage_Read(void);
<#if BTL_MPU_USB_DEVICE_PRESENT?? && BTL_MPU_USB_DEVICE_PRESENT == true && (DRIVER_USED == "DRV_NAND_FLASH" || DRIVER_USED == "DRV_SST26")>
HEX_RECORD_STATUS bootloader_Storage_ProgramHexRecord(uint8_t *HexRecord, size_t size);
bool bootloader_Storage_Erase(void);
<#else>
bool bootloader_Storage_Write(bool imageStartFlag, void *buffer, size_t size);
</#if>
bool bootloader_Storage_CRC_Verify(uint32_t crc);

#endif    //BOOTLOADER_STORAGE_H