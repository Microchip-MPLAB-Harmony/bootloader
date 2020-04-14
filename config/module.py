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

unSupportedFamilies = ["SAM9", "SAMA5"]

#Define Bootloader component names
bootloaderComponents = [
    {"name":"uart", "label": "UART", "dependency":["MEMORY", "UART", "TMR"], "mips_support":"True", "condition":"True"},
    {"name":"i2c", "label": "I2C", "dependency":["MEMORY", "I2C"], "mips_support":"False", "condition":"True"},
]

def hasPeripheral(peripheral):
    periphNode          = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
    peripherals         = periphNode.getChildren()

    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))
        if (periphName == peripheral):
            return True

    return False

def loadModule():

    # Do not add Bootloader Component for unsupported families
    coreFamily   = ATDF.getNode( "/avr-tools-device-file/devices/device" ).getAttribute( "family" )
    if ((any(x == coreFamily for x in unSupportedFamilies) == True)):
        return

    print("Load Module: Bootloader")

    for bootloaderComponent in bootloaderComponents:

        timer_dep = False

        #check if component should be created
        if eval(bootloaderComponent['condition']):
            Name        = bootloaderComponent['name']
            Label       = bootloaderComponent['label'] + " Bootloader"

            # To be removed once I2C Slave is supported on other devices
            if ((Name == "i2c") and (hasPeripheral("SERCOM") == False)):
                continue

            mips_support = eval(bootloaderComponent['mips_support'])

            if (("PIC32M" in Variables.get("__PROCESSOR")) and (mips_support == True)):
                filePath  = "config/bootloader_" + Name + "_mips.py"
                timer_dep = True
            else:
                filePath  = "config/bootloader_" + Name + "_arm.py"

            displayPath = "/Bootloader/"

            Component = Module.CreateComponent(Name + "_bootloader", Label, displayPath, filePath )

            if "dependency" in bootloaderComponent:
                for dep in bootloaderComponent['dependency']:
                    if (dep == "TMR"): 
                        if (timer_dep == True):
                            Component.addDependency("btl_TIMER_dependency", dep, False, True)
                    else:
                        Component.addDependency("btl_" + dep + "_dependency", dep, False, True)

        Component.setDisplayType("Bootloader")
