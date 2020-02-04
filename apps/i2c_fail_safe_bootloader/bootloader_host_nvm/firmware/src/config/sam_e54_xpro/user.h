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
/*******************************************************************************
  User Configuration Header

  File Name:
    user.h

  Summary:
    Build-time configuration header for the user defined by this project.

  Description:
    An MPLAB Project may have multiple configurations.  This file defines the
    build-time options for a single configuration.

  Remarks:
    It only provides macro definitions for build-time configuration options

*******************************************************************************/

#ifndef USER_H
#define USER_H

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: User Configuration macros
// *****************************************************************************
// *****************************************************************************

/* Include the Hex header file of the application to be programmed by the 
 * I2C host bootloader application. 
 * Specify the I2C slave address, Erase page size and Program Page size.
 * and the start address of the application being programmed.
 * For SAM D20, SAM D21, SAM C21N, SAM D11, SAM DA1, SAM L10, SAM L11, SAM L21, SAM L22,
 * the Erase Page Size is 256 bytes and Program Page Size can be specified as 64 bytes
 * or equal to the erase page size (256)
 * #define APP_ERASE_PAGE_SIZE         (256L)    
 * #define APP_PROGRAM_PAGE_SIZE       (64L)
 * #define APP_IMAGE_START_ADDR        0x800UL    
 * For SAM E54, the Erase Page Size is 8192 bytes and Program Page Size is 512 bytes.
 * #define APP_ERASE_PAGE_SIZE         (8192L)    
 * #define APP_PROGRAM_PAGE_SIZE       (512L)
 * #define APP_IMAGE_START_ADDR        0x2000UL 
 */
#define APP_HEX_HEADER_FILE         "test_app_images/image_pattern_hex_sam_e54_xpro_bootloader_app_merged.h"
#define APP_I2C_SLAVE_ADDR          0x0054
#define APP_ERASE_PAGE_SIZE         (8192L)  
/* This example programs all the pages in an erase row in one shot. In case the 
 * embedded host has limited RAM, the APP_PROGRAM_PAGE_SIZE macro can be set to 
 * the actual program page size (64 or 512) to reduce the RAM used to hold the 
 * program data.
 */
#define APP_PROGRAM_PAGE_SIZE       (8192L)
/* Specify the user application start address. The application start address must
 * be aligned to erase page unit. If the bootloader itself is being upgraded then 
 * the APP_IMAGE_START_ADDR must be set to 0x00 (start of bootloader). Ensure the
 * bootloader and application is also configured with the same value of application 
 * start address. 
 * If bank swap feature is enabled, the application start address must be set to
 * 0x80000UL when programming the combined bootloader and application binary to 
 * the inactive bank. Once the bootloader is programmed to the inactive bank 
 * and only application is being programmed, the address must be set to 0x82000UL
 */
#define APP_IMAGE_START_ADDR        0x80000UL
    
//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

#endif // USER_H
/*******************************************************************************
 End of File
*/
