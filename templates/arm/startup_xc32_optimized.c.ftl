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
    <#lt>#include "interrupts.h"
</#if>
#include <libpic32c.h>
#include <sys/cdefs.h>
#include <stdbool.h>
<#if core.CoreUseMPU??>
<#if core.CoreUseMPU>
#include "peripheral/mpu/plib_mpu.h"
</#if>
</#if>

/* MISRAC 2012 deviation block start */
/* MISRA C-2012 Rule 21.2 deviated 1 times. Deviation record ID -  H3_MISRAC_2012_R_21_2_DR_1 */
/* MISRA C-2012 Rule 8.6 deviated 7 times.  Deviation record ID -  H3_MISRAC_2012_R_8_6_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
#pragma coverity compliance block \
(deviate:1 "MISRA C-2012 Rule 21.2" "H3_MISRAC_2012_R_21_2_DR_1")\
(deviate:7 "MISRA C-2012 Rule 8.6" "H3_MISRAC_2012_R_8_6_DR_1")
</#if>
/* Initialize segments */
extern uint32_t _sfixed;
extern void _ram_end_(void);

extern int main(void);

<#if core.CoreSysIntFile?? && core.CoreSysIntFile == false >

    <#lt>/* Declaration of Reset handler (may be custom) */
    <#lt>void __attribute__((noinline)) Reset_Handler(void);
    <#lt>extern void (* const vectors[])(void);

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
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 8.6"
#pragma coverity compliance end_block "MISRA C-2012 Rule 21.2"
#pragma GCC diagnostic pop
</#if>
/* MISRAC 2012 deviation block end */

void __attribute__((noinline, section(".romfunc.Reset_Handler"))) Reset_Handler(void)
{
    register uint32_t count;
<#if core.RAM_INIT?? && core.DeviceFamily == "PIC32CM_JH00_JH01">
    register uint32_t *pRam = (uint32_t*)(uintptr_t)&_sdata;

    // MCRAMC initialization loop (to handle ECC properly)
    // Write to entire RAM (leaving initial 16 bytes) to initialize ECC checksum
    for (count = 0U; count < (((uint32_t)&_ram_end_ - (uint32_t)&_sdata) / 4U); count++)
    {
        pRam[count] = 0U;

        if (((WDT_REGS->WDT_CTRLA & WDT_CTRLA_ALWAYSON_Msk) != 0U) || ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_ENABLE_Msk) != 0U))
        {
            if ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_WEN_Msk) != 0U)
            {
                if ((WDT_REGS->WDT_INTFLAG & WDT_INTFLAG_EW_Msk) == WDT_INTFLAG_EW_Msk)
                {
                    if ((WDT_REGS->WDT_SYNCBUSY & WDT_SYNCBUSY_CLEAR_Msk) == 0U)
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
                if ((WDT_REGS->WDT_SYNCBUSY & WDT_SYNCBUSY_CLEAR_Msk) == 0U)
                {

                    /* Clear WDT and reset the WDT timer before the timeout occurs */
                    WDT_REGS->WDT_CLEAR = (uint8_t)WDT_CLEAR_CLEAR_KEY;
                }
            }
        }
    }
</#if>
<#if core.RAM_INIT?? && core.DeviceFamily == "PIC32CZ_CA80_CA90_CA91">
/* MISRAC 2012 deviation block start */
/* MISRA C-2012 Rule 18.1 deviated 1 times. Deviation record ID -  H3_MISRAC_2012_R_18_1_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
#pragma coverity compliance block \
(deviate:1 "MISRA C-2012 Rule 18.1" "H3_MISRAC_2012_R_18_1_DR_1")
</#if>
    register uint64_t *pFlexRam = (uint64_t*)(uintptr_t)&_sdata;

    // FlexRAM initialization loop (to handle ECC properly)
    // we need to initialize all of RAM with 64 bit aligned writes
    for (count = 0U; count < (((uint32_t)&_ram_end_ - (uint32_t)&_sdata) / 8U); count++)
    {
        pFlexRam[count] = 0U;
    }

    __DSB();
    __ISB();
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 18.1"
#pragma GCC diagnostic pop
</#if>
/* MISRAC 2012 deviation block end */
</#if>

    uint32_t *pSrc, *pDst;
    uintptr_t src, dst;

<#if core.CoreSysIntFile?? && core.CoreSysIntFile == true >
    uint32_t i;
    src = (uintptr_t)&_vectors_loadaddr; /* flash address */
    pSrc = (uint32_t *)src;
    dst = (uintptr_t)&_sfixed;
    pDst = (uint32_t *)dst;

    /* Copy .vectors section from flash to RAM */
    for (i = 0U; i < sizeof(H3DeviceVectors)/4U; i++)
    {
        pDst[i] = pSrc[i];
    }
</#if>

    src = (uintptr_t)&_etext;
    pSrc = (uint32_t *)src;      /* flash functions start after .text */
    dst = (uintptr_t)&_sdata;
    pDst = (uint32_t *)dst;      /* boundaries of .data area to init */

    /* Init .data */
    for (count = 0U; count < (((uint32_t)&_edata - (uint32_t)dst) / 4U); count++)
    {
        pDst[count] = pSrc[count];
    }

    /* Init .bss */
    dst = (uintptr_t)&_sbss;
    pDst = (uint32_t *)dst;
    for (count = 0U; count < (((uint32_t)&_ebss - (uint32_t)dst) / 4U); count++)
    {
        pDst[count] = 0U;
    }

<#if core.CoreSysIntFile?? && core.CoreSysIntFile == true >
    <#lt>#if defined (__VTOR_PRESENT) && (__VTOR_PRESENT == 1U)
    <#lt>    /*  Set the vector-table base address in RAM */
    <#lt>    pSrc = (uint32_t *) & _sfixed;
    <#lt>    SCB->VTOR = ((uint32_t) pSrc & SCB_VTOR_TBLOFF_Msk);
    <#lt>#endif /* #if defined (__VTOR_PRESENT) && (__VTOR_PRESENT == 1U) */
</#if>

<#if core.CoreUseMPU??>
<#if core.CoreUseMPU>
    /* Initialize MPU */
    MPU_Initialize();

</#if>
</#if>
     /* Branch to application's main function */
    (void)main();

#if (defined(__DEBUG) || defined(__DEBUG_D)) && defined(__XC32)
    __builtin_software_breakpoint();
#endif
}
