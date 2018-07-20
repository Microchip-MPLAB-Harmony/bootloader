/**
 * Copyright (c) 2016-2017 Microchip Technology Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "definitions.h" /* for potential custom handler names */
#include <libpic32c.h>
#include <sys/cdefs.h>
#include <stdbool.h>

/* Initialize segments */
extern uint32_t _sfixed;
extern void _ram_end_(void);

extern int main(void);

/* Declaration of Reset handler (may be custom) */
void __attribute__((noinline)) Reset_Handler(void);

__attribute__ ((used, section(".vectors")))
void (* const vectors[])(void) =
{
  &_ram_end_,
  Reset_Handler,
};

/**
 * \brief This is the code that gets called on processor reset.
 * To initialize the device, and call the main() routine.
 */

/* Linker-defined symbols for data initialization. */
extern uint32_t _sdata, _edata, _etext;
extern uint32_t _sbss, _ebss;

void __attribute__((noinline, section(".romfunc.Reset_Handler"))) Reset_Handler(void)
{
    uint32_t *pSrc, *pDst;;

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
    /*  Set the vector-table base address in FLASH */
    pSrc = (uint32_t *) & _sfixed;
    SCB->VTOR = ((uint32_t) pSrc & SCB_VTOR_TBLOFF_Msk);
#  endif /* SCB_VTOR_TBLOFF_Msk */


     /* Branch to application's main function */
    main();

#if (defined(__DEBUG) || defined(__DEBUG_D)) && defined(__XC32)
    __builtin_software_breakpoint();
#endif
}
