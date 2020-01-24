"""*****************************************************************************
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
*****************************************************************************"""

def hasSERCOMModule():
    periphNode          = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
    peripherals         = periphNode.getChildren()
    
    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))
        if (periphName == "SERCOM"):            
            return True

def loadModule():
    print("Load Module: Bootloader")
        
    if ("PIC32M" in Variables.get("__PROCESSOR")):
        uartBootloaderComponent = Module.CreateComponent("uart_bootloader", "UART Bootloader", "/Bootloader/", "config/bootloader_uart_mips.py")
        uartBootloaderComponent.addDependency("btl_TIMER_dependency", "TMR", False, True)
    else:
        uartBootloaderComponent = Module.CreateComponent("uart_bootloader", "UART Bootloader", "/Bootloader/", "config/bootloader_uart_arm.py")
        if (hasSERCOMModule() == True):        
            i2cBootloaderComponent = Module.CreateComponent("i2c_bootloader", "I2C Bootloader", "/Bootloader/", "config/bootloader_i2c_arm.py")
            i2cBootloaderComponent.addDependency("btl_I2C_dependency", "I2C", False, True)
            i2cBootloaderComponent.addDependency("btl_MEMORY_dependency", "MEMORY", False, True)        

    uartBootloaderComponent.addDependency("btl_UART_dependency", "UART", False, True)
    uartBootloaderComponent.addDependency("btl_MEMORY_dependency", "MEMORY", False, True)
    
    
