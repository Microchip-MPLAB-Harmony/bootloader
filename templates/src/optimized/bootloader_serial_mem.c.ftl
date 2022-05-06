/*******************************************************************************
  SERIAL MEMORY Bootloader Source File

  File Name:
    bootloader.c

  Summary:
    This file contains source code necessary to execute SERIAL MEMORY bootloader.

  Description:
    This file contains source code necessary to execute SERIAL MEMORY bootloader.
    It implements bootloader protocol which uses Serial memory peripheral to download
    application firmware into internal flash from Serial Memory.
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2021 Microchip Technology Inc. and its subsidiaries.
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
#include "definitions.h"
#include <device.h>

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

#define DATA_SIZE                   ERASE_BLOCK_SIZE

#define APP_UPDATE_REQUIRED         (0xFFFFFFFFU)
#define APP_CLEAR_UPDATE_REQUIRED   (0x00000000U)

#define APP_META_DATA_PROLOGUE      (0xDEADBEEFU)
#define APP_META_DATA_EPILOGUE      (0xBEEFDEADU)
#define APP_META_DATA_CLR           (0xFFFFFFFFU)

typedef enum
{
    BOOTLOADER_STATE_INIT = 0,

    BOOTLOADER_STATE_OPEN_DRIVER,

    BOOTLOADER_STATE_GEOMETRY_GET,

    BOOTLOADER_STATE_GET_METADATA,

    BOOTLOADER_STATE_CHECK_UPDATE,

    BOOTLOADER_STATE_CHECK_TRIGGER,

    BOOTLOADER_STATE_RUN_APPLICATION,

    BOOTLOADER_STATE_READ_APP_BINARY,

    BOOTLOADER_STATE_READ_WAIT,

    BOOTLOADER_STATE_FLASH,

    BOOTLOADER_STATE_VERIFY_BINARY,

    BOOTLOADER_STATE_UPDATE_META_DATA,

    BOOTLOADER_STATE_UPDATE_WAIT,

    BOOTLOADER_STATE_ERROR

} BOOTLOADR_STATES;

typedef enum
{
    /* Transfer being processed */
    SERIAL_MEM_TRANSFER_BUSY,

    /* Transfer is successfully completed*/
    SERIAL_MEM_TRANSFER_COMPLETED,

    /* Transfer had error*/
    SERIAL_MEM_TRANSFER_ERROR_UNKNOWN,

} SERIAL_MEM_TRANSFER_STATUS;

/*
 Summary:
    Memory Device Geometry Table.

 Description:
    This Data Structure is used by Bootloader to get
    the geometry details.

    The Serial Memory attached to bootloader needs to fill in
    this data structure when GEOMETRY_GET is called.

 Remarks:
    None.
*/
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

} SERIAL_MEM_GEOMETRY;

/* Structure to store the Meta Data of the application binary for bootloader
 * Note: The order of the members should not be changed
 */
typedef struct
{
    /* Used to Validate the Meta Data itself*/
    uint32_t prologue;

    /* Flag to indicate if a firmware update is required
     * 0xFFFFFFFF --> Update Required. Set by Serial Memory programmer after programming
     *                the image in Serial memory
     * 0x00000000 --> Update Completed. Changed by bootloader after programming
     *                the image from Serial memory to internal flash
     */
    uint32_t isAppUpdateRequired;

    /* Application Start address */
    uint32_t appStartAddress;

    /* Application Jump address */
    uint32_t appJumpAddress;
    
    /* Size of the application binary */
    uint32_t appSize;

    /* CRC32 value for the application binary */
    uint32_t appCRC32;

    /* Used to Validate the Meta Data itself*/
    uint32_t epilogue;

} APP_META_DATA;

typedef struct
{
    BOOTLOADR_STATES state;

    DRV_HANDLE handle;

    SERIAL_MEM_GEOMETRY geometry;

    uint32_t read_index;

    uint32_t serialFlashStart;

    uint32_t serialFlashSize;

    uint32_t appMetaDataAddress;

    uint32_t flash_addr;

    uint32_t appStartAddress;

    uint32_t appJumpAddress;

    uint32_t crc32;

} BOOTLOADER_DATA;

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************

APP_META_DATA CACHE_ALIGN appMetaData;

BOOTLOADER_DATA CACHE_ALIGN btlData =
{
    .state              = BOOTLOADER_STATE_INIT,
    .flash_addr         = APP_START_ADDRESS,
    .appStartAddress    = APP_START_ADDRESS,
<#if __PROCESSOR?matches("PIC32M.*") == false>
    .appJumpAddress     = APP_START_ADDRESS,
<#else>
    .appJumpAddress     = APP_JUMP_ADDRESS,
</#if>
};

<#if .vars["${DRIVER_USED?lower_case}"].EEPROM_PAGE_SIZE??>
    <#lt>static uint32_t CACHE_ALIGN clearUpdateRequired[${DRIVER_USED}_EEPROM_PAGE_SIZE / sizeof(uint32_t)];
<#else>
    <#lt>static uint32_t CACHE_ALIGN clearUpdateRequired[${DRIVER_USED}_PAGE_SIZE / sizeof(uint32_t)];
</#if>

static uint8_t CACHE_ALIGN flash_data[DATA_SIZE];

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Local Functions
// *****************************************************************************
// *****************************************************************************

static bool BOOTLOADER_WaitForXferComplete( void )
{
    bool status = false;

    SERIAL_MEM_TRANSFER_STATUS transferStatus = SERIAL_MEM_TRANSFER_ERROR_UNKNOWN;

    do
    {
        transferStatus = ${DRIVER_USED}_TransferStatusGet(btlData.handle);

    } while (transferStatus == SERIAL_MEM_TRANSFER_BUSY);

    if(transferStatus == SERIAL_MEM_TRANSFER_COMPLETED)
    {
        status = true;
    }

    return status;
}

static bool BOOTLOADER_GetMetaData( void )
{
    bool status = false;

    btlData.serialFlashStart    = btlData.geometry.blockStartAddress;

    btlData.serialFlashSize     = (btlData.geometry.read_blockSize * btlData.geometry.read_numBlocks);

<#if SERIAL_MEM_ERASE_ENABLE?? && SERIAL_MEM_ERASE_ENABLE == true>
    btlData.appMetaDataAddress  = ((btlData.serialFlashStart + btlData.serialFlashSize) - btlData.geometry.erase_blockSize);
<#else>
    btlData.appMetaDataAddress  = ((btlData.serialFlashStart + btlData.serialFlashSize) - btlData.geometry.write_blockSize);
</#if>

    if (${DRIVER_USED}_Read(btlData.handle, (uint32_t *)&appMetaData, sizeof(appMetaData), btlData.appMetaDataAddress) != true)
    {
        return false;
    }

    status = BOOTLOADER_WaitForXferComplete();

    return status;
}

static bool BOOTLOADER_CheckForUpdate( void )
{
    bool status = false;

    /* Check if Meta Data has expected prologue and epilogue before update
     * When meta Data is in Reset State or corrupted jump to existing
     * application running in internal flash.
    */
    if ((appMetaData.prologue == APP_META_DATA_PROLOGUE) &&
        (appMetaData.epilogue == APP_META_DATA_EPILOGUE) &&
        (appMetaData.appSize  != 0))
    {
        if (appMetaData.isAppUpdateRequired == APP_UPDATE_REQUIRED)
        {
            status = true;
        }

        btlData.flash_addr      = appMetaData.appStartAddress;
        btlData.appStartAddress = appMetaData.appStartAddress;
        btlData.appJumpAddress  = appMetaData.appJumpAddress;
    }
    else
    {
        btlData.flash_addr      = APP_START_ADDRESS;
        btlData.appStartAddress = APP_START_ADDRESS;
<#if __PROCESSOR?matches("PIC32M.*") == false>
        btlData.appJumpAddress  = APP_START_ADDRESS;
<#else>
        btlData.appJumpAddress  = APP_JUMP_ADDRESS;
</#if>
    }

    return status;
}

static bool BOOTLOADER_UpdateMetaData( void )
{
    bool status = false;

    memset((void *)clearUpdateRequired, 0xFF, sizeof(clearUpdateRequired));

    /* Read existing Meta Data to Perform Read-Modify-Write */
    if (${DRIVER_USED}_Read(btlData.handle, clearUpdateRequired, sizeof(appMetaData), btlData.appMetaDataAddress) == false)
    {
        return status;
    }

    if (BOOTLOADER_WaitForXferComplete() == false)
    {
        return status;
    }

    /* Clear the Update required field (btlData.appMetaDataAddress + 4)  */
    clearUpdateRequired[1] = APP_CLEAR_UPDATE_REQUIRED;

    /* Only Update the "isUpdatRequired" field of meta data to indicate the update is completed.
     * No Need to Erase before Write as the "isUpdatRequired" location is already in Erased State (0xFFFFFFFF)
     */
    status = ${DRIVER_USED}_PageWrite(btlData.handle, (uint32_t *)clearUpdateRequired, btlData.appMetaDataAddress);

    if (status == true)
    {
        status = BOOTLOADER_WaitForXferComplete();
    }

    return status;
}

extern void SYS_DeInitialize( void *data );

static void BOOTLOADER_ReleaseResources(void)
{
    SYS_DeInitialize ( NULL );
}

/* Function to program received application firmware data into internal flash */
static void flash_task(void)
{
    uint32_t addr       = btlData.flash_addr;
    uint32_t page       = 0;
    uint32_t write_idx  = 0;

<#if core.CoreArchitecture != "MIPS">
    // Lock region size is always bigger than the row size
    ${MEM_USED}_RegionUnlock(addr);

    while(${MEM_USED}_IsBusy() == true)
    {

    }
</#if>

    /* Erase the Current sector */
    ${.vars["${MEM_USED?lower_case}"].ERASE_API_NAME}(addr);

    while(${MEM_USED}_IsBusy() == true)
    {

    }

    for (page = 0; page < PAGES_IN_ERASE_BLOCK; page++)
    {
        ${.vars["${MEM_USED?lower_case}"].WRITE_API_NAME}((uint32_t *)&flash_data[write_idx], addr);

        while(${MEM_USED}_IsBusy() == true)
        {

        }

        addr        += PAGE_SIZE;
        write_idx   += PAGE_SIZE;
    }

    btlData.flash_addr += DATA_SIZE;
}

// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Global Functions
// *****************************************************************************
// *****************************************************************************

void bootloader_${BTL_TYPE}_Tasks ( void )
{
    /* Check the application's current state. */
    switch ( btlData.state )
    {
        case BOOTLOADER_STATE_INIT:
        {
            if (${DRIVER_USED}_Status(${DRIVER_USED}_INDEX) == SYS_STATUS_READY)
            {
                btlData.state = BOOTLOADER_STATE_OPEN_DRIVER;
            }

            break;
        }

        case BOOTLOADER_STATE_OPEN_DRIVER:
        {
            btlData.handle = ${DRIVER_USED}_Open(${DRIVER_USED}_INDEX, DRV_IO_INTENT_READWRITE);

            if (btlData.handle != DRV_HANDLE_INVALID)
            {
                btlData.state = BOOTLOADER_STATE_GEOMETRY_GET;
            }

            break;
        }

        case BOOTLOADER_STATE_GEOMETRY_GET:
        {
            if (${DRIVER_USED}_GeometryGet(btlData.handle, (${DRIVER_USED}_GEOMETRY *)&btlData.geometry) != true)
            {
                btlData.state = BOOTLOADER_STATE_ERROR;
                break;
            }

            btlData.state = BOOTLOADER_STATE_GET_METADATA;

            break;
        }

        case BOOTLOADER_STATE_GET_METADATA:
        {
            if (BOOTLOADER_GetMetaData() == true)
            {
                btlData.state = BOOTLOADER_STATE_CHECK_UPDATE;
            }
            else
            {
                btlData.state = BOOTLOADER_STATE_RUN_APPLICATION;
            }

            break;
        }

        case BOOTLOADER_STATE_CHECK_UPDATE:
        {
            if (BOOTLOADER_CheckForUpdate() == true)
            {
                btlData.state = BOOTLOADER_STATE_READ_APP_BINARY;
            }
            else
            {
                btlData.state = BOOTLOADER_STATE_CHECK_TRIGGER;
            }

            break;
        }

        case BOOTLOADER_STATE_CHECK_TRIGGER:
        {
            if (bootloader_Trigger() == true)
            {
                btlData.state = BOOTLOADER_STATE_READ_APP_BINARY;
            }
            else
            {
                btlData.state = BOOTLOADER_STATE_RUN_APPLICATION;
            }
                
            break;
        }

        case BOOTLOADER_STATE_RUN_APPLICATION:
        {
            BOOTLOADER_ReleaseResources();

            run_Application(btlData.appJumpAddress);

            break;
        }

        case BOOTLOADER_STATE_READ_APP_BINARY:
        {
            memset((void *)flash_data, 0xFF, DATA_SIZE);

            if (${DRIVER_USED}_Read(btlData.handle, (uint32_t *)&flash_data[0], DATA_SIZE, (btlData.serialFlashStart + btlData.read_index)) == false)
            {
                btlData.state = BOOTLOADER_STATE_ERROR;
                break;
            }

            if (BOOTLOADER_WaitForXferComplete() == true)
            {
                btlData.state = BOOTLOADER_STATE_FLASH;
            }
            else
            {
                btlData.state = BOOTLOADER_STATE_ERROR;
            }

            break;
        }

        case BOOTLOADER_STATE_FLASH:
        {
            flash_task();

            btlData.read_index += DATA_SIZE;

            if (btlData.read_index >= appMetaData.appSize)
            {
                btlData.state = BOOTLOADER_STATE_VERIFY_BINARY;
            }
            else
            {
                btlData.state = BOOTLOADER_STATE_READ_APP_BINARY;
            }

            break;
        }

        case BOOTLOADER_STATE_VERIFY_BINARY:
        {
            btlData.crc32 = bootloader_CRCGenerate(btlData.appStartAddress, appMetaData.appSize);

            if (btlData.crc32 == appMetaData.appCRC32)
            {
                btlData.state = BOOTLOADER_STATE_UPDATE_META_DATA;
            }
            else
            {
                btlData.state = BOOTLOADER_STATE_ERROR;
            }

            break;
        }

        case BOOTLOADER_STATE_UPDATE_META_DATA:
        {
            BOOTLOADER_UpdateMetaData();

            bootloader_TriggerReset();

            break;
        }

        case BOOTLOADER_STATE_ERROR:
        default:
            break;
    }
}
