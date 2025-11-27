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
typedef enum
{
<#if DRIVER_USED != "">
    BOOTLOADER_STATE_INIT = 0U,

    BOOTLOADER_CHECK_IMAGE,
<#else>
    BOOTLOADER_REGISTER_EVENT_HANDLER = 0U,

    BOOTLOADER_WAIT_FOR_DEVICE_ATTACH,
</#if>

    BOOTLOADER_STATE_IDLE
} BOOTLOADER_STATES;

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************
<#if DRIVER_USED != "">
static BOOTLOADER_STATES btl_state = BOOTLOADER_STATE_INIT;
<#else>
static BOOTLOADER_STATES btl_state = BOOTLOADER_REGISTER_EVENT_HANDLER;
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Global Functions
// *****************************************************************************
// *****************************************************************************

void bootloader_${BTL_TYPE}_Tasks(void)
{
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
            bootloader_Storage_Read();
            btl_state = BOOTLOADER_STATE_IDLE;
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
                bootloader_Storage_Read();
                btl_state = BOOTLOADER_STATE_IDLE;
            }
            break;
        }
</#if>
        case BOOTLOADER_STATE_IDLE:
        {
            // idle
            break;
        }
        default:
        {
            // default
            break;
        }
    }

}
