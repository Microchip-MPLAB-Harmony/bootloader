/*******************************************************************************
  Bootloader Header File

  File Name:
    bootloader.h

  Summary:
    This file contains Interface definitions of bootloder

  Description:
    This file defines interface for bootloader.
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

#ifndef BOOTLOADER_H
#define BOOTLOADER_H

#include <stdint.h>
#include <stdbool.h>

<#if BTL_TRIGGER_ENABLE == true && BTL_TRIGGER_LEN != "0" >
    <#if core.CoreArchitecture == "MIPS">
        <#lt>#include "sys/kmem.h"

        <#lt>#define BTL_TRIGGER_RAM_START   KVA0_TO_KVA1(${BTL_RAM_START})
    <#else>
        <#lt>#define BTL_TRIGGER_RAM_START   ${BTL_RAM_START}
    </#if>

    <#lt>#define BTL_TRIGGER_LEN         ${BTL_TRIGGER_LEN}
</#if>

<#if core.CoreArchitecture == "MIPS" && BTL_DUAL_BANK?? && BTL_DUAL_BANK == true >
    <#lt>// *****************************************************************************
    <#lt>/* Function:
    <#lt>    bool bootloader_ProgramFlashBankSelect( void );
    <#lt>
    <#lt> Summary:
    <#lt>    Selects Appropriate Program Flash Bank after reset.
    <#lt>
    <#lt> Description:
    <#lt>    This function can be used to select the approproate Program flash bank based on the
    <#lt>    serial number stored in each of bank after reset.

    <#lt>    Bootloader should know the address at compile time where the serial number is stored
    <#lt>    in each bank. It reads the serial number from both banks, Compares the values and maps the
    <#lt>    bank with highest serial number to lower region.

    <#lt> Precondition:
    <#lt>    - PORT/PIO Initialize must have been called.

    <#lt>    - This Function should be called before calling bootloader_Trigger() function

    <#lt> Parameters:
    <#lt>    None.
    <#lt>
    <#lt> Returns:
    <#lt>    None.

    <#lt> Example:
    <#lt>    <code>

    <#lt>        bootloader_ProgramFlashBankSelect( void );

    <#lt>        if (bootloader_Trigger() == false)
    <#lt>        {
    <#lt>            run_Application();
    <#lt>        }

    <#lt>    </code>
    <#lt>*/
    <#lt>void bootloader_ProgramFlashBankSelect( void );
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
            run_Application();
        }

        CLOCK_Initialize();

    </code>
*/
bool bootloader_Trigger( void );

// *****************************************************************************
/* Function:
    void run_Application( void );

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
    None.

 Returns:
    None

 Example:
    <code>

        NVMCTRL_Initialize();

        PORT_Initialize();

        if (bootloader_Trigger() == false)
        {
            run_Application();
        }

        CLOCK_Initialize();

    </code>
*/
void run_Application( void );

// *****************************************************************************
/* Function:
    void bootloader_Tasks( void );

 Summary:
    Starts bootloader execution.

 Description:
    This function can be used to start bootloader execution.

    The function continuously waits for application firmware from the HOST via
    selected communication protocol to program into internal flash memory.

    Once the complete application is received, programmed and verified successfully,
    It resets the device to jump into programmed application.

    Note:
    For Optimized Bootloaders:
        - This function never returns.
        - This function will be directly called from main function

    For Unified and File System based Bootloaders:
        - This function returns once the state machine execution is completed
        - This function will be called from SYS_Tasks() routine from the super loop

 Precondition:
    bootloader_Trigger() must be called to check for bootloader triggers at startup.

 Parameters:
    None.

 Returns:
    None

 Example:
    <code>

        bootloader_Tasks();

    </code>
*/
void bootloader_Tasks( void );

#endif