/*******************************************************************************
  ${BTL_TYPE} Bootloader Header File

  File Name:
    bootloader_${BTL_TYPE?lower_case}.h

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

#ifndef BOOTLOADER_${BTL_TYPE}_H
#define BOOTLOADER_${BTL_TYPE}_H

#include <stdint.h>
#include <stdbool.h>
#include "bootloader_common.h"

<#if core.CoreArchitecture == "MIPS">
    <#lt>#include "sys/kmem.h"
</#if>

<#if core.CoreArchitecture == "MIPS" && BTL_DUAL_BANK?? && BTL_DUAL_BANK == true >
    <#lt>// *****************************************************************************
    <#lt>/* Function:
    <#lt>    void bootloader_ProgramFlashBankSelect( void );
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
    <#lt>            run_Application(APP_JUMP_ADDRESS);
    <#lt>        }

    <#lt>    </code>
    <#lt>*/
    <#lt>void bootloader_ProgramFlashBankSelect( void );
</#if>

<#if BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true >
    <#lt>// *****************************************************************************
    <#lt>/* Function:
    <#lt>    void bootloader_SwapAndReset( void );
    <#lt>
    <#if core.CoreArchitecture == "MIPS">
        <#lt> Summary:
        <#lt>    Updates the Serial number in Inactive Bank and triggers Reset.

        <#lt> Description:
        <#lt>    This function can be used by the application to update the serial number in inactive
        <#lt>    bank and trigger reset after Live Update is Completed.

        <#lt>    Switcher in Boot Flash Memory should know the address at compile time where the serial
        <#lt>    number is stored in each bank. It reads the serial number from both banks, Compares the
        <#lt>    values and maps the bank with highest serial number to lower region.
    <#else>
        <#lt> Summary:
        <#lt>    Swaps Bank and triggers reset.

        <#lt> Description:
        <#lt>    This function can be used by the application to swap bank and trigger reset
        <#lt>    after Live Update is Completed.
    </#if>

    <#lt> Precondition:
    <#lt>    - Live Update has to be completed before calling this function

    <#lt> Parameters:
    <#lt>    None.
    <#lt>
    <#lt> Returns:
    <#lt>    None.

    <#lt> Example:
    <#lt>    <code>

    <#lt>        bootloader_SwapAndReset( void );

    <#lt>    </code>
    <#lt>*/
    <#lt>void bootloader_SwapAndReset( void );
</#if>



// *****************************************************************************
/* Function:
    void bootloader_${BTL_TYPE}_Tasks( void )

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

        bootloader_${BTL_TYPE}_Tasks();

    </code>
*/
void bootloader_${BTL_TYPE}_Tasks( void );

#endif  //BOOTLOADER_${BTL_TYPE}_H