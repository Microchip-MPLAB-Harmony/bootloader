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

#include "bootloader_common.h"

// *****************************************************************************
// *****************************************************************************
// Section: Type Definitions
// *****************************************************************************
// *****************************************************************************

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

<#if BTL_HW_CRC_GEN?? && BTL_HW_CRC_GEN == true>
    <#lt>/* Function to Generate CRC using the device service unit peripheral on programmed data */
    <#lt>uint32_t bootloader_CRCGenerate(uint32_t start_addr, uint32_t size)
    <#lt>{
    <#lt>    uint32_t crc  = 0;

    <#lt>    PAC_PeripheralProtectSetup (PAC_PERIPHERAL_DSU, PAC_PROTECTION_CLEAR);

    <#lt>    DSU_CRCCalculate (
    <#lt>       start_addr,
    <#lt>       size,
    <#lt>       0xffffffff,
    <#lt>       &crc
    <#lt>   );

    <#lt>    PAC_PeripheralProtectSetup (PAC_PERIPHERAL_DSU, PAC_PROTECTION_SET);

    <#lt>    return crc;
    <#lt>}
<#else>
    <#lt>/* Function to Generate CRC by reading the firmware programmed into internal flash */
    <#lt>uint32_t bootloader_CRCGenerate(uint32_t start_addr, uint32_t size)
    <#lt>{
    <#lt>    uint32_t   i, j, value;
    <#lt>    uint32_t   crc_tab[256];
    <#lt>    uint32_t   crc = 0xffffffff;
    <#lt>    uint8_t    data;

    <#lt>    for (i = 0; i < 256; i++)
    <#lt>    {
    <#lt>        value = i;

    <#lt>        for (j = 0; j < 8; j++)
    <#lt>        {
    <#lt>            if (value & 1)
    <#lt>            {
    <#lt>                value = (value >> 1) ^ 0xEDB88320;
    <#lt>            }
    <#lt>            else
    <#lt>            {
    <#lt>                value >>= 1;
    <#lt>            }
    <#lt>        }
    <#lt>        crc_tab[i] = value;
    <#lt>    }

    <#lt>    for (i = 0; i < size; i++)
    <#lt>    {
    <#lt>        <#if __PROCESSOR?matches("PIC32M.*") == false>
    <#lt>        data = *(uint8_t *)(start_addr + i);
    <#lt>        <#else>
    <#lt>        data = *(uint8_t *)KVA0_TO_KVA1((start_addr + i));
    <#lt>        </#if>
    <#lt>
    <#lt>        crc = crc_tab[(crc ^ data) & 0xff] ^ (crc >> 8);
    <#lt>    }
    <#lt>    return crc;
    <#lt>}
</#if>

<#if __PROCESSOR?matches("PIC32M.*") == false>
/* Trigger a reset */
void bootloader_TriggerReset(void)
{
    NVIC_SystemReset();
}

void run_Application(void)
{
    uint32_t msp            = *(uint32_t *)(APP_START_ADDRESS);
    uint32_t reset_vector   = *(uint32_t *)(APP_START_ADDRESS + 4);

    if (msp == 0xffffffff)
    {
        return;
    }

    __set_MSP(msp);

    asm("bx %0"::"r" (reset_vector));
}
<#else>

/* Trigger a reset */
void bootloader_TriggerReset(void)
{
    /* Perform system unlock sequence */
    SYSKEY = 0x00000000;
    SYSKEY = 0xAA996655;
    SYSKEY = 0x556699AA;

    RSWRSTSET = _RSWRST_SWRST_MASK;
    (void)RSWRST;
}

void run_Application(void)
{
    uint32_t msp            = *(uint32_t *)(APP_START_ADDRESS);

    void (*fptr)(void);

    /* Set default to APP_RESET_ADDRESS */
    fptr = (void (*)(void))APP_START_ADDRESS;

    if (msp == 0xffffffff)
    {
        return;
    }

    fptr();
}
</#if>


bool __WEAK bootloader_Trigger(void)
{
    /* Function can be overriden with custom implementation */
    return false;
}

