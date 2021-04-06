/*******************************************************************************
  File Name:
    bootloader_nvm_interface.h

  Summary:
    NVM Interface function definitions.

  Description:
    This file contains the definitions needed for PLIB usage of the Flash
    Controller.
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
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

#ifndef _BOOTLOADER_NVM_INTERFACE_H
#define _BOOTLOADER_NVM_INTERFACE_H

#ifdef __cplusplus
    extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
<#if core.CoreArchitecture == "MIPS">
    <#lt>#include "sys/kmem.h"
</#if>

#define FLASH_START             (${.vars["${MEM_USED?lower_case}"].FLASH_START_ADDRESS}UL)
#define FLASH_LENGTH            (${.vars["${MEM_USED?lower_case}"].FLASH_SIZE}UL)
#define PAGE_SIZE               (${.vars["${MEM_USED?lower_case}"].FLASH_PROGRAM_SIZE}UL)
#define ERASE_BLOCK_SIZE        (${.vars["${MEM_USED?lower_case}"].FLASH_ERASE_SIZE}UL)
#define PAGES_IN_ERASE_BLOCK    (ERASE_BLOCK_SIZE / PAGE_SIZE)

<#if BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true >
    <#lt>/* Starting location of Bootloader in Inactive bank */
    <#lt>#define INACTIVE_BANK_OFFSET    (FLASH_LENGTH / 2)

    <#lt>#define INACTIVE_BANK_START     (FLASH_START + INACTIVE_BANK_OFFSET)

    <#lt>#define APP_START_ADDRESS       INACTIVE_BANK_START

    <#lt>#define FLASH_END_ADDRESS       (INACTIVE_BANK_START + INACTIVE_BANK_OFFSET)
<#else>
    <#lt>#define FLASH_END_ADDRESS       (FLASH_START + FLASH_LENGTH)

    <#if core.CoreArchitecture == "MIPS">
        <#lt>#define APP_START_ADDRESS       ((uint32_t)(PA_TO_KVA0(0x${core.APP_START_ADDRESS}UL)))
    <#else>
        <#lt>#define APP_START_ADDRESS       (0x${core.APP_START_ADDRESS}UL)
    </#if>
</#if>

<#if core.CoreArchitecture == "MIPS" && BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true >
    <#lt>#define LOWER_FLASH_START               (FLASH_START)
    <#lt>#define LOWER_FLASH_SERIAL_START        (LOWER_FLASH_START + (FLASH_LENGTH / 2) - PAGE_SIZE)
    <#lt>#define LOWER_FLASH_SERIAL_SECTOR       (LOWER_FLASH_START + (FLASH_LENGTH / 2) - ERASE_BLOCK_SIZE)

    <#lt>#define UPPER_FLASH_START               INACTIVE_BANK_START
    <#lt>#define UPPER_FLASH_SERIAL_START        (FLASH_END_ADDRESS - PAGE_SIZE)
    <#lt>#define UPPER_FLASH_SERIAL_SECTOR       (FLASH_END_ADDRESS - ERASE_BLOCK_SIZE)

    <#lt>#define FLASH_SERIAL_PROLOGUE           0xDEADBEEF
    <#lt>#define FLASH_SERIAL_EPILOGUE           0xBEEFDEAD
    <#lt>#define FLASH_SERIAL_CLEAR              0xFFFFFFFF

    <#lt>#define LOWER_FLASH_SERIAL_READ         ((T_FLASH_SERIAL *)KVA0_TO_KVA1(LOWER_FLASH_SERIAL_START))
    <#lt>#define UPPER_FLASH_SERIAL_READ         ((T_FLASH_SERIAL *)KVA0_TO_KVA1(UPPER_FLASH_SERIAL_START))

    <#lt>/* Structure to validate the Flash serial and its checksum
    <#lt> * Note: The order of the members should not be changed
    <#lt> */
    <#lt>typedef struct
    <#lt>{
    <#lt>    uint32_t prologue;
    <#lt>    uint32_t serial;
    <#lt>    uint32_t epilogue;
    <#lt>    uint32_t dummy;
    <#lt>} T_FLASH_SERIAL;
</#if>

#define DATA_RECORD             0
#define END_OF_FILE_RECORD      1
#define EXT_SEG_ADRS_RECORD     2
#define EXT_LIN_ADRS_RECORD     4
#define START_LIN_ADRS_RECORD   5

typedef enum
{
    // indicates that the CRC value between the calculated value and the
    // value received from data stream did not match
    HEX_REC_CRC_ERROR   = -10,

    // programming error
    HEX_REC_PGM_ERROR   = -5,

    // An unspecified hex record tyype is received
    HEX_REC_UNKNOW_TYPE = -1,

    // the record type is a valid hex record
    HEX_REC_NORMAL      = 0,
} HEX_RECORD_STATUS;

HEX_RECORD_STATUS bootloader_NvmProgramHexRecord(uint8_t* HexRecord, uint32_t totalLen);

void bootloader_NvmAppErase(void);

void bootloader_NvmPageWrite(uint32_t address, uint32_t* data);

bool bootloader_NvmIsBusy(void);

<#if BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true >
    <#if core.CoreArchitecture == "MIPS" >
        <#lt>void bootloader_NvmUpdateFlashSerial(uint32_t addr);
    <#else>
        <#lt>void bootloader_NvmSwapAndReset( void );
    </#if>
</#if>

#ifdef  __cplusplus
}
#endif

#endif //_BOOTLOADER_NVM_INTERFACE_H
