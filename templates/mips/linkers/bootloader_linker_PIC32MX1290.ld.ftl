/*--------------------------------------------------------------------------
 * MPLAB XC Compiler -  PIC32MX 1XX/2XX/5XX Bootloader linker script
 * Build date : Jan 26 2021
 * 
 * Copyright (c) 2021, Microchip Technology Inc. and its subsidiaries ("Microchip")
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
 *         with the distribution. Publication is not required when this file 
 *         is used in an embedded application.
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

/* Custom linker script, for bootloaders residing completely in boot flash */

OUTPUT_FORMAT("elf32-tradlittlemips")
OUTPUT_ARCH(pic32mx)
ENTRY(_reset)
/*
 * Provide for a minimum stack and heap size
 * - _min_stack_size - represents the minimum space that must be made
 *                     available for the stack.  Can be overridden from
 *                     the command line using the linker's --defsym option.
 * - _min_heap_size  - represents the minimum space that must be made
 *                     available for the heap.  Must be specified on
 *                     the command line using the linker's --defsym option.
 */
EXTERN (_min_stack_size _min_heap_size)
PROVIDE(_min_stack_size = 0x400) ;

/*************************************************************************
 * Legacy processor-specific object file.  Contains SFR definitions.
 * The SFR definitions are now provided in a processor-specific *.S
 * assembly source file rather than the processor.o file. Use the new
 * .S file rather than this processor.o file for new projects. MPLAB XC32
 * v2.10 and later will automatically link the new .S file.
 *************************************************************************/
#if defined(__XC32_VERSION__) && (__XC32_VERSION__ < 2100)
OPTIONAL("processor.o")
#endif

/*************************************************************************
 * Symbols used for interrupt-vector table generation
 * To override the defaults, define the _vector_spacing & _ebase_address
 * symbols using the --defsym linker opt as shown in these examples:
 *   xc32-gcc src.c -Wl,--defsym=_vector_spacing=2
 *   xc32-gcc src.c -Wl,--defsym=_ebase_address=0x9D001000
 *************************************************************************/
PROVIDE(_vector_spacing = 0x0001);
PROVIDE(_ebase_address = 0x9D000000);

/*************************************************************************
 * Memory Address Equates
 * _RESET_ADDR                    -- Reset Vector or entry point
 * _BEV_EXCPT_ADDR                -- Boot exception Vector
 * _DBG_EXCPT_ADDR                -- In-circuit Debugging Exception Vector
 * _DBG_CODE_ADDR                 -- In-circuit Debug Executive address
 * _DBG_CODE_SIZE                 -- In-circuit Debug Executive size
 * _GEN_EXCPT_ADDR                -- General Exception Vector
 *************************************************************************/
_RESET_ADDR                    = 0xBFC00000;
_BEV_EXCPT_ADDR                = 0xBFC00380;
_DBG_EXCPT_ADDR                = 0xBFC00480;
_DBG_CODE_ADDR                 = 0x9FC00490;
_DBG_CODE_SIZE                 = 0x760;
_GEN_EXCPT_ADDR                = _ebase_address + 0x180;

/*************************************************************************
 * Memory Regions
 *
 * Memory regions without attributes cannot be used for orphaned sections.
 * Only sections specifically assigned to these regions can be allocated
 * into these regions.
 *
 * The config_<address> sections are used to locate the config words at
 * their absolute addresses.
 *************************************************************************/
<#assign btlFlashStartAddress = "${BTL_START}">
<#assign btlFlashSize = "${BTL_SIZE}">

<#if BTL_TRIGGER_ENABLE == true && BTL_TRIGGER_LEN != "0" >
    <#lt><#assign btlRamStartAddress = "${BTL_RAM_START} + ${BTL_TRIGGER_LEN}">
    <#lt><#assign btlRamSize = "${BTL_RAM_SIZE} - ${BTL_TRIGGER_LEN}">
<#else>
    <#lt><#assign btlRamStartAddress = "${BTL_RAM_START}">
    <#lt><#assign btlRamSize = "${BTL_RAM_SIZE}">
</#if>

MEMORY
{
  kseg0_program_mem     (rx)  : ORIGIN = ${btlFlashStartAddress}, LENGTH = ${btlFlashSize} /* All C files will be located here */
  kseg1_boot_mem              : ORIGIN = 0xBFC00000, LENGTH = 0x490
  debug_exec_mem              : ORIGIN = 0x9FC00490, LENGTH = 0x760
  config3                     : ORIGIN = 0xBFC00BF0, LENGTH = 0x4
  config2                     : ORIGIN = 0xBFC00BF4, LENGTH = 0x4
  config1                     : ORIGIN = 0xBFC00BF8, LENGTH = 0x4
  config0                     : ORIGIN = 0xBFC00BFC, LENGTH = 0x4
  kseg1_data_mem       (w!x)  : ORIGIN = ${btlRamStartAddress}, LENGTH = ${btlRamSize}
  sfrs                        : ORIGIN = 0xBF800000, LENGTH = 0x100000
  configsfrs                  : ORIGIN = 0xBFC00BF0, LENGTH = 0x10
}

/*************************************************************************
 * Configuration-word sections. Map the config-pragma input sections to
 * absolute-address output sections.
 *************************************************************************/
SECTIONS
{
  .config_BFC00BF0 : {
    KEEP(*(.config_BFC00BF0))
  } > config3
  .config_BFC00BF4 : {
    KEEP(*(.config_BFC00BF4))
  } > config2
  .config_BFC00BF8 : {
    KEEP(*(.config_BFC00BF8))
  } > config1
  .config_BFC00BFC : {
    KEEP(*(.config_BFC00BFC))
  } > config0
}
SECTIONS
{
  /* Boot Sections */
  .reset _RESET_ADDR :
  {
    KEEP(*(.reset))
    KEEP(*(.reset.startup))
  } > kseg1_boot_mem
  .bev_excpt _BEV_EXCPT_ADDR :
  {
    KEEP(*(.bev_handler))
  } > kseg1_boot_mem
  /* Debug exception vector */
  .dbg_excpt _DBG_EXCPT_ADDR (NOLOAD) :
  {
    . += (DEFINED (_DEBUGGER) ? 0x8 : 0x0);
  } > kseg1_boot_mem
  /* Space reserved for the debug executive */
  .dbg_code _DBG_CODE_ADDR (NOLOAD) :
  {
    . += (DEFINED (_DEBUGGER) ? _DBG_CODE_SIZE : 0x0);
  } > debug_exec_mem

  .app_excpt _GEN_EXCPT_ADDR :
  {
    KEEP(*(.gen_handler))
  } > kseg0_program_mem

<#if (BTL_TYPE != "UART") && (BTL_TYPE != "I2C") >
    <#lt>   .vector_0 _ebase_address + 0x200 + ((_vector_spacing << 5) * 0) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_0))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_0) <= (_vector_spacing << 5), "function at exception vector 0 too large")
    <#lt>  .vector_1 _ebase_address + 0x200 + ((_vector_spacing << 5) * 1) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_1))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_1) <= (_vector_spacing << 5), "function at exception vector 1 too large")
    <#lt>  .vector_2 _ebase_address + 0x200 + ((_vector_spacing << 5) * 2) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_2))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_2) <= (_vector_spacing << 5), "function at exception vector 2 too large")
    <#lt>  .vector_3 _ebase_address + 0x200 + ((_vector_spacing << 5) * 3) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_3))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_3) <= (_vector_spacing << 5), "function at exception vector 3 too large")
    <#lt>  .vector_4 _ebase_address + 0x200 + ((_vector_spacing << 5) * 4) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_4))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_4) <= (_vector_spacing << 5), "function at exception vector 4 too large")
    <#lt>  .vector_5 _ebase_address + 0x200 + ((_vector_spacing << 5) * 5) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_5))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_5) <= (_vector_spacing << 5), "function at exception vector 5 too large")
    <#lt>  .vector_6 _ebase_address + 0x200 + ((_vector_spacing << 5) * 6) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_6))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_6) <= (_vector_spacing << 5), "function at exception vector 6 too large")
    <#lt>  .vector_7 _ebase_address + 0x200 + ((_vector_spacing << 5) * 7) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_7))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_7) <= (_vector_spacing << 5), "function at exception vector 7 too large")
    <#lt>  .vector_8 _ebase_address + 0x200 + ((_vector_spacing << 5) * 8) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_8))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_8) <= (_vector_spacing << 5), "function at exception vector 8 too large")
    <#lt>  .vector_9 _ebase_address + 0x200 + ((_vector_spacing << 5) * 9) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_9))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_9) <= (_vector_spacing << 5), "function at exception vector 9 too large")
    <#lt>  .vector_10 _ebase_address + 0x200 + ((_vector_spacing << 5) * 10) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_10))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_10) <= (_vector_spacing << 5), "function at exception vector 10 too large")
    <#lt>  .vector_11 _ebase_address + 0x200 + ((_vector_spacing << 5) * 11) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_11))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_11) <= (_vector_spacing << 5), "function at exception vector 11 too large")
    <#lt>  .vector_12 _ebase_address + 0x200 + ((_vector_spacing << 5) * 12) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_12))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_12) <= (_vector_spacing << 5), "function at exception vector 12 too large")
    <#lt>  .vector_13 _ebase_address + 0x200 + ((_vector_spacing << 5) * 13) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_13))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_13) <= (_vector_spacing << 5), "function at exception vector 13 too large")
    <#lt>  .vector_14 _ebase_address + 0x200 + ((_vector_spacing << 5) * 14) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_14))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_14) <= (_vector_spacing << 5), "function at exception vector 14 too large")
    <#lt>  .vector_15 _ebase_address + 0x200 + ((_vector_spacing << 5) * 15) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_15))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_15) <= (_vector_spacing << 5), "function at exception vector 15 too large")
    <#lt>  .vector_16 _ebase_address + 0x200 + ((_vector_spacing << 5) * 16) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_16))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_16) <= (_vector_spacing << 5), "function at exception vector 16 too large")
    <#lt>  .vector_17 _ebase_address + 0x200 + ((_vector_spacing << 5) * 17) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_17))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_17) <= (_vector_spacing << 5), "function at exception vector 17 too large")
    <#lt>  .vector_18 _ebase_address + 0x200 + ((_vector_spacing << 5) * 18) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_18))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_18) <= (_vector_spacing << 5), "function at exception vector 18 too large")
    <#lt>  .vector_19 _ebase_address + 0x200 + ((_vector_spacing << 5) * 19) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_19))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_19) <= (_vector_spacing << 5), "function at exception vector 19 too large")
    <#lt>  .vector_20 _ebase_address + 0x200 + ((_vector_spacing << 5) * 20) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_20))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_20) <= (_vector_spacing << 5), "function at exception vector 20 too large")
    <#lt>  .vector_21 _ebase_address + 0x200 + ((_vector_spacing << 5) * 21) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_21))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_21) <= (_vector_spacing << 5), "function at exception vector 21 too large")
    <#lt>  .vector_22 _ebase_address + 0x200 + ((_vector_spacing << 5) * 22) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_22))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_22) <= (_vector_spacing << 5), "function at exception vector 22 too large")
    <#lt>  .vector_23 _ebase_address + 0x200 + ((_vector_spacing << 5) * 23) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_23))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_23) <= (_vector_spacing << 5), "function at exception vector 23 too large")
    <#lt>  .vector_24 _ebase_address + 0x200 + ((_vector_spacing << 5) * 24) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_24))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_24) <= (_vector_spacing << 5), "function at exception vector 24 too large")
    <#lt>  .vector_25 _ebase_address + 0x200 + ((_vector_spacing << 5) * 25) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_25))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_25) <= (_vector_spacing << 5), "function at exception vector 25 too large")
    <#lt>  .vector_26 _ebase_address + 0x200 + ((_vector_spacing << 5) * 26) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_26))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_26) <= (_vector_spacing << 5), "function at exception vector 26 too large")
    <#lt>  .vector_27 _ebase_address + 0x200 + ((_vector_spacing << 5) * 27) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_27))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_27) <= (_vector_spacing << 5), "function at exception vector 27 too large")
    <#lt>  .vector_28 _ebase_address + 0x200 + ((_vector_spacing << 5) * 28) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_28))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_28) <= (_vector_spacing << 5), "function at exception vector 28 too large")
    <#lt>  .vector_29 _ebase_address + 0x200 + ((_vector_spacing << 5) * 29) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_29))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_29) <= (_vector_spacing << 5), "function at exception vector 29 too large")
    <#lt>  .vector_30 _ebase_address + 0x200 + ((_vector_spacing << 5) * 30) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_30))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_30) <= (_vector_spacing << 5), "function at exception vector 30 too large")
    <#lt>  .vector_31 _ebase_address + 0x200 + ((_vector_spacing << 5) * 31) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_31))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_31) <= (_vector_spacing << 5), "function at exception vector 31 too large")
    <#lt>  .vector_32 _ebase_address + 0x200 + ((_vector_spacing << 5) * 32) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_32))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_32) <= (_vector_spacing << 5), "function at exception vector 32 too large")
    <#lt>  .vector_33 _ebase_address + 0x200 + ((_vector_spacing << 5) * 33) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_33))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_33) <= (_vector_spacing << 5), "function at exception vector 33 too large")
    <#lt>  .vector_34 _ebase_address + 0x200 + ((_vector_spacing << 5) * 34) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_34))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_34) <= (_vector_spacing << 5), "function at exception vector 34 too large")
    <#lt>  .vector_35 _ebase_address + 0x200 + ((_vector_spacing << 5) * 35) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_35))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_35) <= (_vector_spacing << 5), "function at exception vector 35 too large")
    <#lt>  .vector_36 _ebase_address + 0x200 + ((_vector_spacing << 5) * 36) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_36))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_36) <= (_vector_spacing << 5), "function at exception vector 36 too large")
    <#lt>  .vector_37 _ebase_address + 0x200 + ((_vector_spacing << 5) * 37) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_37))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_37) <= (_vector_spacing << 5), "function at exception vector 37 too large")
    <#lt>  .vector_38 _ebase_address + 0x200 + ((_vector_spacing << 5) * 38) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_38))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_38) <= (_vector_spacing << 5), "function at exception vector 38 too large")
    <#lt>  .vector_39 _ebase_address + 0x200 + ((_vector_spacing << 5) * 39) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_39))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_39) <= (_vector_spacing << 5), "function at exception vector 39 too large")
    <#lt>  .vector_40 _ebase_address + 0x200 + ((_vector_spacing << 5) * 40) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_40))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_40) <= (_vector_spacing << 5), "function at exception vector 40 too large")
    <#lt>  .vector_41 _ebase_address + 0x200 + ((_vector_spacing << 5) * 41) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_41))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_41) <= (_vector_spacing << 5), "function at exception vector 41 too large")
    <#lt>  .vector_42 _ebase_address + 0x200 + ((_vector_spacing << 5) * 42) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_42))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_42) <= (_vector_spacing << 5), "function at exception vector 42 too large")
    <#lt>  .vector_43 _ebase_address + 0x200 + ((_vector_spacing << 5) * 43) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_43))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_43) <= (_vector_spacing << 5), "function at exception vector 43 too large")
    <#lt>  .vector_44 _ebase_address + 0x200 + ((_vector_spacing << 5) * 44) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_44))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_44) <= (_vector_spacing << 5), "function at exception vector 44 too large")
    <#lt>  .vector_45 _ebase_address + 0x200 + ((_vector_spacing << 5) * 45) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_45))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_45) <= (_vector_spacing << 5), "function at exception vector 45 too large")
    <#lt>  .vector_46 _ebase_address + 0x200 + ((_vector_spacing << 5) * 46) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_46))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_46) <= (_vector_spacing << 5), "function at exception vector 46 too large")
    <#lt>  .vector_47 _ebase_address + 0x200 + ((_vector_spacing << 5) * 47) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_47))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_47) <= (_vector_spacing << 5), "function at exception vector 47 too large")
    <#lt>  .vector_48 _ebase_address + 0x200 + ((_vector_spacing << 5) * 48) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_48))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_48) <= (_vector_spacing << 5), "function at exception vector 48 too large")
    <#lt>  .vector_49 _ebase_address + 0x200 + ((_vector_spacing << 5) * 49) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_49))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_49) <= (_vector_spacing << 5), "function at exception vector 49 too large")
    <#lt>  .vector_50 _ebase_address + 0x200 + ((_vector_spacing << 5) * 50) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_50))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_50) <= (_vector_spacing << 5), "function at exception vector 50 too large")
    <#lt>  .vector_51 _ebase_address + 0x200 + ((_vector_spacing << 5) * 51) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_51))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_51) <= (_vector_spacing << 5), "function at exception vector 51 too large")
    <#lt>  .vector_52 _ebase_address + 0x200 + ((_vector_spacing << 5) * 52) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_52))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_52) <= (_vector_spacing << 5), "function at exception vector 52 too large")
    <#lt>  .vector_53 _ebase_address + 0x200 + ((_vector_spacing << 5) * 53) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_53))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_53) <= (_vector_spacing << 5), "function at exception vector 53 too large")
    <#lt>  .vector_54 _ebase_address + 0x200 + ((_vector_spacing << 5) * 54) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_54))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_54) <= (_vector_spacing << 5), "function at exception vector 54 too large")
    <#lt>  .vector_55 _ebase_address + 0x200 + ((_vector_spacing << 5) * 55) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_55))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_55) <= (_vector_spacing << 5), "function at exception vector 55 too large")
    <#lt>  .vector_56 _ebase_address + 0x200 + ((_vector_spacing << 5) * 56) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_56))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_56) <= (_vector_spacing << 5), "function at exception vector 56 too large")
    <#lt>  .vector_57 _ebase_address + 0x200 + ((_vector_spacing << 5) * 57) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_57))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_57) <= (_vector_spacing << 5), "function at exception vector 57 too large")
    <#lt>  .vector_58 _ebase_address + 0x200 + ((_vector_spacing << 5) * 58) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_58))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_58) <= (_vector_spacing << 5), "function at exception vector 58 too large")
    <#lt>  .vector_59 _ebase_address + 0x200 + ((_vector_spacing << 5) * 59) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_59))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_59) <= (_vector_spacing << 5), "function at exception vector 59 too large")
    <#lt>  .vector_60 _ebase_address + 0x200 + ((_vector_spacing << 5) * 60) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_60))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_60) <= (_vector_spacing << 5), "function at exception vector 60 too large")
    <#lt>  .vector_61 _ebase_address + 0x200 + ((_vector_spacing << 5) * 61) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_61))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_61) <= (_vector_spacing << 5), "function at exception vector 61 too large")
    <#lt>  .vector_62 _ebase_address + 0x200 + ((_vector_spacing << 5) * 62) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_62))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_62) <= (_vector_spacing << 5), "function at exception vector 62 too large")
    <#lt>  .vector_63 _ebase_address + 0x200 + ((_vector_spacing << 5) * 63) :
    <#lt>  {
    <#lt>     KEEP(*(.vector_63))
    <#lt>  } > kseg0_program_mem
    <#lt>  ASSERT (_vector_spacing == 0 || SIZEOF(.vector_63) <= (_vector_spacing << 5), "function at exception vector 63 too large")
</#if>

  /* Code Sections - Note that input sections *(.text) and *(.text.*)
   * are not mapped here. The best-fit allocator locates them,
   * so that .text may flow around absolute sections as needed.
   */
  .text :
  {
    *(.stub .gnu.linkonce.t.*)
    KEEP (*(.text.*personality*))
    *(.mips16.fn.*)
    *(.mips16.call.*)
    *(.gnu.warning)
    . = ALIGN(4) ;
  } >kseg0_program_mem
  /* Global-namespace object initialization */
  .init   :
  {
    KEEP (*crti.o(.init))
    KEEP (*crtbegin.o(.init))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o *crtn.o ).init))
    KEEP (*crtend.o(.init))
    KEEP (*crtn.o(.init))
    . = ALIGN(4) ;
  } >kseg0_program_mem
  .fini   :
  {
    KEEP (*(.fini))
    . = ALIGN(4) ;
  } >kseg0_program_mem
  .preinit_array   :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
    . = ALIGN(4) ;
  } >kseg0_program_mem
  .init_array   :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array))
    PROVIDE_HIDDEN (__init_array_end = .);
    . = ALIGN(4) ;
  } >kseg0_program_mem
  .fini_array   :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array))
    PROVIDE_HIDDEN (__fini_array_end = .);
    . = ALIGN(4) ;
  } >kseg0_program_mem
  .ctors   :
  {
    /* XC32 uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */
    KEEP (*crtbegin.o(.ctors))
    KEEP (*crtbegin?.o(.ctors))
    /* We don't want to include the .ctor section from
       the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
    . = ALIGN(4) ;
  } >kseg0_program_mem
  .dtors   :
  {
    KEEP (*crtbegin.o(.dtors))
    KEEP (*crtbegin?.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
    . = ALIGN(4) ;
  } >kseg0_program_mem
  /* Read-only sections */
  .rodata   :
  {
    *( .gnu.linkonce.r.*)
    *(.rodata1)
    . = ALIGN(4) ;
  } >kseg0_program_mem
  /*
   * Small initialized constant global and static data can be placed in the
   * .sdata2 section.  This is different from .sdata, which contains small
   * initialized non-constant global and static data.
   */
  .sdata2 ALIGN(4) :
  {
    *(.sdata2 .sdata2.* .gnu.linkonce.s2.*)
    . = ALIGN(4) ;
  } >kseg0_program_mem
  /*
   * Uninitialized constant global and static data (i.e., variables which will
   * always be zero).  Again, this is different from .sbss, which contains
   * small non-initialized, non-constant global and static data.
   */
  .sbss2 ALIGN(4) :
  {
    *(.sbss2 .sbss2.* .gnu.linkonce.sb2.*)
    . = ALIGN(4) ;
  } >kseg0_program_mem
  .eh_frame_hdr   :
  {
    *(.eh_frame_hdr)
  } >kseg0_program_mem
    . = ALIGN(4) ;
  .eh_frame   : ONLY_IF_RO
  {
    KEEP (*(.eh_frame))
  } >kseg0_program_mem
    . = ALIGN(4) ;
  .gcc_except_table   : ONLY_IF_RO
  {
    *(.gcc_except_table .gcc_except_table.*)
  } >kseg0_program_mem
    . = ALIGN(4) ;
  .dbg_data (NOLOAD) :
  {
    . += (DEFINED (_DEBUGGER) ? 0x200 : 0x0);
  } >kseg1_data_mem
  .jcr   :
  {
    KEEP (*(.jcr))
    . = ALIGN(4) ;
  } >kseg1_data_mem
  .eh_frame    : ONLY_IF_RW
  {
    KEEP (*(.eh_frame))
  } >kseg1_data_mem
    . = ALIGN(4) ;
  .gcc_except_table    : ONLY_IF_RW
  {
    *(.gcc_except_table .gcc_except_table.*)
  } >kseg1_data_mem
    . = ALIGN(4) ;
  /* Persistent data - Use the new C 'persistent' attribute instead. */
  .persist   :
  {
    _persist_begin = .;
    *(.persist .persist.*)
    . = ALIGN(4) ;
    _persist_end = .;
  } >kseg1_data_mem
  /*
   *  Note that input sections named .data* are not mapped here.
   *  The best-fit allocator locates them, so that they may flow
   *  around absolute sections as needed.
   */
  .data   :
  {
    *( .gnu.linkonce.d.*)
    SORT(CONSTRUCTORS)
    *(.data1)
    . = ALIGN(4) ;
  } >kseg1_data_mem
  . = .;
  _gp = ALIGN(16) + 0x7ff0;
  .got ALIGN(4) :
  {
    *(.got.plt) *(.got)
    . = ALIGN(4) ;
  } >kseg1_data_mem /* AT>kseg0_program_mem */
  /*
   * Note that 'small' data sections are still mapped in the linker
   * script. This ensures that they are grouped together for
   * gp-relative addressing. Absolute sections are allocated after
   * the 'small' data sections so small data cannot flow around them.
   */
  /*
   * We want the small data sections together, so single-instruction offsets
   * can access them all, and initialized data all before uninitialized, so
   * we can shorten the on-disk segment size.
   */
  .sdata ALIGN(4) :
  {
    _sdata_begin = . ;
    *(.sdata .sdata.* .gnu.linkonce.s.*)
    . = ALIGN(4) ;
    _sdata_end = . ;
  } >kseg1_data_mem
  .lit8           :
  {
    *(.lit8)
  } >kseg1_data_mem
  .lit4           :
  {
    *(.lit4)
  } >kseg1_data_mem
  . = ALIGN (4) ;
  _data_end = . ;
  _bss_begin = . ;
  .sbss ALIGN(4) :
  {
    _sbss_begin = . ;
    *(.dynsbss)
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
    _sbss_end = . ;
    . = ALIGN(4) ;
  } >kseg1_data_mem
  /*
   *  Align here to ensure that the .bss section occupies space up to
   *  _end.  Align after .bss to ensure correct alignment even if the
   *  .bss section disappears because there are no input sections.
   *
   *  Note that input sections named .bss* are no longer mapped here.
   *  The best-fit allocator locates them, so that they may flow
   *  around absolute sections as needed.
   *
   */
  .bss     :
  {
    *(.dynbss)
    *(COMMON)
   /* Align here to ensure that the .bss section occupies space up to
      _end.  Align after .bss to ensure correct alignment even if the
      .bss section disappears because there are no input sections. */
   . = ALIGN(. != 0 ? 4 : 1);
  } >kseg1_data_mem
  . = ALIGN(4) ;
  _end = . ;
  _bss_end = . ;
  /*
   *  The heap and stack are best-fit allocated by the linker after other
   *  data and bss sections have been allocated.
   */
  /*
   * RAM functions go at the end of our stack and heap allocation.
   * Alignment of 2K required by the boundary register (BMXDKPBA).
   *
   * RAM functions are now allocated by the linker. The linker generates
   * _ramfunc_begin and _bmxdkpba_address symbols depending on the
   * location of RAM functions.
   */
  _bmxdudba_address = LENGTH(kseg1_data_mem) ;
  _bmxdupba_address = LENGTH(kseg1_data_mem) ;
    /* The .pdr section belongs in the absolute section */
    /DISCARD/ : { *(.pdr) }
  .gptab.sdata : { *(.gptab.data) *(.gptab.sdata) }
  .gptab.sbss : { *(.gptab.bss) *(.gptab.sbss) }
  .mdebug.abi32 0 : { KEEP(*(.mdebug.abi32)) }
  .mdebug.abiN32 0 : { KEEP(*(.mdebug.abiN32)) }
  .mdebug.abi64 0 : { KEEP(*(.mdebug.abi64)) }
  .mdebug.abiO64 0 : { KEEP(*(.mdebug.abiO64)) }
  .mdebug.eabi32 0 : { KEEP(*(.mdebug.eabi32)) }
  .mdebug.eabi64 0 : { KEEP(*(.mdebug.eabi64)) }
  .gcc_compiled_long32 : { KEEP(*(.gcc_compiled_long32)) }
  .gcc_compiled_long64 : { KEEP(*(.gcc_compiled_long64)) }
  /* Stabs debugging sections.  */
  .stab          0 : { *(.stab) }
  .stabstr       0 : { *(.stabstr) }
  .stab.excl     0 : { *(.stab.excl) }
  .stab.exclstr  0 : { *(.stab.exclstr) }
  .stab.index    0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment       0 : { *(.comment) }
  /* DWARF debug sections used by MPLAB X for source-level debugging. 
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *.elf(.debug) *(.debug) }
  .line           0 : { *.elf(.line) *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *.elf(.debug_srcinfo) *(.debug_srcinfo) }
  .debug_sfnames  0 : { *.elf(.debug_sfnames) *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *.elf(.debug_aranges) *(.debug_aranges) }
  .debug_pubnames 0 : { *.elf(.debug_pubnames) *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *.elf(.debug_info .gnu.linkonce.wi.*) *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev   0 : { *.elf(.debug_abbrev) *(.debug_abbrev) }
  .debug_line     0 : { *.elf(.debug_line) *(.debug_line) }
  .debug_frame    0 : { *.elf(.debug_frame) *(.debug_frame) }
  .debug_str      0 : { *.elf(.debug_str) *(.debug_str) }
  .debug_loc      0 : { *.elf(.debug_loc) *(.debug_loc) }
  .debug_macinfo  0 : { *.elf(.debug_macinfo) *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *.elf(.debug_weaknames) *(.debug_weaknames) }
  .debug_funcnames 0 : { *.elf(.debug_funcnames) *(.debug_funcnames) }
  .debug_typenames 0 : { *.elf(.debug_typenames) *(.debug_typenames) }
  .debug_varnames  0 : { *.elf(.debug_varnames) *(.debug_varnames) }
  .debug_pubtypes 0 : { *.elf(.debug_pubtypes) *(.debug_pubtypes) }
  .debug_ranges   0 : { *.elf(.debug_ranges) *(.debug_ranges) }
  /DISCARD/ : { *(.rel.dyn) }
  .gnu.attributes 0 : { KEEP (*(.gnu.attributes)) }
  /DISCARD/ : { *(.note.GNU-stack) }
  /DISCARD/ : { *(.note.GNU-stack) *(.gnu_debuglink) *(.gnu.lto_*) *(.discard) }
}

