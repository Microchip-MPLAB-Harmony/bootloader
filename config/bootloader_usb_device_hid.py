"""*****************************************************************************
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
*****************************************************************************"""
global btlSizes
global btl_type
global btl_helpkeyword

btl_type = "USB_DEVICE_HID"
btl_helpkeyword = "mcc_h3_usb_bootloader_configurations"

bootloaderCore = ""

# Maximum Size for Bootloader [BYTES]
if ("PIC32M" in Variables.get("__PROCESSOR")):
    bootloaderCore = "bootloader_mips.py"
    btlSizes = {
                "PIC32MX"     : [32768],
                "PIC32MK"     : [32768],
                "PIC32MM1387" : [18432],
                "PIC32MZDA"   : [45056],
                "PIC32MZEF"   : [45056],
                "PIC32MZW"    : [45056],
    }
else:
    bootloaderCore = "bootloader_arm.py"
    btlSizes = {
                "CORTEX-M0PLUS"     : [15360],
                "CORTEX-M23"        : [15360],
                "CORTEX-M4"         : [16384],
                "CORTEX-M7"         : [16384],
    }

def getMaxBootloaderSize(arch):

    if (arch in btlSizes):
        return btlSizes[arch][0]
    else:
        return 0

# Call bootloader core python
execfile(Module.getPath() + "/config/" + bootloaderCore)

# Call Bootloader Live Update Settings python
execfile(Module.getPath() + "/config/bootloader_live_update.py")

def getLinkerParams(btlLength, triggerLength):
    global ram_start
    global ram_size

    romLen      = str(hex(btlLength))

    ramStart    = str(hex((int(ram_start, 16) + triggerLength)))
    ramLen      = str(hex((int(ram_size, 16) - triggerLength)))

    rom_length  = "ROM_LENGTH=" + romLen
    ram_origin  = "RAM_ORIGIN=" + ramStart
    ram_length  = "RAM_LENGTH=" + ramLen

    return (rom_length + ";" + ram_origin + ";" + ram_length)

def setLinkerParams(symbol, event):
    component = symbol.getComponent()

    liveUpdateEnabled = component.getSymbolByID("BTL_LIVE_UPDATE").getValue()

    if (liveUpdateEnabled == True):
        btlLength = int(component.getSymbolByID("BTL_LIVE_UPDATE_SIZE").getValue())
    else:
        btlLength = int(component.getSymbolByID("BTL_SIZE").getValue())

    triggerLength = int(component.getSymbolByID("BTL_TRIGGER_LEN").getValue())

    linkerParams = getLinkerParams(btlLength, triggerLength)

    symbol.setValue(linkerParams)

def setupCoreComponentSymbols():

    coreComponent = Database.getComponentByID("core")

    coreComponent.getSymbolByID("CoreSysInitFile").setValue(False)

    coreComponent.getSymbolByID("XC32_LINKER_PREPROC_MARCOS").setEnabled(False)

def instantiateComponent(bootloaderComponent):
    configName = Variables.get("__CONFIGURATION_NAME")

    setupCoreComponentSymbols()

    btlUsbDeviceIndex = bootloaderComponent.createIntegerSymbol("USB_DEVICE_INDEX", None)
    btlUsbDeviceIndex.setHelp("mcc_h3_usb_bootloader_configurations")
    btlUsbDeviceIndex.setLabel("Bootloader USB Device Index")
    btlUsbDeviceIndex.setReadOnly(True)
    btlUsbDeviceIndex.setVisible(False)

    generateCommonSymbols(bootloaderComponent)

    setupLiveUpdateSymbols(bootloaderComponent)

    #################### Code Generation ####################

    btlSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_SRC", None)
    btlSourceFile.setSourcePath("../bootloader/templates/src/unified/bootloader.c.ftl")
    btlSourceFile.setOutputName("bootloader_" + btl_type.lower() + ".c")
    btlSourceFile.setMarkup(True)
    btlSourceFile.setOverwrite(True)
    btlSourceFile.setDestPath("/bootloader/")
    btlSourceFile.setProjectPath("config/" + configName + "/bootloader/")
    btlSourceFile.setType("SOURCE")

    btlHeaderFile = bootloaderComponent.createFileSymbol("BOOTLOADER_HEADER", None)
    btlHeaderFile.setSourcePath("../bootloader/templates/src/bootloader.h.ftl")
    btlHeaderFile.setOutputName("bootloader_" + btl_type.lower() + ".h")
    btlHeaderFile.setMarkup(True)
    btlHeaderFile.setOverwrite(True)
    btlHeaderFile.setDestPath("/bootloader/")
    btlHeaderFile.setProjectPath("config/" + configName + "/bootloader/")
    btlHeaderFile.setType("HEADER")

    btlNvmSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_NVM_SRC", None)
    btlNvmSourceFile.setSourcePath("../bootloader/templates/src/unified/bootloader_nvm_interface.c.ftl")
    btlNvmSourceFile.setOutputName("bootloader_nvm_interface.c")
    btlNvmSourceFile.setMarkup(True)
    btlNvmSourceFile.setOverwrite(True)
    btlNvmSourceFile.setDestPath("/bootloader/")
    btlNvmSourceFile.setProjectPath("config/" + configName + "/bootloader/")
    btlNvmSourceFile.setType("SOURCE")

    btlNvmHeaderFile = bootloaderComponent.createFileSymbol("BOOTLOADER_NVM_HEADER", None)
    btlNvmHeaderFile.setSourcePath("../bootloader/templates/src/unified/bootloader_nvm_interface.h.ftl")
    btlNvmHeaderFile.setOutputName("bootloader_nvm_interface.h")
    btlNvmHeaderFile.setMarkup(True)
    btlNvmHeaderFile.setOverwrite(True)
    btlNvmHeaderFile.setDestPath("/bootloader/")
    btlNvmHeaderFile.setProjectPath("config/" + configName + "/bootloader/")
    btlNvmHeaderFile.setType("HEADER")

    btlDatastreamHeaderFile = bootloaderComponent.createFileSymbol("BOOTLOADER_DATASTREAM_HEADER", None)
    btlDatastreamHeaderFile.setSourcePath("../bootloader/templates/src/unified/datastream/datastream.h")
    btlDatastreamHeaderFile.setOutputName("datastream.h")
    btlDatastreamHeaderFile.setOverwrite(True)
    btlDatastreamHeaderFile.setDestPath("/bootloader/datastream/")
    btlDatastreamHeaderFile.setProjectPath("config/" + configName + "/bootloader/datastream/")
    btlDatastreamHeaderFile.setType("HEADER")

    btlDatastreamUsbHIDSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_DATASTREAM_USB_DEVICE_HID_SRC", None)
    btlDatastreamUsbHIDSourceFile.setSourcePath("../bootloader/templates/src/unified/datastream/datastream_usb_device_hid.c.ftl")
    btlDatastreamUsbHIDSourceFile.setOutputName("datastream_usb_device_hid.c")
    btlDatastreamUsbHIDSourceFile.setMarkup(True)
    btlDatastreamUsbHIDSourceFile.setOverwrite(True)
    btlDatastreamUsbHIDSourceFile.setDestPath("/bootloader/datastream/")
    btlDatastreamUsbHIDSourceFile.setProjectPath("config/" + configName + "/bootloader/datastream/")
    btlDatastreamUsbHIDSourceFile.setType("SOURCE")

    # Generate Initialization File
    btlInitFile = bootloaderComponent.createFileSymbol("INITIALIZATION_BOOTLOADER_C", None)
    if ("PIC32M" in Variables.get("__PROCESSOR")):
        btlInitFile.setSourcePath("../bootloader/templates/mips/initialization.c.ftl")
    else:
        btlInitFile.setSourcePath("../bootloader/templates/arm/initialization.c.ftl")
    btlInitFile.setOutputName("initialization.c")
    btlInitFile.setMarkup(True)
    btlInitFile.setOverwrite(True)
    btlInitFile.setDestPath("")
    btlInitFile.setProjectPath("config/" + configName + "/")
    btlInitFile.setType("SOURCE")

    btlSystemTasksFile = bootloaderComponent.createFileSymbol("BOOTLOADER_SYS_TASK", None)
    btlSystemTasksFile.setType("STRING")
    btlSystemTasksFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_DRIVER_TASKS")
    btlSystemTasksFile.setSourcePath("../bootloader/templates/system/tasks.c.ftl")
    btlSystemTasksFile.setMarkup(True)

    btlSystemDefFile = bootloaderComponent.createFileSymbol("BTL_SYS_DEF_HEADER", None)
    btlSystemDefFile.setType("STRING")
    btlSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    btlSystemDefFile.setSourcePath("../bootloader/templates/system/definitions.h.ftl")
    btlSystemDefFile.setMarkup(True)

    if ("PIC32M" in Variables.get("__PROCESSOR")):
        generateLinkerFileSymbol(bootloaderComponent)
    else:
        # XC32-LD option to set values of ROM_LENGTH, RAM_ORIGIN, RAM_LENGTH from default linker files for SAM devices
        xc32LdPreprocessroMacroSym = bootloaderComponent.createSettingSymbol("BOOTLOADER_XC32_LINKER_PREPROC_MARCOS", None)
        xc32LdPreprocessroMacroSym.setHelp("mcc_h3_usb_bootloader_configurations")
        xc32LdPreprocessroMacroSym.setCategory("C32-LD")
        xc32LdPreprocessroMacroSym.setKey("preprocessor-macros")
        xc32LdPreprocessroMacroSym.setValue(getLinkerParams(0, 0))
        xc32LdPreprocessroMacroSym.setAppend(True, ";=")
        xc32LdPreprocessroMacroSym.setDependencies(setLinkerParams, ["BTL_SIZE", "BTL_TRIGGER_LEN", "BTL_LIVE_UPDATE"])

    generateCommonFiles(bootloaderComponent)

    setOptimizationLevel(bootloaderComponent, "-O2")

def onAttachmentConnected(source, target):
    global flash_erase_size

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    srcID = source["id"]
    targetID = target["id"]

    if (srcID == "btl_USB_DEVICE_HID_dependency"):
        hidIndex = remoteComponent.getSymbolByID("CONFIG_USB_DEVICE_FUNCTION_INDEX").getValue()

        localComponent.getSymbolByID("USB_DEVICE_INDEX").setValue(hidIndex)

        # Configure USB Component
        remoteComponent.getSymbolByID("CONFIG_USB_DEVICE_HID_REPORT_DESCRIPTOR_TYPE").setValue("Custom")

    if (srcID == "btl_MEMORY_dependency"):
        flash_erase_size = int(Database.getSymbolValue(remoteID, "FLASH_ERASE_SIZE"))
        localComponent.getSymbolByID("MEM_USED").setValue(remoteID.upper())

        Database.setSymbolValue(remoteID, "INTERRUPT_ENABLE", False)

def onAttachmentDisconnected(source, target):
    global flash_erase_size

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    srcID = source["id"]
    targetID = target["id"]

    if (srcID == "btl_USB_DEVICE_HID_dependency"):
        localComponent.getSymbolByID("USB_DEVICE_INDEX").clearValue()

    if (srcID == "btl_MEMORY_dependency"):
        flash_erase_size = 0
        localComponent.getSymbolByID("MEM_USED").clearValue()

def finalizeComponent(bootloaderComponent):
    activateAndConnectDependencies("usb_device_hid_bootloader")
