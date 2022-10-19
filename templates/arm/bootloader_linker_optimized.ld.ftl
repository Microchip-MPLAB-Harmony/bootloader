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

#define ROM_START ${BTL_START}

/* Bootloader size is calculated with below criteria with optimization level -O2
 * bootloader size = Minimum Flash Erase Size Or actual bootloader ELF size
                     (Rounded of to nearest erase boundary) whichever is
                     greater.
 */
#define ROM_SIZE  ${BTL_SIZE}

#if (ROM_SIZE > ${.vars["${MEM_USED?lower_case}"].FLASH_SIZE})
    #  error ROM_SIZE is greater than the max size of ${.vars["${MEM_USED?lower_case}"].FLASH_SIZE}
#endif

<#if BTL_TRIGGER_ENABLE == true && BTL_TRIGGER_LEN != "0" >
    <#if core.CoreArchitecture == "CORTEX-M23">
        <#lt>/* Bootloader Trigger pattern of length ${BTL_TRIGGER_LEN} Bytes needs to be stored
        <#lt> * at 0x1000 offset from starting of RAM by the application if it wants to
        <#lt> * run bootloader at startup without any external trigger.
        <#lt> * The Offset 0x1000 is because on reset Boot ROM clears the first 4KB of RAM.
        <#lt> * Example:
        <#lt> *     ram[0] = 0x5048434D;
        <#lt> *     ram[1] = 0x5048434D;
        <#lt> *     ....
        <#lt> *     ram[n] = 0x5048434D;
        <#lt> */
        <#lt>#define RAM_START (${BTL_RAM_START} + 0x1000 + ${BTL_TRIGGER_LEN})

        <#lt>#define RAM_SIZE  (${BTL_RAM_SIZE} - 0x1000 - ${BTL_TRIGGER_LEN})
    <#else>
        <#lt>/* Bootloader Trigger pattern of length ${BTL_TRIGGER_LEN} Bytes needs to be stored
        <#lt> * from starting of Ram by the application if it wants to
        <#lt> * run bootloader at startup without any external trigger.
        <#lt> * Example:
        <#lt> *     ram[0] = 0x5048434D;
        <#lt> *     ram[1] = 0x5048434D;
        <#lt> *     ....
        <#lt> *     ram[n] = 0x5048434D;
        <#lt> */
        <#lt>#define RAM_START (${BTL_RAM_START} + ${BTL_TRIGGER_LEN})

        <#lt>#define RAM_SIZE  (${BTL_RAM_SIZE} - ${BTL_TRIGGER_LEN})
    </#if>
<#else>
    <#lt>#define RAM_START ${BTL_RAM_START}

    <#lt>#define RAM_SIZE  ${BTL_RAM_SIZE}
</#if>

#if (RAM_SIZE > ${BTL_RAM_SIZE})
    #  error RAM_SIZE is greater than the max size of ${BTL_RAM_SIZE}
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
<#if BTL_CAN_PRESENT?? && BTL_CAN_PRESENT == true && core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
  <#if core.CoreUseMPU == true>
  <#assign MPU_REGION_NAME = "core.MPU_Region_Name" + BTL_MPU_REGION_NUMBER>
  <#assign MPU_REGION_ADDR = "core.MPU_Region_" + BTL_MPU_REGION_NUMBER + "_Address">
  <#assign MPU_REGION_SIZE = "core.MPU_Region_" + BTL_MPU_REGION_NUMBER + "_Size">
  <#if MPU_REGION_NAME?eval?has_content>
  ${MPU_REGION_NAME?eval} (RWX) : ORIGIN = 0x${MPU_REGION_ADDR?eval}, LENGTH = (1 << (${MPU_REGION_SIZE?eval} + 1))
  <#else>
  #error MPU Region ${BTL_MPU_REGION_NUMBER} is not configured
  </#if>
  <#else>
  #error MPU Region ${BTL_MPU_REGION_NUMBER} is not configured
  </#if>
</#if>
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

<#if BTL_CAN_PRESENT?? && BTL_CAN_PRESENT == true && core.DATA_CACHE_ENABLE?? && core.DATA_CACHE_ENABLE == true>
    <#assign MPU_REGION_NAME = "core.MPU_Region_Name" + BTL_MPU_REGION_NUMBER>
    .${PERIPH_USED?lower_case}_message_ram (NOLOAD):
    {
    . = ALIGN(4);
    _s_${PERIPH_USED?lower_case}_message_ram = .;
    *(.${PERIPH_USED?lower_case}_message_ram .${PERIPH_USED?lower_case}_message_ram.*)
    . = ALIGN(4);
    _e_${PERIPH_USED?lower_case}_message_ram = .;
    } > ${MPU_REGION_NAME?eval}

</#if>
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
