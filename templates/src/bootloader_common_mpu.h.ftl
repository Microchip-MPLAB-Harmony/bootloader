/*******************************************************************************
  Bootloader Common Header File

  File Name:
    bootloader_common.h

  Summary:
    This file contains common definitions and functions.

  Description:
    This file contains common definitions and functions.
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

#ifndef BOOTLOADER_COMMON_H
#define BOOTLOADER_COMMON_H

<#if HarmonyCore??>
    <#if HarmonyCore.ENABLE_DRV_COMMON == true ||
         HarmonyCore.ENABLE_SYS_COMMON == true ||
         HarmonyCore.ENABLE_APP_FILE == true >
        <#lt>#include "configuration.h"
    </#if>
</#if>
#include "definitions.h"
#include <device.h>

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

#define BOOTLOADER_SIZE                         ${BTL_SIZE}U
#define BOOTLOADER_START_ADDRESS                (${BTL_START}U)
#define APP_START_ADDRESS                       (${BTL_APP_START}U)
<#if sys_fs??>
#define PAGE_SIZE                               ${sys_fs.SYS_FS_MEDIA_MAX_BLOCK_SIZE}U
<#else>
#define PAGE_SIZE                               ${DRIVER_USED}_PAGE_SIZE
</#if>

// *****************************************************************************

void SYS_DeInitialize( void *data );

/* Function:
    uint16_t bootloader_GetVersion( void );

Summary:
    Returns the current bootloader version.

Description:
    This function can be used to read the current version of bootloader.

    The bootloader version is of 2 Bytes. MAJOR version is sent first
    followed by MINOR version

    This function is defined as __WEAK in bootloader core and defines the bootloader
    version to current release version of bootloader repo.

    It can be overridden with custom implementation by user based on his requirement.

    User can make use of bootloader read version command to read the current version
    from the respective host.

Precondition:
    None

Parameters:
    None.

Returns:
    bootloader version - 2 Bytes (MAJOR version is sent first followed by MINOR version)

Example:
    <code>

    #define BTL_MAJOR_VERSION       3U
    #define BTL_MINOR_VERSION       6U

    uint16_t bootloader_GetVersion( void )
    {
        uint16_t btlVersion = (((BTL_MAJOR_VERSION & (uint16_t)0xFFU) << 8) | (BTL_MINOR_VERSION & (uint16_t)0xFFU));

        return btlVersion;
    }

    </code>
*/
uint16_t bootloader_GetVersion( void );

/* MISRA C-2012 Rule 5.8 deviated below. Deviation record ID -
   H3_MISRAC_2012_R_5_8_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate "MISRA C-2012 Rule 5.8" "H3_MISRAC_2012_R_5_8_DR_1" )
</#if>
// *****************************************************************************
/* Function:
    bool bootloader_Trigger( void );

Summary:
    Checks if Bootloader has to be executed at startup.

Description:
    This function can be used to check for a External HW trigger or Internal firmware
    trigger to execute bootloader at startup.

    This check should happen before any system resources are initialized apart for PORT
    as the same system resource can be Re-initialized by the application if bootloader jumps
    to it and may cause issues.

    - <b>External Trigger: </b>
        Is achieved by triggering the selected GPIO_PIN in bootloader configuration
        in MHC.
    - <b>Firmware Trigger: </b>
        Application firmware which wants to execute bootloader at startup needs to
        fill first 16 bytes of ram location with bootloader request pattern.

        <code>
            uint32_t *sram = (uint32_t *)RAM_START_ADDRESS;

            sram[0] = 0x5048434D;
            sram[1] = 0x5048434D;
            sram[2] = 0x5048434D;
            sram[3] = 0x5048434D;
        </code>

Precondition:
    PORT/PIO Initialize must have been called.

Parameters:
    None.

Returns:
    - True  : If any of trigger is detected.
    - False : If no trigger is detected..

Example:
    <code>

        NVMCTRL_Initialize();

        PORT_Initialize();

        if (bootloader_Trigger() == false)
        {
            run_Application(APP_START_ADDRESS);
        }

        CLOCK_Initialize();

    </code>
*/
bool bootloader_Trigger( void );

// *****************************************************************************
/* Function:
    void run_Application( uint32_t address );

Summary:
    Runs the programmed application at startup.

Description:
    This function can be used to run programmed application though bootloader at startup.

    If the first 4Bytes of Application Memory is not 0xFFFFFFFF then it jumps to
    the application start address to run the application programmed through bootloader and
    never returns.

    If the first 4Bytes of Application Memory is 0xFFFFFFFF then it returns from function
    and executes bootloader for accepting a new application firmware.

Precondition:
    bootloader_Trigger() must be called to check for bootloader triggers at startup.

Parameters:
    address - Application Start/Jump address.

Returns:
    None

Example:
    <code>

        NVMCTRL_Initialize();

        PORT_Initialize();

        if (bootloader_Trigger() == false)
        {
            run_Application(APP_START_ADDRESS);
        }

        CLOCK_Initialize();

    </code>
*/
void run_Application( uint32_t address );
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 5.8"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>

// *****************************************************************************
/* Function:
    uint32_t bootloader_CRCGenerate(uint8_t *start_addr, uint32_t size, uint32_t crc)

Summary:
    Generates CRC on the contents of external media memory from the given start address and size

Description:
    This function can be used to verify the programmed image in external media when a Verify
    command is received from the host

Precondition:
    The application binary is already programmed in external media memory

Parameters:
    start_addr - Pointer to buffer which contains data to calculate the CRC from
    size - Size of the buffer to calculate CRC for
    crc - Initial crc value

Returns:
    Returns the calculated CRC

Example:
    <code>
        #define PAGE_SIZE    512
        uint8_t CACHE_ALIGN fileBuffer[PAGE_SIZE];
        uint32_t crcGenerate = 0xFFFFFFFFU;

        crcGenerate = bootloader_CRCGenerate(fileBuffer, PAGE_SIZE, crcGenerate);

    </code>
*/

uint32_t bootloader_CRCGenerate(uint8_t *start_addr, uint32_t size, uint32_t crc);

// *****************************************************************************
/* Function:
    void bootloader_TriggerReset(void)

Summary:
    Triggers a reset

Description:
    This function can be used to reset the device in response to the RESET command
    received from the host

Precondition:
    None.

Parameters:
    None

Returns:
    None

Example:
    <code>

        bootloader_TriggerReset();

    </code>
*/
void bootloader_TriggerReset(void);

#endif      //BOOTLOADER_COMMON_H