/*******************************************************************************
  System Initialization File

  File Name:
    initialization.c

  Summary:
    This file contains source code necessary to initialize the system.

  Description:
    This file contains source code necessary to initialize the system.  It
    implements the "SYS_Initialize" function, defines the configuration bits,
    and allocates any necessary global system resources,
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
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
<#if HarmonyCore??>
    <#if HarmonyCore.ENABLE_DRV_COMMON == true ||
         HarmonyCore.ENABLE_SYS_COMMON == true ||
         HarmonyCore.ENABLE_APP_FILE == true >
        <#lt>#include "configuration.h"
    </#if>
</#if>
#include "definitions.h"
#include "device.h"
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
    <#if core.COMPILER_CHOICE == "XC32">


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
    </#if>
</#if>


// ****************************************************************************
// ****************************************************************************
// Section: Configuration Bits
// ****************************************************************************
// ****************************************************************************
<#if __TRUSTZONE_ENABLED?? && __TRUSTZONE_ENABLED == "true">
<#-- In case of TrustZone Fuse settings are set in secure mode -->
<#else>
${core.LIST_SYSTEM_INIT_C_CONFIG_BITS_INITIALIZATION}
</#if>


// *****************************************************************************
// *****************************************************************************
// Section: Driver Initialization Data
// *****************************************************************************
// *****************************************************************************
/* Following MISRA-C rules are deviated in the below code block */
/* MISRA C-2012 Rule 7.2 */
/* MISRA C-2012 Rule 11.1 */
/* MISRA C-2012 Rule 11.3 */
/* MISRA C-2012 Rule 11.8 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance block deviate "MISRA C-2012 Rule 7.2"  "H3_MISRAC_2012_R_7_2_DR_1"
#pragma coverity compliance block deviate "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1"
#pragma coverity compliance block deviate "MISRA C-2012 Rule 11.3" "H3_MISRAC_2012_R_11_3_DR_1"
#pragma coverity compliance block deviate "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1"
</#if>
${core.LIST_SYSTEM_INIT_C_DRIVER_INITIALIZATION_DATA}

// *****************************************************************************
// *****************************************************************************
// Section: System Data
// *****************************************************************************
// *****************************************************************************
<#if HarmonyCore??>
    <#if HarmonyCore.ENABLE_DRV_COMMON == true ||
         HarmonyCore.ENABLE_SYS_COMMON == true >
        <#lt>/* Structure to hold the object handles for the modules in the system. */
        <#lt>SYSTEM_OBJECTS sysObj;
    </#if>
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Library/Stack Initialization Data
// *****************************************************************************
// *****************************************************************************
${core.LIST_SYSTEM_INIT_C_LIBRARY_INITIALIZATION_DATA}

// *****************************************************************************
// *****************************************************************************
// Section: System Initialization
// *****************************************************************************
// *****************************************************************************
${core.LIST_SYSTEM_INIT_C_SYSTEM_INITIALIZATION}


// *****************************************************************************
// *****************************************************************************
// Section: Local initialization functions
// *****************************************************************************
// *****************************************************************************
${core.LIST_SYSTEM_INIT_C_INITIALIZER_STATIC_FUNCTIONS}


/*******************************************************************************
  Function:
    void SYS_Initialize ( void *data )

  Summary:
    Initializes the board, services, drivers, application and other modules.

  Remarks:
 */

void SYS_Initialize ( void* data )
{
    /* MISRAC 2012 deviation block start */
    /* MISRA C-2012 Rule 2.2 deviated in this file.  Deviation record ID -  H3_MISRAC_2012_R_2_2_DR_1 */
    /* MISRA C-2012 Rule 11.6 deviated in this file.  Deviation record ID -  H3_MISRAC_2012_R_11_6_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
    #pragma coverity compliance block deviate "MISRA C-2012 Rule 2.2" "H3_MISRAC_2012_R_2_2_DR_1"
    #pragma coverity compliance block deviate "MISRA C-2012 Rule 11.6" "H3_MISRAC_2012_R_11_6_DR_1"
</#if>
    /* Start out with interrupts disabled before configuring any modules */
    (void)__builtin_disable_interrupts();

    <#lt>${core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_CORE}

    <#lt>${core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_CORE1}

<#if BTL_DUAL_BANK?? && BTL_DUAL_BANK == true>
    bootloader_ProgramFlashBankSelect();
</#if>

    if (bootloader_Trigger() == false)
    {
        run_Application(APP_JUMP_ADDRESS);
    }

    <#lt>${core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_PERIPHERALS}
    /* MISRAC 2012 deviation block start */
    /* Following MISRA-C rules deviated in this block  */
    /* MISRA C-2012 Rule 11.3 - Deviation record ID - H3_MISRAC_2012_R_11_3_DR_1 */
    /* MISRA C-2012 Rule 11.8 - Deviation record ID - H3_MISRAC_2012_R_11_8_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
     #pragma coverity compliance block \
     (deviate "MISRA C-2012 Rule 11.3" "H3_MISRAC_2012_R_11_3_DR_1" )\
     (deviate "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )
</#if>
    <#lt>${core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS}
    <#lt>${core.LIST_SYSTEM_INIT_C_INITIALIZE_SYSTEM_SERVICES}
    <#lt>${core.LIST_SYSTEM_INIT_C_INITIALIZE_MIDDLEWARE}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
    #pragma coverity compliance end_block "MISRA C-2012 Rule 11.3"
    #pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
</#if>
    /* MISRAC 2012 deviation block end */
    <#if HarmonyCore??>
        <#lt><#if HarmonyCore.ENABLE_APP_FILE == true >
                <#lt>${core.LIST_SYSTEM_INIT_C_APP_INITIALIZE_DATA}
        <#lt></#if>
    </#if>
    <#lt>${core.LIST_SYSTEM_INIT_INTERRUPTS}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
    #pragma coverity compliance end_block "MISRA C-2012 Rule 11.6"
    #pragma coverity compliance end_block "MISRA C-2012 Rule 2.2"
</#if>
    /* MISRAC 2012 deviation block end */
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
    <#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop

    </#if>
</#if>
