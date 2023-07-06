/*******************************************************************************
  OTA service Control Block Header File

  File Name:
    ota_service_control_block.h

  Summary:
    This file contains OTA service Control Block definitions.

  Description:
    This file contains OTA service Control Block definitions.
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

#ifndef OTA_SERVICE_CONTROL_BLOCK_H
#define OTA_SERVICE_CONTROL_BLOCK_H

#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <device.h>
<#if core.CoreArchitecture == "MIPS">
    <#lt>#include "sys/kmem.h"
</#if>

/* Provide C++ Compatibility */
#ifdef __cplusplus
extern "C" {
#endif

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

//Macros for control block status field
#define OTA_CB_STATUS_INVALID            0U
#define OTA_CB_STATUS_DOWNLOADED         1U
#define OTA_CB_STATUS_UNBOOTED           2U
#define OTA_CB_STATUS_DISABLED           3U
#define OTA_CB_STATUS_VALID              4U

//Macros for control block imageType field
#define OTA_CB_IMAGETYPE_ACTIVE          0U
#define OTA_CB_IMAGETYPE_ROLLBACK        1U
#define OTA_CB_IMAGETYPE_FACTORY         2U

//Macros for control block imageStorage field
#define OTA_CB_IMAGESTORAGE_INT_FLASH    0U
#define OTA_CB_IMAGESTORAGE_EXT_FLASH    1U
#define OTA_CB_IMAGESTORAGE_DUAL_BANK    2U

//Macros for control block format field
#define OTA_CB_FORMAT_BIN                0U
#define OTA_CB_FORMAT_HEX                1U

//Macros for control block signatureType field
#define OTA_CB_SIGNATURE_TYPE_CRC32      0U

/* Per app image info to store in this structure for bootloader/OTA service
 * Note: The order of the members should not be changed
 */
typedef struct __attribute__((packed))
{
    unsigned int  status           : 3;
    unsigned int  signaturePresent : 1;
    unsigned int  filenamePresent  : 1;
    unsigned int  imageEncrypted   : 1;
    unsigned int  reserved         : 2;
    unsigned int  imageType        : 4;
    unsigned int  imageStorage     : 4;
    unsigned int  versionNum       : 4;
    unsigned int  format           : 4;
    unsigned int  signatureType    : 8;
    uint32_t programAddress;
    uint32_t jumpAddress;
    uint32_t loadAddress;
    uint8_t  signature[8];
    uint32_t imageSize;
<#if IS_FS_SUPPORTED_IN_OTA?? && IS_FS_SUPPORTED_IN_OTA == true>
    uint8_t  filename[32];
</#if>
} APP_IMAGE_INFO;

/* Control block (Metadata) structure for bootloader/OTA service
 * Note: The order of the members should not be changed
 */
typedef struct
{
<#if (core.CoreArchitecture == "MIPS") && (DRIVER_USED == NVM_MEM_USED)>
    uint32_t       serialNum;
</#if>
    unsigned int   versionNum     : 4;
    unsigned int   ActiveImageNum : 4;
    unsigned int   blockUpdated   : 1;
    unsigned int   reserved       : 23;
<#if DRIVER_USED == NVM_MEM_USED>
    APP_IMAGE_INFO appImageInfo[1];
<#else>
    APP_IMAGE_INFO appImageInfo[${NUM_OF_APP_IMAGE}];
</#if>
} OTA_CONTROL_BLOCK;

/* Provide C++ Compatibility */
#ifdef __cplusplus
}
#endif

#endif      //OTA_SERVICE_CONTROL_BLOCK_H
