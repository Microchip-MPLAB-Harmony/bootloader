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

#define BOOTLOADER_SIZE                         ${BTL_SIZE}
<#if __PROCESSOR?matches("PIC32M.*") == false>
#define APP_START_ADDRESS                       (0x${core.APP_START_ADDRESS}UL)
<#else>
#define APP_START_ADDRESS                       (PA_TO_KVA0(0x${core.APP_START_ADDRESS}UL))
</#if>

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
    <#lt>            run_Application();
    <#lt>        }

    <#lt>        CLOCK_Initialize();

    <#lt>    </code>
    <#lt>*/
    <#lt>bool bootloader_Trigger( void );

    <#lt>// *****************************************************************************
    <#lt>/* Function:
    <#lt>    void run_Application( void );

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
    <#lt>    None.

    <#lt>Returns:
    <#lt>    None

    <#lt>Example:
    <#lt>    <code>

    <#lt>        NVMCTRL_Initialize();

    <#lt>        PORT_Initialize();

    <#lt>        if (bootloader_Trigger() == false)
    <#lt>        {
    <#lt>            run_Application();
    <#lt>        }

    <#lt>        CLOCK_Initialize();

    <#lt>    </code>
    <#lt>*/
    <#lt>void run_Application( void );
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

#endif      //BOOTLOADER_COMMON_H