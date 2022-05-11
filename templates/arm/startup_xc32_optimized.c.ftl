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
    <#lt>#include "device_vectors.h"
</#if>
#include <libpic32c.h>
#include <sys/cdefs.h>
#include <stdbool.h>

/* Initialize segments */
extern uint32_t _sfixed;
extern void _ram_end_(void);

extern int main(void);

<#if core.CoreSysIntFile?? && core.CoreSysIntFile == false >

    <#lt>/* Declaration of Reset handler (may be custom) */
    <#lt>void __attribute__((noinline)) Reset_Handler(void);

    <#lt>__attribute__ ((used, section(".vectors")))
    <#lt>void (* const vectors[])(void) =
    <#lt>{
    <#lt>    &_ram_end_,
    <#lt>    Reset_Handler,
    <#lt>};
</#if>

/**
 * \brief This is the code that gets called on processor reset.
 * To initialize the device, and call the main() routine.
 */

/* Linker-defined symbols for data initialization. */
extern uint32_t _sdata, _edata, _etext;
extern uint32_t _sbss, _ebss;
<#if core.CoreSysIntFile?? && core.CoreSysIntFile == true >
    <#lt>extern uint32_t _vectors_loadaddr;
</#if>

void __attribute__((noinline, section(".romfunc.Reset_Handler"))) Reset_Handler(void)
{
<#if core.RAM_INIT?? && core.DeviceFamily == "PIC32CM_JH00_JH01">
    register uint32_t *pRam;

    // MCRAMC initialization loop (to handle ECC properly)
    // Write to entire RAM (leaving initial 16 bytes) to initialize ECC checksum
    for (pRam = (uint32_t*)&_sdata ; pRam < (uint32_t*)&_ram_end_; pRam++)
    {
        *pRam = 0;

        if ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_ALWAYSON_Msk) || (WDT_REGS->WDT_CTRLA & WDT_CTRLA_ENABLE_Msk))
        {
            if (WDT_REGS->WDT_CTRLA & WDT_CTRLA_WEN_Msk)
            {
                if (WDT_REGS->WDT_INTFLAG & WDT_INTFLAG_EW_Msk)
                {
                    if ((WDT_REGS->WDT_SYNCBUSY & WDT_SYNCBUSY_CLEAR_Msk) != WDT_SYNCBUSY_CLEAR_Msk)
                    {

                        /* Clear WDT and reset the WDT timer before the
                        timeout occurs */
                        WDT_REGS->WDT_CLEAR = (uint8_t)WDT_CLEAR_CLEAR_KEY;

                        WDT_REGS->WDT_INTFLAG |= WDT_INTFLAG_EW_Msk;
                    }
                }
            }
            else
            {
                if ((WDT_REGS->WDT_SYNCBUSY & WDT_SYNCBUSY_CLEAR_Msk) != WDT_SYNCBUSY_CLEAR_Msk)
                {

                    /* Clear WDT and reset the WDT timer before the timeout occurs */
                    WDT_REGS->WDT_CLEAR = (uint8_t)WDT_CLEAR_CLEAR_KEY;
                }
            }
        }
    }
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
