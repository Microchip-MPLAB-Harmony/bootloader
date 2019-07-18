/*--------------------------------------------------------------------------
 * MPLAB XC32 Compiler -  Bootloader linker script
 * 
 * Copyright (c) 2019, Microchip Technology Inc. and its subsidiaries ("Microchip")
 * All rights reserved.
 * 
 * This software is developed by Microchip Technology Inc. and its
 * subsidiaries ("Microchip").
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are 
 * met:
 * 
 * 1.      Redistributions of source code must retain the above copyright
 *         notice, this list of conditions and the following disclaimer.
 * 2.      Redistributions in binary form must reproduce the above 
 *         copyright notice, this list of conditions and the following 
 *         disclaimer in the documentation and/or other materials provided 
 *         with the distribution.
 * 3.      Microchip's name may not be used to endorse or promote products
 *         derived from this software without specific prior written 
 *         permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY MICROCHIP "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR PURPOSE ARE DISCLAIMED. IN NO EVENT 
 * SHALL MICROCHIP BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWSOEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 */

OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
SEARCH_DIR(.)

/*  
 *  Define the __XC32_RESET_HANDLER_NAME macro on the command line when you 
 *  want to use a different name for the Reset Handler function.
 */
#ifndef __XC32_RESET_HANDLER_NAME 
#define __XC32_RESET_HANDLER_NAME Reset_Handler
#endif /* __XC32_RESET_HANDLER_NAME */

/*  Set the entry point in the ELF file. Once the entry point is in the ELF 
 *  file, you can then use the --write-sla option to xc32-bin2hex to place 
 *  the address into the hex file using the SLA field (RECTYPE 5). This hex 
 *  record may be useful for a bootloader that needs to determine the entry 
 *  point to the application.
 */
ENTRY(__XC32_RESET_HANDLER_NAME)

/* Bootloader Size is calculated with below criteria with optimization level -O1
 * bootloader size = Minimum Flash Erase Size Or actual bootloader ELF size
                     (Rounded of to nearest erase boundary) whichever is
                     greater.
 */
bootloader_size        = 2048;

/* Bootloader Request pattern needs to be stored in starting 16 Bytes of Ram
 * by the application if it wants to run bootloader at startup without any
 * external trigger.
 * ram[0] = 0x5048434D;
 * ram[1] = 0x5048434D;
 * ram[2] = 0x5048434D;
 * ram[3] = 0x5048434D;
 */
bootloader_request_len = 16;

#define ROM_START 0x00000000

#define ROM_SIZE  bootloader_size

#if (ROM_SIZE > 0x10000)
    #  error ROM_SIZE is greater than the max size of 0x10000
#endif

#define RAM_START (0x20000000 + bootloader_request_len)

#define RAM_SIZE  (0x4000 - bootloader_request_len)

#if (RAM_SIZE > 0x4000)
    #  error RAM_SIZE is greater than the max size of 0x4000
#endif
 

/*************************************************************************
 * Memory-Region Definitions
 * The MEMORY command describes the location and size of blocks of memory
 * on the target device. The command below uses the macros defined above.
 *************************************************************************/
MEMORY
{
  rom (rx) : ORIGIN = ROM_START, LENGTH = ROM_SIZE
  ram (rwx) : ORIGIN = RAM_START, LENGTH = RAM_SIZE
}

/*************************************************************************
 * Section Definitions - Map input sections to output sections
 *************************************************************************/
SECTIONS
{
    /*
     * The linker moves the .vectors section into itcm when itcm is 
     * enabled via the -mitcm option, but only when this .vectors output 
     * section exists in the linker script. 
     */
    .vectors :
    {
        . = ALIGN(4);
        _sfixed = .;
        KEEP(*(.vectors .vectors.*))
    } > ram AT > rom

    .text :
    {
        . = ALIGN(4);
        *(.glue_7t) *(.glue_7)
        *(.gnu.linkonce.r.*)
        *(.ARM.extab* .gnu.linkonce.armextab.*)

        . = ALIGN(4);

        /* allow for .romfunc section to keep individual functions in flash */
        *(.romfunc)
        *(.romfunc.*)

        . = ALIGN(4);
        _efixed = .;            /* End of text section */
    } > rom

    /* .ARM.exidx is sorted, so has to go in its own output section.  */
    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > rom
    PROVIDE_HIDDEN (__exidx_end = .);

    . = ALIGN(4);
    _etext = .;

    /* Locate text/rodata in special data section to be copied
       in startup sequence. */
    .data :
    {
        . = ALIGN(4);
        __data_start__ = .;
        _sdata = .;
        *(.dinit)
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
        __data_end__ = .;
        _edata = .;
    } > ram AT > rom

    /*
     *  Align here to ensure that the .bss section occupies space up to
     *  _end.  Align after .bss to ensure correct alignment even if the
     *  .bss section disappears because there are no input sections.
     */
    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        __bss_start__ = .;
        _sbss = . ;
        _szero = .;
        *(COMMON)
        *(.bss)
        *(.bss.*)
        . = ALIGN(4);
        __bss_end__ = .;
        _ebss = . ;
        _ezero = .;
    } > ram

    . = ALIGN(4);
    _end = . ;
    _ram_end_ = ORIGIN(ram) + LENGTH(ram) -1 ;
}
