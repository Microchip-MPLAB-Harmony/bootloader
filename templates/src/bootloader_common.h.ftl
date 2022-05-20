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
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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

#include "definitions.h"
#include <device.h>
<#if core.CoreArchitecture == "MIPS">
    <#lt>#include "sys/kmem.h"
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

#define FLASH_START                             (${.vars["${MEM_USED?lower_case}"].FLASH_START_ADDRESS}UL)
#define FLASH_LENGTH                            (${.vars["${MEM_USED?lower_case}"].FLASH_SIZE}UL)
#define PAGE_SIZE                               (${.vars["${MEM_USED?lower_case}"].FLASH_PROGRAM_SIZE}UL)
#define ERASE_BLOCK_SIZE                        (${.vars["${MEM_USED?lower_case}"].FLASH_ERASE_SIZE}UL)
#define PAGES_IN_ERASE_BLOCK                    (ERASE_BLOCK_SIZE / PAGE_SIZE)

<#if BTL_FUSE_PROGRAM_ENABLE?? && BTL_FUSE_PROGRAM_ENABLE == true>
    <#if .vars["${MEM_USED?lower_case}"].FLASH_USERROW_START_ADDRESS??>
        <#lt>#define NVM_USER_ROW_START                      (${.vars["${MEM_USED?lower_case}"].FLASH_USERROW_START_ADDRESS}UL)
        <#lt>#define NVM_USER_ROW_SIZE                       (${.vars["${MEM_USED?lower_case}"].FLASH_USERROW_SIZE}UL)
        <#lt>#define NVM_USER_PAGE_SIZE                      (${.vars["${MEM_USED?lower_case}"].FLASH_USERROW_PROGRAM_SIZE}UL)
    </#if>

    <#if .vars["${MEM_USED?lower_case}"].FLASH_BOCORROW_START_ADDRESS??>
        <#lt>#define NVM_BOCOR_ROW_START                      (${.vars["${MEM_USED?lower_case}"].FLASH_BOCORROW_START_ADDRESS}UL)
        <#lt>#define NVM_BOCOR_ROW_SIZE                       (${.vars["${MEM_USED?lower_case}"].FLASH_BOCORROW_SIZE}UL)
        <#lt>#define NVM_BOCOR_PAGE_SIZE                      (${.vars["${MEM_USED?lower_case}"].FLASH_BOCORROW_PROGRAM_SIZE}UL)
    </#if>
</#if>

#define BOOTLOADER_SIZE                         ${BTL_SIZE}

<#if (BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true) ||
     (BTL_DUAL_BANK?? && BTL_DUAL_BANK == true) >
    <#lt>/* Starting location of Bootloader in Inactive bank */
    <#lt>#define INACTIVE_BANK_OFFSET                    (FLASH_LENGTH / 2)

    <#lt>#define INACTIVE_BANK_START                     (FLASH_START + INACTIVE_BANK_OFFSET)

    <#lt>#define FLASH_END_ADDRESS                       (INACTIVE_BANK_START + INACTIVE_BANK_OFFSET)

<#else>
    <#lt>#define FLASH_END_ADDRESS                       (FLASH_START + FLASH_LENGTH)

</#if>

<#if BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true >
    <#lt>#define APP_START_ADDRESS                       INACTIVE_BANK_START
<#else>
    <#if core.CoreArchitecture == "MIPS">
        <#lt>#define APP_START_ADDRESS                       ((uint32_t)(PA_TO_KVA0(0x${core.APP_START_ADDRESS}UL)))
        <#lt>#define APP_JUMP_ADDRESS                        ((uint32_t)(PA_TO_KVA0(0x${BTL_APP_JUMP_ADDRESS}UL)))
    <#else>
        <#lt>#define APP_START_ADDRESS                       (0x${core.APP_START_ADDRESS}UL)
    </#if>
</#if>

<#if (core.CoreArchitecture == "MIPS") &&
     ((BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true) ||
     (BTL_DUAL_BANK?? && BTL_DUAL_BANK == true)) >

    <#lt>#define LOWER_FLASH_START                       (FLASH_START)
    <#lt>#define LOWER_FLASH_SERIAL_START                (LOWER_FLASH_START + (FLASH_LENGTH / 2) - PAGE_SIZE)
    <#lt>#define LOWER_FLASH_SERIAL_SECTOR               (LOWER_FLASH_START + (FLASH_LENGTH / 2) - ERASE_BLOCK_SIZE)

    <#lt>#define UPPER_FLASH_START                       INACTIVE_BANK_START
    <#lt>#define UPPER_FLASH_SERIAL_START                (FLASH_END_ADDRESS - PAGE_SIZE)
    <#lt>#define UPPER_FLASH_SERIAL_SECTOR               (FLASH_END_ADDRESS - ERASE_BLOCK_SIZE)

    <#lt>#define FLASH_SERIAL_PROLOGUE                   0xDEADBEEF
    <#lt>#define FLASH_SERIAL_EPILOGUE                   0xBEEFDEAD
    <#lt>#define FLASH_SERIAL_CLEAR                      0xFFFFFFFF

    <#lt>#define LOWER_FLASH_SERIAL_READ                 ((T_FLASH_SERIAL *)KVA0_TO_KVA1(LOWER_FLASH_SERIAL_START))
    <#lt>#define UPPER_FLASH_SERIAL_READ                 ((T_FLASH_SERIAL *)KVA0_TO_KVA1(UPPER_FLASH_SERIAL_START))

    <#lt>typedef enum
    <#lt>{
    <#lt>    PROGRAM_FLASH_BANK_1,
    <#lt>    PROGRAM_FLASH_BANK_2,
    <#lt>} T_FLASH_BANK;

    <#lt>/* Structure to validate the Flash serial and its checksum
    <#lt> * Note: The order of the members should not be changed
    <#lt> */
    <#lt>typedef struct
    <#lt>{
    <#lt>    uint32_t prologue;
    <#lt>    uint32_t serial;
    <#lt>    uint32_t epilogue;
    <#lt>    uint32_t dummy;
    <#lt>} T_FLASH_SERIAL;
</#if>

<#if BTL_TRIGGER_ENABLE == true && BTL_TRIGGER_LEN != "0" >
    <#if core.CoreArchitecture == "MIPS">
        <#lt>#define BTL_TRIGGER_RAM_START                   KVA0_TO_KVA1(${BTL_RAM_START})
    <#elseif core.CoreArchitecture == "CORTEX-M23">
        <#lt>#define BTL_TRIGGER_RAM_START                   (${BTL_RAM_START} + 0x1000)
    <#else>
        <#lt>#define BTL_TRIGGER_RAM_START                   ${BTL_RAM_START}
    </#if>

    <#lt>#define BTL_TRIGGER_LEN                         ${BTL_TRIGGER_LEN}
</#if>

// *****************************************************************************
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

    // Bootloader Major and Minor version sent for a Read Version command (MAJOR.MINOR)
    #define BTL_MAJOR_VERSION       3
    #define BTL_MINOR_VERSION       6

    uint16_t bootloader_GetVersion( void )
    {
        uint16_t btlVersion = (((BTL_MAJOR_VERSION & 0xFF) << 8) | (BTL_MINOR_VERSION & 0xFF));

        return btlVersion;
    }

    </code>
*/
uint16_t bootloader_GetVersion( void );

<#if (BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == false) ||
     (!BTL_LIVE_UPDATE??) >
    <#lt>// *****************************************************************************
    <#lt>/* Function:
    <#lt>    bool bootloader_Trigger( void );

    <#lt>Summary:
    <#lt>    Checks if Bootloader has to be executed at startup.

    <#lt>Description:
    <#lt>    This function can be used to check for a External HW trigger or Internal firmware
    <#lt>    trigger to execute bootloader at startup.

    <#lt>    This check should happen before any system resources are initialized apart for PORT
    <#lt>    as the same system resource can be Re-initialized by the application if bootloader jumps
    <#lt>    to it and may cause issues.

    <#lt>    - <b>External Trigger: </b>
    <#lt>        Is achieved by triggering the selected GPIO_PIN in bootloader configuration
    <#lt>        in MHC.
    <#lt>    - <b>Firmware Trigger: </b>
    <#lt>        Application firmware which wants to execute bootloader at startup needs to
    <#lt>        fill first 16 bytes of ram location with bootloader request pattern.

    <#lt>        <code>
    <#lt>            uint32_t *sram = (uint32_t *)RAM_START_ADDRESS;

    <#lt>            sram[0] = 0x5048434D;
    <#lt>            sram[1] = 0x5048434D;
    <#lt>            sram[2] = 0x5048434D;
    <#lt>            sram[3] = 0x5048434D;
    <#lt>        </code>

    <#lt>Precondition:
    <#lt>    PORT/PIO Initialize must have been called.

    <#lt>Parameters:
    <#lt>    None.

    <#lt>Returns:
    <#lt>    - True  : If any of trigger is detected.
    <#lt>    - False : If no trigger is detected..

    <#lt>Example:
    <#lt>    <code>

    <#lt>        NVMCTRL_Initialize();

    <#lt>        PORT_Initialize();

    <#lt>        if (bootloader_Trigger() == false)
    <#lt>        {
    <#lt>            run_Application(APP_START_ADDRESS);
    <#lt>        }

    <#lt>        CLOCK_Initialize();

    <#lt>    </code>
    <#lt>*/
    <#lt>bool bootloader_Trigger( void );

    <#lt>// *****************************************************************************
    <#lt>/* Function:
    <#lt>    void run_Application( uint32_t address );

    <#lt>Summary:
    <#lt>    Runs the programmed application at startup.

    <#lt>Description:
    <#lt>    This function can be used to run programmed application though bootloader at startup.

    <#lt>    If the first 4Bytes of Application Memory is not 0xFFFFFFFF then it jumps to
    <#lt>    the application start address to run the application programmed through bootloader and
    <#lt>    never returns.

    <#lt>    If the first 4Bytes of Application Memory is 0xFFFFFFFF then it returns from function
    <#lt>    and executes bootloader for accepting a new application firmware.

    <#lt>Precondition:
    <#lt>    bootloader_Trigger() must be called to check for bootloader triggers at startup.

    <#lt>Parameters:
    <#lt>    address - Application Start/Jump address.

    <#lt>Returns:
    <#lt>    None

    <#lt>Example:
    <#lt>    <code>

    <#lt>        NVMCTRL_Initialize();

    <#lt>        PORT_Initialize();

    <#lt>        if (bootloader_Trigger() == false)
    <#lt>        {
    <#lt>            run_Application(APP_START_ADDRESS);
    <#lt>        }

    <#lt>        CLOCK_Initialize();

    <#lt>    </code>
    <#lt>*/
    <#lt>void run_Application( uint32_t address );
</#if>

// *****************************************************************************
/* Function:
    uint32_t bootloader_CRCGenerate(uint32_t start_addr, uint32_t size)

Summary:
    Generates CRC on the contents of Flash memory from the given start address and size

Description:
    This function can be used to verify the programmed image in flash when a Verify
    command is received from the host

Precondition:
    The application binary is already programmed in flash memory

Parameters:
    start_addr - Start address of flash memory to calculate the CRC from
    size - Size of the memory area to calculate CRC for

Returns:
    Returns the calculated CRC

Example:
    <code>
        uint32_t appImageStartAddr;
        uint32_t appImageSize;
        uint32_t receivedCRC;

        appImageStartAddr = 0x00002000;
        appImageSize = 0x8000;

        // receivedCRC is populated based on the Verify command received from the host

        if (bootloader_CRCGenerate(appImageStartAddr, appImageSize) != receivedCRC)
        {
            // CRC mismatch
        }
        else
        {
            // CRC matches
        }

    </code>
*/

uint32_t bootloader_CRCGenerate(uint32_t start_addr, uint32_t size);

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
        // Make sure all transfers are complete before resetting the device

        bootloader_TriggerReset();

    </code>
*/
void bootloader_TriggerReset(void);

<#if (core.CoreArchitecture == "MIPS") &&
     ((BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true) ||
      (BTL_DUAL_BANK?? && BTL_DUAL_BANK == true)) >
    <#lt>/* Function to read the Serial number from Flash bank mapped to lower region */
    <#lt>uint32_t bootloader_GetLowerFlashSerial(void);

    <#lt>/* Function to update the serial number based on address */
    <#lt>void bootloader_UpdateFlashSerial(uint32_t serial, uint32_t addr);

    <#lt>/* Function to update the serial number in upper flash panel (Inactive Panel) */
    <#lt>void bootloader_UpdateUpperFlashSerial(void);

    <#if BTL_DUAL_BANK?? && BTL_DUAL_BANK == true >
        <#lt>/* Function to mark the Upper flash erase status */
        <#lt>void bootloader_SetUpperFlashSerialErased(bool erased);
    </#if>
</#if>

<#if BTL_WDOG_ENABLE?? &&  BTL_WDOG_ENABLE == true>
/* Function to refresh watchdog timer */
void kickdog(void);
</#if>

#endif      //BOOTLOADER_COMMON_H