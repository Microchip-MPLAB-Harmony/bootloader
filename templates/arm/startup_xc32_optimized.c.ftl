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
#include "device_vectors.h"
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
extern uint32_t _vectors_loadaddr;

void __attribute__((noinline, section(".romfunc.Reset_Handler"))) Reset_Handler(void)
{    
<#if core.RAM_INIT?? && core.DeviceFamily == "PIC32CM_JH00_JH01">
    register uint32_t wdt_ctrl = 0;
    register uint32_t *pRam;   
    
	/* Save the WDT control register to be restored after RAM init is complete */
	wdt_ctrl = WDT_REGS->WDT_CTRLA;
	
    if ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_ENABLE_Msk) && (!(WDT_REGS->WDT_CTRLA & WDT_CTRLA_ALWAYSON_Msk)))
    {
        /* Wait for synchronization */
        while(WDT_REGS->WDT_SYNCBUSY != 0U)
        {

        }

        /* Disable Watchdog Timer */
        WDT_REGS->WDT_CTRLA &= (uint8_t)(~WDT_CTRLA_ENABLE_Msk);

        /* Wait for synchronization */
        while(WDT_REGS->WDT_SYNCBUSY != 0U)
        {

        }
    }    
    
    if ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_WEN_Msk) && (WDT_REGS->WDT_CTRLA & WDT_CTRLA_ALWAYSON_Msk))
    {            
        while(WDT_REGS->WDT_SYNCBUSY != 0U)
        {

        }

        /* Disable window mode */
        WDT_REGS->WDT_CTRLA &= (uint8_t)(~WDT_CTRLA_WEN_Msk);

        while(WDT_REGS->WDT_SYNCBUSY != 0U)
        {

        }
    }  
	
	__DSB();
    __ISB();
               
    // MCRAMC initialization loop (to handle ECC properly)
    // Write to entire RAM (leaving initial 16 bytes) to initialize ECC checksum
    for (pRam = (uint32_t*)&_sdata ; pRam < (uint32_t*)&_ram_end_; pRam++)
    {
        *pRam = 0;   
                        
        if ((WDT_REGS->WDT_SYNCBUSY & WDT_SYNCBUSY_CLEAR_Msk) != WDT_SYNCBUSY_CLEAR_Msk)
        {
            
            /* Clear WDT and reset the WDT timer before the
            timeout occurs */
            WDT_REGS->WDT_CLEAR = (uint8_t)WDT_CLEAR_CLEAR_KEY;
        }
    }    
	
	__DSB();
    __ISB();
	
	/* Wait for synchronization */
	while(WDT_REGS->WDT_SYNCBUSY != 0U)
	{

	}
	
	/* Restore back the WDT control register */
	WDT_REGS->WDT_CTRLA = wdt_ctrl;
	
	/* Wait for synchronization */
	while(WDT_REGS->WDT_SYNCBUSY != 0U)
	{

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

#  ifdef SCB_VTOR_TBLOFF_Msk
    /*  Set the vector-table base address in RAM */
    pSrc = (uint32_t *) & _sfixed;
    SCB->VTOR = ((uint32_t) pSrc & SCB_VTOR_TBLOFF_Msk);
#  endif /* SCB_VTOR_TBLOFF_Msk */


     /* Branch to application's main function */
    main();

#if (defined(__DEBUG) || defined(__DEBUG_D)) && defined(__XC32)
    __builtin_software_breakpoint();
#endif
}
