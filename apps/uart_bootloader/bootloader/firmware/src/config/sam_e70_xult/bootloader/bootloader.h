/*******************************************************************************
  Bootloader Header File

  File Name:
    bootloader.h

  Summary:
    This file contains Interface definitions of bootloder

  Description:
    This file defines interface for bootloader.
 *******************************************************************************/

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

#ifndef BOOTLOADER_H
#define BOOTLOADER_H

// *****************************************************************************
/* Function:
    bool bootloader_Trigger(void);

 Summary:
    Checks if Bootloader has to be executed at startup.

 Description:
    This function can be used to check for a External HW trigger or Internal firmware
    trigger to execute bootloader at startup.

    External Trigger:
        Is achieved by triggering the selected GPIO_PIN in bootloader configuration
        in MHC.

    Firmware Trigger
        Application firmware which wants to execute bootloader at startup needs to
        fill first 16 bytes of ram location with bootloader request pattern.

        ram[0] = 0x5048434D;
        ram[1] = 0x5048434D;
        ram[2] = 0x5048434D;
        ram[3] = 0x5048434D;

 Precondition:
    CLK_Initialize and PIO_Initialize must have been called.

 Parameters:
    None.

 Returns:
    True    - If any of trigger is detected.
    False   - If no trigger is detected..

 Example:
    <code>

        CLK_Initialize();
        PIO_Initialize();

        if (bootloader_Trigger() == false)
        {
            run_Application();
        }

    </code>
*/
bool bootloader_Trigger(void);

// *****************************************************************************
/* Function:
    void run_Application(void);

 Summary:
    Runs the programmed application at startup.

 Description:
    This function can be used to run programmed application though bootloader at startup.

    If the first 4Bytes of Application Memory is not 0xFFFFFFFF then it jumps to
    the APP_START_ADDRESS to run the application programmed through bootloader and
    never returns.

    If the first 4Bytes of Application Memory is 0xFFFFFFFF then it returns from function
    and executes bootloader for accepting a new application firmware.

 Precondition:
    bootloader_Trigger must be called to check for bootloader triggers at startup.

 Parameters:
    None.

 Returns:
    None

 Example:
    <code>

        CLK_Initialize();
        PIO_Initialize();

        if (bootloader_Trigger() == false)
        {
            run_Application();
        }

    </code>
*/
void run_Application(void);

// *****************************************************************************
/* Function:
    void bootloader_Start(void);

 Summary:
    Starts bootloader execution.

 Description:
    This function can be used to start bootloader execution.

    The function continously waits for application firmware from the HOST-PC via
    selected communication protocol to program into internal flash memory.

    Once the complete application is received, programmed and verified successfully,
    It resets the device to jump into programmed application.

    Before Jumping into application it clears the initial 16 bytes of ram memory so
    that the bootloader is not triggered at reset in case application has previously
    filled it to have a internal firmware trigger.

    Note: This function never returns.

 Precondition:
    bootloader_Trigger must be called to check for bootloader triggers at startup.

 Parameters:
    None.

 Returns:
    None

 Example:
    <code>

        CLK_Initialize();
        PIO_Initialize();

        if (bootloader_Trigger() == false)
        {
            run_Application();
        }

        SYSTICK_TimerInitialize();

        RSWDT_REGS->RSWDT_MR = RSWDT_MR_WDDIS_Msk;  // Disable RSWDT 

        WDT_REGS->WDT_MR = WDT_MR_WDDIS_Msk;        // Disable WDT 

        USART1_Initialize();

        bootloader_Start();
    </code>
*/
void bootloader_Start(void);

#endif