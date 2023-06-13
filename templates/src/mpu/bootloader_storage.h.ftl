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

<#if DRIVER_USED != "">
void bootloader_ImageSizeSet(uint32_t size);
bool bootloader_IsDeviceReady(void);
<#else>
void bootloader_SysFsEventHandler(SYS_FS_EVENT event, void * eventData, uintptr_t context);
bool bootloader_IsDeviceAttached(void);
</#if>
void bootloader_Storage_Read(void);
bool bootloader_Storage_Write(bool imageStartFlag, void *buffer, size_t size);
bool bootloader_Storage_CRC_Verify(uint32_t crc);

#endif    //BOOTLOADER_STORAGE_H