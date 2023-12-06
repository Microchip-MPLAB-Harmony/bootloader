/*******************************************************************************
  Bootloader Common Source File

  File Name:
    bootloader_common.c

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

#include "bootloader_common.h"

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

/* Bootloader Major and Minor version sent for a Read Version command (MAJOR.MINOR)*/
#define BTL_MAJOR_VERSION       3U
#define BTL_MINOR_VERSION       7U
#define ASM_VECTOR(address)     asm("bx %0"::"r" (address))

// *****************************************************************************
// *****************************************************************************
// Section: Global objects
// *****************************************************************************
// *****************************************************************************


// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Local Functions
// *****************************************************************************
// *****************************************************************************


// *****************************************************************************
// *****************************************************************************
// Section: Bootloader Global Functions
// *****************************************************************************
// *****************************************************************************

/* MISRA C-2012 Rule 8.6 and 5.8 deviated below. Deviation record ID -
   H3_MISRAC_2012_R_8_6_DR_1, H3_MISRAC_2012_R_5_8_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate "MISRA C-2012 Rule 8.6" "H3_MISRAC_2012_R_8_6_DR_1" )\
(deviate "MISRA C-2012 Rule 5.8" "H3_MISRAC_2012_R_5_8_DR_1" )
</#if>
bool __WEAK bootloader_Trigger(void)
{
    /* Function can be overriden with custom implementation */
    return false;
}

void __WEAK SYS_DeInitialize( void *data )
{
    /* Function can be overriden with custom implementation */
}

uint16_t __WEAK bootloader_GetVersion( void )
{
    /* Function can be overriden with custom implementation */
    uint16_t btlVersion = (((BTL_MAJOR_VERSION & (uint16_t)0xFFU) << 8) | (BTL_MINOR_VERSION & (uint16_t)0xFFU));

    return btlVersion;
}
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 5.8"
#pragma coverity compliance end_block "MISRA C-2012 Rule 8.6"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>

/* MISRA C-2012 Rule 10.1, 10.4, 11.1, 11.6 deviated below. Deviation record ID -
   H3_MISRAC_2012_R_10_1_DR_1, H3_MISRAC_2012_R_10_4_DR_1, H3_MISRAC_2012_R_11_1_DR_1 & H3_MISRAC_2012_R_11_6_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:2 "MISRA C-2012 Rule 10.1" "H3_MISRAC_2012_R_10_1_DR_1" )\
(deviate:2 "MISRA C-2012 Rule 10.4" "H3_MISRAC_2012_R_10_4_DR_1" )\
(deviate:2 "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1" )\
(deviate:2 "MISRA C-2012 Rule 11.6" "H3_MISRAC_2012_R_11_6_DR_1" )
</#if>

/* Function to Generate CRC by reading the firmware programmed from external media memory */
uint32_t bootloader_CRCGenerate(uint8_t *start_addr, uint32_t size, uint32_t crc)
{
    uint32_t   i, j, value;
    uint32_t   crc_tab[256];
    uint8_t    data;

    for (i = 0; i < 256U; i++)
    {
        value = i;

        for (j = 0; j < 8U; j++)
        {
            if ((value & 1U) != 0U)
            {
                value = (value >> 1) ^ 0xEDB88320U;
            }
            else
            {
                value >>= 1;
            }
        }
        crc_tab[i] = value;
    }

    for (i = 0; i < size; i++)
    {
        data = start_addr[i];
        crc = crc_tab[(crc ^ data) & 0xffU] ^ (crc >> 8);
    }

    return crc;
}

/* Trigger a reset */
void bootloader_TriggerReset(void)
{
    /* Issue reset command */
    RSTC_REGS->RSTC_CR = RSTC_CR_KEY_PASSWD | RSTC_CR_PROCRST_Msk;

    /* Wait for command processing */
    while ((RSTC_REGS->RSTC_SR & (uint32_t)RSTC_SR_SRCMP_Msk) != 0U)
    {
        // Wait
    }

    /* Prevent any unwanted code execution until reset occurs */
    while(true)
    {
        // Do nothing
    }
}


void run_Application(uint32_t address)
{
    uint32_t entry = *(uint32_t *)address;

    if ((entry == 0U) || (entry == 0xffffffffU))
    {
        return;
    }

    /* Call Deinitialize routine to free any resources acquired by Bootloader */
    SYS_DeInitialize(NULL);

    ASM_VECTOR(address);
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 10.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 10.4"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.6"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>
</#if>
/* MISRAC 2012 deviation block end */