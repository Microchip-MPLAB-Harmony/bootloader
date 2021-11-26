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

#include "definitions.h" /* for potential custom handler names */
<#if core.CoreSysIntFile?? && core.CoreSysIntFile == true >
    <lt>#include "device_vectors.h"
</#if>
#include <libpic32c.h>
#include <sys/cdefs.h>
#include <stdbool.h>

/* Initialize segments */
extern uint32_t _sfixed;
extern void _ram_end_(void);

extern int main(void);

<#if core.CoreSysIntFile?? && core.CoreSysIntFile == false >

/* Declaration of Reset handler (may be custom) */
void __attribute__((noinline)) Reset_Handler(void);

__attribute__ ((used, section(".vectors")))
void (* const vectors[])(void) =
{
  &_ram_end_,
  Reset_Handler,
};

</#if>

/**
 * \brief This is the code that gets called on processor reset.
 * To initialize the device, and call the main() routine.
 */

/* Linker-defined symbols for data initialization. */
extern uint32_t _sdata, _edata, _etext;
extern uint32_t _sbss, _ebss;
<#if core.CoreSysIntFile?? && core.CoreSysIntFile == true >
    <lt>extern uint32_t _vectors_loadaddr;
</#if>

void __attribute__((noinline, section(".romfunc.Reset_Handler"))) Reset_Handler(void)
{
<#if core.RAM_INIT?? && core.DeviceFamily == "PIC32CM_JH00_JH01">
    <#lt>    register uint32_t *pRam;

    <#if BTL_WDOG_ENABLE?? && BTL_WDOG_ENABLE == true>
        <#lt>    register uint32_t wdt_ctrl = 0;

        <#lt>    /* Save the WDT control register to be restored after RAM init is complete */
        <#lt>    wdt_ctrl = WDT_REGS->WDT_CTRLA;

        <#lt>    if ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_ENABLE_Msk) && (!(WDT_REGS->WDT_CTRLA & WDT_CTRLA_ALWAYSON_Msk)))
        <#lt>    {
        <#lt>        /* Wait for synchronization */
        <#lt>        while(WDT_REGS->WDT_SYNCBUSY != 0U)
        <#lt>        {

        <#lt>        }

        <#lt>        /* Disable Watchdog Timer */
        <#lt>        WDT_REGS->WDT_CTRLA &= (uint8_t)(~WDT_CTRLA_ENABLE_Msk);

        <#lt>        /* Wait for synchronization */
        <#lt>        while(WDT_REGS->WDT_SYNCBUSY != 0U)
        <#lt>        {

        <#lt>        }
        <#lt>    }

        <#lt>    if ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_WEN_Msk) && (WDT_REGS->WDT_CTRLA & WDT_CTRLA_ALWAYSON_Msk))
        <#lt>    {
        <#lt>        while(WDT_REGS->WDT_SYNCBUSY != 0U)
        <#lt>        {

        <#lt>        }

        <#lt>        /* Disable window mode */
        <#lt>        WDT_REGS->WDT_CTRLA &= (uint8_t)(~WDT_CTRLA_WEN_Msk);

        <#lt>        while(WDT_REGS->WDT_SYNCBUSY != 0U)
        <#lt>        {

        <#lt>        }
        <#lt>    }

        <#lt>    __DSB();
        <#lt>    __ISB();
    </#if>

    <#lt>    // MCRAMC initialization loop (to handle ECC properly)
    <#lt>    // Write to entire RAM (leaving initial 16 bytes) to initialize ECC checksum
    <#lt>    for (pRam = (uint32_t*)&_sdata ; pRam < (uint32_t*)&_ram_end_; pRam++)
    <#lt>    {
    <#lt>        *pRam = 0;

    <#if BTL_WDOG_ENABLE?? && BTL_WDOG_ENABLE == true>
        <#lt>        if ((WDT_REGS->WDT_SYNCBUSY & WDT_SYNCBUSY_CLEAR_Msk) != WDT_SYNCBUSY_CLEAR_Msk)
        <#lt>        {
        <#lt>
        <#lt>            /* Clear WDT and reset the WDT timer before the
        <#lt>            timeout occurs */
        <#lt>            WDT_REGS->WDT_CLEAR = (uint8_t)WDT_CLEAR_CLEAR_KEY;
        <#lt>        }
    </#if>
    <#lt>    }

    <#lt>    __DSB();
    <#lt>    __ISB();

    <#if BTL_WDOG_ENABLE?? && BTL_WDOG_ENABLE == true>
        <#lt>    /* Wait for synchronization */
        <#lt>    while(WDT_REGS->WDT_SYNCBUSY != 0U)
        <#lt>    {

        <#lt>    }

        <#lt>    /* Restore back the WDT control register */
        <#lt>    WDT_REGS->WDT_CTRLA = wdt_ctrl;

        <#lt>    /* Wait for synchronization */
        <#lt>    while(WDT_REGS->WDT_SYNCBUSY != 0U)
        <#lt>    {

        <#lt>    }
    </#if>
</#if>

    uint32_t *pSrc, *pDst;

<#if core.CoreSysIntFile?? && core.CoreSysIntFile == true >
    uint32_t i;
    pSrc = (uint32_t *) &_vectors_loadaddr; /* flash address */
    pDst = (uint32_t *) &_sfixed;

    /* Copy .vectors section from flash to RAM */
    for (i = 0; i < sizeof(H3DeviceVectors)/4; i++)
    {
        *pDst++ = *pSrc++;
    }
</#if>

    pSrc = (uint32_t *) &_etext; /* flash functions start after .text */
    pDst = (uint32_t *) &_sdata;  /* boundaries of .data area to init */

    /* Init .data */
    while (pDst < &_edata)
        *pDst++ = *pSrc++;

    /* Init .bss */
    pDst = &_sbss;
    while (pDst < &_ebss)
      *pDst++ = 0;

<#if core.CoreSysIntFile?? && core.CoreSysIntFile == true >
    <#lt>#if defined (__VTOR_PRESENT) && (__VTOR_PRESENT == 1U)
    <#lt>    /*  Set the vector-table base address in RAM */
    <#lt>    pSrc = (uint32_t *) & _sfixed;
    <#lt>    SCB->VTOR = ((uint32_t) pSrc & SCB_VTOR_TBLOFF_Msk);
    <#lt>#endif /* #if defined (__VTOR_PRESENT) && (__VTOR_PRESENT == 1U) */
</#if>

     /* Branch to application's main function */
    main();

#if (defined(__DEBUG) || defined(__DEBUG_D)) && defined(__XC32)
    __builtin_software_breakpoint();
#endif
}
