/*--------------------------------------------------------------------------
 * MPLAB XC32 Compiler -  Bootloader linker script for TrustZone devices
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

#define ROM_START ${.vars["${MEM_USED?lower_case}"].FLASH_START_ADDRESS}

/* Bootloader size is calculated with below criteria with optimization level -O2
 * bootloader size = Minimum Flash Erase Size Or actual bootloader ELF size
                     (Rounded of to nearest erase boundary) whichever is
                     greater.
 */
#define ROM_SIZE  ${BTL_SIZE}

#if (ROM_SIZE > ${.vars["${MEM_USED?lower_case}"].FLASH_SIZE})
    #  error ROM_SIZE is greater than the max size of ${.vars["${MEM_USED?lower_case}"].FLASH_SIZE}
#endif

#ifndef SECURE
#  warning "Defaulting to a SECURE TrustZone-M project. Please define the linker macro SECURE (e.g. -Wl,-DSECURE)."
#  define SECURE
#endif

#if defined(SECURE)
#  if ((BOOTPROT_SIZE == 0) || (BOOTPROT_SIZE < ${BTL_SIZE}))
#    error "Boot protection size (BOOTPROT_SIZE) is either 0 or less than Bootloader size ${BTL_SIZE}. Update the BOOTPROT_SIZE accordingly in MCC"
#  endif

#  if (RS_SIZE < (${BTL_SIZE} + 0x2000))
#    error "Secure SRAM length (RS_SIZE) should be greater than or equal to (${BTL_SIZE} + 8KB). Update the RS_SIZE accordingly in MCC"
#  endif
#endif

<#if BTL_TRIGGER_ENABLE == true && BTL_TRIGGER_LEN != "0" >
    <#lt>/* Bootloader Trigger pattern of length ${BTL_TRIGGER_LEN} Bytes needs to be stored
    <#lt> * at 0x1000 offset from starting of RAM by the Secure application if it wants to
    <#lt> * run bootloader at startup without any external trigger.
    <#lt> * The Offset 0x1000 is because on reset Boot ROM clears the first 4KB of RAM.
    <#lt> * Example:
    <#lt> *     ram[0] = 0x5048434D;
    <#lt> *     ram[1] = 0x5048434D;
    <#lt> *     ....
    <#lt> *     ram[n] = 0x5048434D;
    <#lt> */
    <#lt>#define RAM_START (${BTL_RAM_START} + 0x1000 + ${BTL_TRIGGER_LEN})

    <#lt>#define RAM_SIZE  (RS_SIZE - 0x1000 - ${BTL_TRIGGER_LEN})
<#else>
    <#lt>#define RAM_START ${BTL_RAM_START}

    <#lt>#define RAM_SIZE  RS_SIZE
</#if>

#if (RAM_SIZE > ${BTL_RAM_SIZE})
    #  error RAM_SIZE is greater than the max size of ${BTL_RAM_SIZE}
#endif

#if defined(SECURE)
#  define _SECURE
#  define TZ_ROM_ORIGIN (ROM_START)
   /* Reserve the last 32 Bytes of Secure Boot Region for SHA value if BOOTOPT is enabled */
#  define TZ_ROM_LENGTH (BOOTPROT_SIZE - BNSC_SIZE - 32)
#  define TZ_ROM_BNSC_ORIGIN ((ROM_START + BOOTPROT_SIZE) - BNSC_SIZE)
#  define TZ_ROM_BNSC_LENGTH (BNSC_SIZE)
#  define TZ_RAM_ORIGIN (RAM_START)
#  define TZ_RAM_LENGTH (RAM_SIZE)
#endif

/*************************************************************************
 * Memory-Region Definitions
 * The MEMORY command describes the location and size of blocks of memory
 * on the target device. The command below uses the macros defined above.
 *************************************************************************/
MEMORY
{
  rom (rx) : ORIGIN = TZ_ROM_ORIGIN, LENGTH = TZ_ROM_LENGTH
#if defined(_SECURE)
  rom_nsc (rx) : ORIGIN = TZ_ROM_BNSC_ORIGIN, LENGTH = TZ_ROM_BNSC_LENGTH
#endif
  ram (rwx) : ORIGIN = TZ_RAM_ORIGIN, LENGTH = TZ_RAM_LENGTH
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
<#if core.CoreSysIntFile?? && core.CoreSysIntFile == true >
<#if BTL_TRIGGER_ENABLE == true && BTL_TRIGGER_LEN != "0" >
    .vectors RAM_START - ${BTL_TRIGGER_LEN} + 0x400:
<#else>
    .vectors :
</#if>
    {
        _sfixed = .;
        KEEP(*(.vectors .vectors.*))
    } > ram AT > rom

    _vectors_loadaddr = LOADADDR(.vectors);
<#else>
    .vectors :
    {
        . = ALIGN(4);
        KEEP(*(.vectors .vectors.*))
        _sfixed = .;
    } > ram AT > rom
</#if>

    .text :
    {
        . = ALIGN(4);
        *(.glue_7t) *(.glue_7)
        /* Force the inclusion of debug info for veneers. This is
         * sensitive to the name of the .o file containing the
         * cmse_nonsecure_entry functions. What are given are
         * common file names. */
        KEEP(*veneer.o(.text.*))
        KEEP(*nonsecure_entry.o(.text.*))
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

#if defined(_SECURE)
    /* Holds the veneers for calling into secure code. */
    . = ALIGN(4);
    .gnu.sgstubs : {
        _ssgstubs = .;
    } > rom_nsc
#endif /* defined(SECURE) */

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
    } > ram AT > ram

    . = ALIGN(4);
    _end = . ;
    _ram_end_ = ORIGIN(ram) + LENGTH(ram) -1 ;
}
