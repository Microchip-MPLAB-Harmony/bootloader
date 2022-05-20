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

/* Bootloader Major and Minor version sent for a Read Version command (MAJOR.MINOR)*/
#define BTL_MAJOR_VERSION       3
#define BTL_MINOR_VERSION       6

<#if __PROCESSOR?matches("PIC32M.*") == true>
    <#lt>#define WORD_ALIGN_MASK         (~(sizeof(uint32_t) - 1))

</#if>
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


<#if (BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == false) ||
     (!BTL_LIVE_UPDATE??) >
    <#lt>bool __WEAK bootloader_Trigger(void)
    <#lt>{
    <#lt>    /* Function can be overriden with custom implementation */
    <#lt>    return false;
    <#lt>}
</#if>

void __WEAK SYS_DeInitialize( void *data )
{
    /* Function can be overriden with custom implementation */
}

uint16_t __WEAK bootloader_GetVersion( void )
{
    /* Function can be overriden with custom implementation */
    uint16_t btlVersion = (((BTL_MAJOR_VERSION & 0xFF) << 8) | (BTL_MINOR_VERSION & 0xFF));

    return btlVersion;
}

<#if BTL_WDOG_ENABLE?? &&  BTL_WDOG_ENABLE == true>
    <#if (__PROCESSOR?matches("PIC32M.*") == true) || (__PROCESSOR?matches("PIC32CX.*") == true) >
        <#lt>void kickdog(void)
        <#lt>{
        <#lt>    if ((WDT_IsEnabled() == true) && (WDT_IsWindowEnabled() == false))
        <#lt>    {
        <#lt>        WDT_Clear();
        <#lt>    }
        <#lt>}
    <#else>
        <#lt>void kickdog(void)
        <#lt>{
        <#lt>    if ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_ALWAYSON_Msk) || (WDT_REGS->WDT_CTRLA & WDT_CTRLA_ENABLE_Msk))
        <#lt>    {
        <#lt>        if (WDT_REGS->WDT_CTRLA & WDT_CTRLA_WEN_Msk)
        <#lt>        {
        <#lt>            if (WDT_REGS->WDT_INTFLAG & WDT_INTFLAG_EW_Msk)
        <#lt>            {
        <#lt>                if ((WDT_REGS->WDT_SYNCBUSY & WDT_SYNCBUSY_CLEAR_Msk) != WDT_SYNCBUSY_CLEAR_Msk)
        <#lt>                {

        <#lt>                    /* Clear WDT and reset the WDT timer before the
        <#lt>                    timeout occurs */
        <#lt>                    WDT_REGS->WDT_CLEAR = (uint8_t)WDT_CLEAR_CLEAR_KEY;

        <#lt>                    WDT_REGS->WDT_INTFLAG |= WDT_INTFLAG_EW_Msk;
        <#lt>                }
        <#lt>            }
        <#lt>        }
        <#lt>        else
        <#lt>        {
        <#lt>            if ((WDT_REGS->WDT_SYNCBUSY & WDT_SYNCBUSY_CLEAR_Msk) != WDT_SYNCBUSY_CLEAR_Msk)
        <#lt>            {

        <#lt>                /* Clear WDT and reset the WDT timer before the timeout occurs */
        <#lt>                WDT_REGS->WDT_CLEAR = (uint8_t)WDT_CLEAR_CLEAR_KEY;
        <#lt>            }
        <#lt>        }
        <#lt>    }
        <#lt>}
    </#if>
</#if>


<#if BTL_HW_CRC_GEN?? && BTL_HW_CRC_GEN == true>
    <#lt>/* Function to Generate CRC using the device service unit peripheral on programmed data */
    <#lt>uint32_t bootloader_CRCGenerate(uint32_t start_addr, uint32_t size)
    <#lt>{
    <#lt>    uint32_t crc  = 0xffffffff;

    <#lt>    PAC_PeripheralProtectSetup (PAC_PERIPHERAL_DSU, PAC_PROTECTION_CLEAR);

    <#if BTL_WDOG_ENABLE?? &&  BTL_WDOG_ENABLE == true>
        <#lt>    uint32_t i;

        <#lt>    for (i = 0; i < size; i += ERASE_BLOCK_SIZE)
        <#lt>    {
        <#lt>       DSU_CRCCalculate (
        <#lt>           start_addr + i,
        <#lt>           ERASE_BLOCK_SIZE,
        <#lt>           crc,
        <#lt>           &crc
        <#lt>       );

        <#lt>       kickdog();
        <#lt>    }
    <#else>
        <#lt>    DSU_CRCCalculate (start_addr, size, crc, &crc);
    </#if>

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

    <#if BTL_WDOG_ENABLE?? &&  BTL_WDOG_ENABLE == true>
        <#lt>    kickdog();

        <#lt>    for (i = 0; i < size; i += ERASE_BLOCK_SIZE)
        <#lt>    {
        <#lt>        for (j = 0; j < ERASE_BLOCK_SIZE; j++)
        <#lt>        {
        <#if __PROCESSOR?matches("PIC32M.*") == false>
            <#lt>            data = *(uint8_t *)(start_addr + (i + j));
        <#else>
            <#lt>            data = *(uint8_t *)KVA0_TO_KVA1((start_addr + (i + j)));
        </#if>

        <#lt>            crc = crc_tab[(crc ^ data) & 0xff] ^ (crc >> 8);
        <#lt>        }
        <#lt>        kickdog();
        <#lt>    }
    <#else>
        <#lt>    for (i = 0; i < size; i++)
        <#lt>    {
        <#if __PROCESSOR?matches("PIC32M.*") == false>
            <#lt>        data = *(uint8_t *)(start_addr + i);
        <#else>
            <#lt>        data = *(uint8_t *)KVA0_TO_KVA1((start_addr + i));
        </#if>

        <#lt>        crc = crc_tab[(crc ^ data) & 0xff] ^ (crc >> 8);
        <#lt>    }
    </#if>

    <#lt>    return crc;
    <#lt>}

</#if>

<#if __PROCESSOR?matches("PIC32M.*") == false>
    <#lt>/* Trigger a reset */
    <#lt>void __NO_RETURN bootloader_TriggerReset(void)
    <#lt>{
    <#lt>    NVIC_SystemReset();
    <#lt>}

    <#if (BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == false) ||
         (!BTL_LIVE_UPDATE??) >
        <#lt>void run_Application(uint32_t address)
        <#lt>{
        <#lt>    uint32_t msp            = *(uint32_t *)(address);
        <#lt>    uint32_t reset_vector   = *(uint32_t *)(address + 4);

        <#lt>    if (msp == 0xffffffff)
        <#lt>    {
        <#lt>        return;
        <#lt>    }

        <#lt>    /* Call Deinitialize routine to free any resources acquired by Bootloader */
        <#lt>    SYS_DeInitialize(NULL);

        <#lt>    __set_MSP(msp);

        <#lt>    asm("bx %0"::"r" (reset_vector));
        <#lt>}
    </#if>
<#else>
    <#lt>/* Trigger a reset */
    <#lt>void bootloader_TriggerReset(void)
    <#lt>{
    <#lt>    /* Perform system unlock sequence */
    <#lt>    SYSKEY = 0x00000000;
    <#lt>    SYSKEY = 0xAA996655;
    <#lt>    SYSKEY = 0x556699AA;

    <#lt>    RSWRSTSET = _RSWRST_SWRST_MASK;
    <#lt>    (void)RSWRST;
    <#lt>}

    <#if (BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == false) ||
         (!BTL_LIVE_UPDATE??) >
        <#lt>void run_Application(uint32_t address)
        <#lt>{
        <#lt>    uint32_t jumpAddrVal = *(uint32_t *)(address & WORD_ALIGN_MASK);

        <#lt>    void (*fptr)(void);

        <#lt>    fptr = (void (*)(void))address;

        <#lt>    if (jumpAddrVal == 0xffffffff)
        <#lt>    {
        <#lt>        return;
        <#lt>    }

        <#lt>    /* Call Deinitialize routine to free any resources acquired by Bootloader */
        <#lt>    SYS_DeInitialize(NULL);

        <#lt>    __builtin_disable_interrupts();

        <#lt>    fptr();
        <#lt>}
    </#if>
</#if>

<#if (core.CoreArchitecture == "MIPS") &&
     ((BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true) ||
      (BTL_DUAL_BANK?? && BTL_DUAL_BANK == true)) >
    <#lt>T_FLASH_SERIAL CACHE_ALIGN  update_flash_serial;

    <#lt>/* Function to read the Serial number from Flash bank mapped to lower region */
    <#lt>uint32_t bootloader_GetLowerFlashSerial(void)
    <#lt>{
    <#lt>    T_FLASH_SERIAL *lower_flash_serial = LOWER_FLASH_SERIAL_READ;

    <#lt>    return (lower_flash_serial->serial);
    <#lt>}

    <#lt>/* Function to update the serial number based on address */
    <#lt>void bootloader_UpdateFlashSerial(uint32_t serial, uint32_t addr)
    <#lt>{
    <#lt>    update_flash_serial.serial         = serial;
    <#lt>    update_flash_serial.prologue       = FLASH_SERIAL_PROLOGUE;
    <#lt>    update_flash_serial.epilogue       = FLASH_SERIAL_EPILOGUE;

    <#lt>    ${MEM_USED}_QuadWordWrite((uint32_t *)&update_flash_serial, addr);

    <#lt>    while(${MEM_USED}_IsBusy() == true);
    <#lt>}

    <#if BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true >
        <#lt>/* Function to update the serial number in upper flash panel (Inactive Panel) */
        <#lt>void bootloader_UpdateUpperFlashSerial(void)
        <#lt>{
        <#lt>    uint32_t upper_flash_serial;

        <#lt>    /* Increment Upper Mapped Flash panel serial by 1 to be ahead of the
        <#lt>     * current running Lower Mapped Flash panel serial
        <#lt>     */
        <#lt>    upper_flash_serial = bootloader_GetLowerFlashSerial() + 1;

        <#lt>    bootloader_UpdateFlashSerial(upper_flash_serial, UPPER_FLASH_SERIAL_START);
        <#lt>}
    <#elseif BTL_DUAL_BANK?? && BTL_DUAL_BANK == true >
        <#lt>volatile uint32_t   dummy_read;

        <#lt>static bool         upper_flash_serial_erased   = false;

        <#lt>void bootloader_SetUpperFlashSerialErased(bool erased)
        <#lt>{
        <#lt>    upper_flash_serial_erased = erased;
        <#lt>}

        <#lt>/* Function to update the serial number in upper flash panel (Inactive Panel) */
        <#lt>void bootloader_UpdateUpperFlashSerial(void)
        <#lt>{
        <#lt>    uint32_t upper_flash_serial;

        <#lt>    /* Increment Upper Mapped Flash panel serial by 1 to be ahead of the
        <#lt>     * current running Lower Mapped Flash panel serial
        <#lt>     */
        <#lt>    upper_flash_serial = bootloader_GetLowerFlashSerial() + 1;

        <#lt>    /* Check if the Serial sector was erased during programming */
        <#lt>    if (upper_flash_serial_erased == false)
        <#lt>    {
        <#lt>        /* Erase the Sector in which Flash Serial Resides */
        <#lt>        ${.vars["${MEM_USED?lower_case}"].ERASE_API_NAME}(UPPER_FLASH_SERIAL_SECTOR);

        <#lt>        /* Wait for erase to complete */
        <#lt>        while(${MEM_USED}_IsBusy() == true);
        <#lt>    }
        <#lt>    else
        <#lt>    {
        <#lt>        bootloader_SetUpperFlashSerialErased(false);
        <#lt>    }

        <#lt>    bootloader_UpdateFlashSerial(upper_flash_serial, UPPER_FLASH_SERIAL_START);
        <#lt>}

        <#lt>/* Function to swap the banks.
        <#lt> * This function has to be removed once NVM PLIB has the support
        <#lt> */
        <#lt>static void bootloader_ProgramFlashSwapBank( T_FLASH_BANK flash_bank )
        <#lt>{
        <#lt>    /* NVMOP can be written only when WREN is zero. So, clear WREN */
        <#lt>    NVMCONCLR = _NVMCON_WREN_MASK;

        <#lt>    /* Write the unlock key sequence */
        <#lt>    NVMKEY = 0x0;
        <#lt>    NVMKEY = 0xAA996655;
        <#lt>    NVMKEY = 0x556699AA;

        <#lt>    if (flash_bank == PROGRAM_FLASH_BANK_1)
        <#lt>    {
        <#lt>        /* Map Program Flash Memory Bank 1 to lower region */
        <#lt>        NVMCONCLR = _NVMCON_PFSWAP_MASK;
        <#lt>    }
        <#lt>    else if (flash_bank == PROGRAM_FLASH_BANK_2)
        <#lt>    {
        <#lt>        /* Map Program Flash Memory Bank 2 to lower region */
        <#lt>        NVMCONSET = _NVMCON_PFSWAP_MASK;
        <#lt>    }
        <#lt>}

        <#lt>/* Function to Select Appropriate program flash bank based on the serial number */
        <#lt>void bootloader_ProgramFlashBankSelect( void )
        <#lt>{
        <#lt>    /* Map Program Flash Bank 1 to lower region after a reset */
        <#lt>    bootloader_ProgramFlashSwapBank(PROGRAM_FLASH_BANK_1);

        <#lt>    T_FLASH_SERIAL *lower_flash_serial = LOWER_FLASH_SERIAL_READ;
        <#lt>    T_FLASH_SERIAL *upper_flash_serial = UPPER_FLASH_SERIAL_READ;

        <#lt>    /* If Both Flash Panels do not have any Serial number */
        <#lt>    if( lower_flash_serial->prologue == FLASH_SERIAL_CLEAR &&
        <#lt>        upper_flash_serial->prologue == FLASH_SERIAL_CLEAR)
        <#lt>    {
        <#lt>        /* Program Checksum and initial ID's for both panels*/
        <#lt>        bootloader_UpdateFlashSerial(0, LOWER_FLASH_SERIAL_START);
        <#lt>        bootloader_UpdateFlashSerial(0, UPPER_FLASH_SERIAL_START);
        <#lt>    }
        <#lt>    /* If both the panels have proper checksum and serial number*/
        <#lt>    else if((lower_flash_serial->prologue == FLASH_SERIAL_PROLOGUE) &&
        <#lt>        (lower_flash_serial->epilogue == FLASH_SERIAL_EPILOGUE) &&
        <#lt>        (upper_flash_serial->prologue == FLASH_SERIAL_PROLOGUE) &&
        <#lt>        (upper_flash_serial->epilogue == FLASH_SERIAL_EPILOGUE))
        <#lt>    {
        <#lt>        /* If Upper flash panel has latest firmware */
        <#lt>        if(upper_flash_serial->serial > lower_flash_serial->serial)
        <#lt>        {
        <#lt>            /* Map Program Flash Bank 2 to lower region */
        <#lt>            bootloader_ProgramFlashSwapBank(PROGRAM_FLASH_BANK_2);

        <#lt>            /* Perform Dummy Read of Inactive panel(Upper Flash) after BankSwap
        <#lt>             * for Swap to take effect
        <#lt>             */
        <#lt>            dummy_read = *(uint32_t *)(UPPER_FLASH_START);
        <#lt>        }
        <#lt>    }
        <#lt>    /* Fallback Case when Panel 1 checksum and serial number is corrupted */
        <#lt>    else if((upper_flash_serial->prologue == FLASH_SERIAL_PROLOGUE) &&
        <#lt>            (upper_flash_serial->epilogue == FLASH_SERIAL_EPILOGUE))
        <#lt>    {
        <#lt>        /* Map Program Flash Bank 2 to lower region */
        <#lt>        bootloader_ProgramFlashSwapBank(PROGRAM_FLASH_BANK_2);

        <#lt>        /* Perform Dummy Read of Inactive panel(Upper Flash) after BankSwap
        <#lt>         * for Swap to take effect
        <#lt>         */
        <#lt>        dummy_read = *(uint32_t *)(UPPER_FLASH_START);
        <#lt>    }
        <#lt>}
    </#if>
</#if>

<#if BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true >
    <#lt>void bootloader_SwapAndReset( void )
    <#lt>{
        <#if core.CoreArchitecture == "MIPS" >
            <#lt>    /* Update Serial number of Inactive bank */
            <#lt>    bootloader_UpdateUpperFlashSerial();

            <#lt>    bootloader_TriggerReset();
        <#else>
            <#lt>    /* Swap bank and Reset */
            <#lt>    ${MEM_USED}_BankSwap();
        </#if>
    <#lt>}
</#if>