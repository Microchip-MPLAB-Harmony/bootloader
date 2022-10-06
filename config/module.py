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

I2CNames        = ["SERCOM", "I2C", "TWIHS"]
SPINames        = ["SERCOM", "SPI"]
USBNames        = ["USB", "USBHS"]
EthernetNames   = ["ETH", "GMAC"]
CANNames        = ["CAN", "MCAN"]

def hasPeripheral(peripheralList):
    periphNode          = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
    peripherals         = periphNode.getChildren()

    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))

        if ((any(x == periphName for x in peripheralList) == True)):
            return True

    return False

def hasPeripheralAndCoreArchitecture(peripheralList, coreArchitecture):
    return ((coreArchitecture in ATDF.getNode("/avr-tools-device-file/devices/device").getAttribute("architecture")) and
             hasPeripheral(peripheralList))

#Define Bootloader component names
bootloaderComponents = [
    {"name":"uart", "label": "UART", "dependency":["MEMORY", "UART", "TMR"], "condition":"True"},
    {"name":"i2c", "label": "I2C", "dependency":["MEMORY", "I2C"], "condition":'hasPeripheral(I2CNames)'},
    {"name":"spi", "label": "SPI", "dependency":["MEMORY", "SPI"], "condition":'hasPeripheral(SPINames)'},
    {"name":"usb_device_hid", "label": "USB Device HID", "dependency":["MEMORY", "USB_DEVICE_HID"], "condition":'hasPeripheral(USBNames)'},
    {"name":"udp", "label": "UDP", "dependency":["MEMORY"], "condition":'hasPeripheral(EthernetNames)'},
    {"name":"can", "label": "CAN", "dependency":["MEMORY", "CAN"], "condition":'hasPeripheralAndCoreArchitecture(CANNames, "CORTEX-M")'},
    {"name":"serial_mem", "label": "Serial Memory", "dependency":["MEMORY"], "condition":"True"},
    {"name":"file_system", "label": "File System", "dependency":["MEMORY", "SYS_FS"], "condition":"True"},
]

def loadModule():

    # Do not add Bootloader Component for unsupported families
    coreFamily   = ATDF.getNode( "/avr-tools-device-file/devices/device" ).getAttribute( "family" )
    if ((any(x == coreFamily for x in unSupportedFamilies) == True)):
        return

    print("Load Module: Bootloader")

    for bootloaderComponent in bootloaderComponents:

        #check if component should be created
        if eval(bootloaderComponent['condition']):
            Name        = bootloaderComponent['name']
            Label       = bootloaderComponent['label'] + " Bootloader"

            filePath  = "config/bootloader_" + Name + ".py"

            displayPath = "/Bootloader/"

            Component = Module.CreateComponent(Name + "_bootloader", Label, displayPath, filePath )

            if "dependency" in bootloaderComponent:
                for dep in bootloaderComponent['dependency']:

                    depId           = "btl_" + dep + "_dependency"
                    depDisplayName  = dep
                    depGeneric      = False
                    depRequired     = True

                    if (dep == "MEMORY"):
                        depDisplayName = "MEMORY (NVM)"

                    elif (dep == "TMR"):
                        if ("PIC32M" in Variables.get("__PROCESSOR")):
                            depId = "btl_TIMER_dependency"
                        else:
                            # Skip Adding dependency
                            continue

                    elif (dep == "SYS_FS"):
                        # Generic Dependency
                        depGeneric = True

                    Component.addDependency(depId, dep, depDisplayName, depGeneric, depRequired)

                    if ((Name == "serial_mem") and (dep == "MEMORY")):
                        # Requires two Dependencies of same type (MEMORY)
                        Component.addDependency("btl_" + dep + "_dependency_SERIAL", dep, "MEMORY (SERIAL)", False, True)

        Component.setDisplayType("Bootloader")
