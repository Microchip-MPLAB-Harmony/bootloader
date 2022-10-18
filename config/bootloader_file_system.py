"""*****************************************************************************
* Copyright (C) 2021 Microchip Technology Inc. and its subsidiaries.
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

btl_helpkeyword = "mcc_h3_fs_bootloader"

# Do not Change Order
mediaList = ["SDCARD", "SERIAL_MEMORY", "USB_HOST_MSD"]

btl_type = mediaList[0]

bootloaderCore = ""

USBNames        = ["USB", "USBHS"]

def hasPeripheral(peripheralList):
    periphNode          = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
    peripherals         = periphNode.getChildren()

    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))

        if ((any(x == periphName for x in peripheralList) == True)):
            return True

    return False

# Maximum Size for Bootloader [BYTES]
if ("PIC32M" in Variables.get("__PROCESSOR")):
    bootloaderCore = "bootloader_mips.py"
    sdcard_btlSizes = {
                "PIC32MX"     : [49152],
                "PIC32MK"     : [49152],
                "PIC32MM1324" : [32768],
                "PIC32MM1387" : [32768],
                "PIC32MZDA"   : [53248],
                "PIC32MZEF"   : [53248],
                "PIC32MZW"    : [53248],
    }

    serial_memory_btlSizes = {
                "PIC32MX"     : [40960],
                "PIC32MK"     : [36864],
                "PIC32MM1324" : [24576],
                "PIC32MM1387" : [24576],
                "PIC32MZDA"   : [49152],
                "PIC32MZEF"   : [49152],
                "PIC32MZW"    : [45056],
    }

    usb_host_msd_btlSizes = {
                "PIC32MX"     : [69632],
                "PIC32MK"     : [65536],
                "PIC32MM1387" : [45056],
                "PIC32MZDA"   : [81920],
                "PIC32MZEF"   : [81920],
                "PIC32MZW"    : [69632],
    }
else:
    bootloaderCore = "bootloader_arm.py"
    sdcard_btlSizes = {
                "CORTEX-M0PLUS"     : [29696],
                "CORTEX-M23"        : [29696],
                "CORTEX-M4"         : [32768],
                "CORTEX-M7"         : [32768],
    }

    serial_memory_btlSizes = {
                "CORTEX-M0PLUS"     : [21504],
                "CORTEX-M23"        : [21504],
                "CORTEX-M4"         : [24576],
                "CORTEX-M7"         : [24576],
    }

    usb_host_msd_btlSizes = {
                "CORTEX-M0PLUS"     : [43008],
                "CORTEX-M23"        : [43008],
                "CORTEX-M4"         : [40960],
                "CORTEX-M7"         : [40960],
    }

btlSize_dict = {
    mediaList[0]    : sdcard_btlSizes,
    mediaList[1]    : serial_memory_btlSizes,
    mediaList[2]    : usb_host_msd_btlSizes,
}

def getMaxBootloaderSize(arch):
    global btlSizes
    global btl_type

    btlSizes = btlSize_dict[btl_type]

    if (arch in btlSizes):
        return btlSizes[arch][0]
    else:
        return 0

# Call bootloader core python
execfile(Module.getPath() + "/config/" + bootloaderCore)

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

    btlLength = int(component.getSymbolByID("BTL_SIZE").getValue())
    triggerLength = int(component.getSymbolByID("BTL_TRIGGER_LEN").getValue())

    linkerParams = getLinkerParams(btlLength, triggerLength)

    symbol.setValue(linkerParams)

def setMediaInformation(symbol, event):
    global btl_type

    component = symbol.getComponent()

    btl_type = component.getSymbolByID("MEDIA_TYPE").getSelectedKey()

    component.getSymbolByID("BTL_TYPE").setValue(btl_type)

    btlSize = str(calcBootloaderSize())

    component.getSymbolByID("BTL_SIZE").setReadOnly(True)
    component.getSymbolByID("BTL_SIZE").setValue(btlSize)
    component.getSymbolByID("BTL_SIZE").setReadOnly(False)

    component.getSymbolByID("BOOTLOADER_SRC").setOutputName("bootloader_" + btl_type.lower() + ".c")
    component.getSymbolByID("BOOTLOADER_HEADER").setOutputName("bootloader_" + btl_type.lower() + ".h")

def setupCoreComponentSymbols():

    coreComponent = Database.getComponentByID("core")

    coreComponent.getSymbolByID("CoreSysInitFile").setValue(False)

    coreComponent.getSymbolByID("XC32_LINKER_PREPROC_MARCOS").setEnabled(False)

def instantiateComponent(bootloaderComponent):
    configName = Variables.get("__CONFIGURATION_NAME")

    btlMediaType = bootloaderComponent.createKeyValueSetSymbol("MEDIA_TYPE", None)
    btlMediaType.setHelp("btl_helpkeyword")
    btlMediaType.setLabel("Bootloader Media Type")
    btlMediaType.addKey(mediaList[0], "0", "SDCARD")
    btlMediaType.addKey(mediaList[1], "1", "Serial Memory")
    if (hasPeripheral(USBNames) == True):
        btlMediaType.addKey(mediaList[2]  , "2", "USB Mass Storage Device")
    btlMediaType.setOutputMode("Key")
    btlMediaType.setDisplayMode("Description")
    btlMediaType.setDefaultValue(0)
    btlMediaType.setDependencies(setMediaInformation, ["MEDIA_TYPE"])

    setupCoreComponentSymbols()

    generateCommonSymbols(bootloaderComponent)

    btlAppImagePath = bootloaderComponent.createStringSymbol("APP_IMAGE_PATH", None)
    btlAppImagePath.setHelp("btl_helpkeyword")
    btlAppImagePath.setLabel("Application Binary Image Path")
    btlAppImagePath.setVisible(True)
    btlAppImagePath.setDefaultValue("image.bin")


    #################### Code Generation ####################

    btlSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_SRC", None)
    btlSourceFile.setSourcePath("../bootloader/templates/src/fs/bootloader.c.ftl")
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
        xc32LdPreprocessroMacroSym.setCategory("C32-LD")
        xc32LdPreprocessroMacroSym.setKey("preprocessor-macros")
        xc32LdPreprocessroMacroSym.setValue(getLinkerParams(0, 0))
        xc32LdPreprocessroMacroSym.setAppend(True, ";=")
        xc32LdPreprocessroMacroSym.setDependencies(setLinkerParams, ["BTL_SIZE", "BTL_TRIGGER_LEN"])

    generateCommonFiles(bootloaderComponent)

    setOptimizationLevel(bootloaderComponent, "-O2")

def onAttachmentConnected(source, target):
    global flash_erase_size

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    srcID = source["id"]
    targetID = target["id"]

    if (srcID == "btl_SYS_FS_dependency"):
        # Configure SYS_FS Component
        remoteComponent.getSymbolByID("SYS_FS_AUTO_MOUNT").setValue(True)
        remoteComponent.getSymbolByID("SYS_FS_FAT_READONLY").setValue(True)

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

    if (srcID == "btl_SYS_FS_dependency"):
        # Deconfigure SYS_FS Component
        remoteComponent.getSymbolByID("SYS_FS_AUTO_MOUNT").setValue(False)
        remoteComponent.getSymbolByID("SYS_FS_FAT_READONLY").setValue(False)

    if (srcID == "btl_MEMORY_dependency"):
        flash_erase_size = 0
        localComponent.getSymbolByID("MEM_USED").clearValue()

def finalizeComponent(bootloaderComponent):
    res = Database.activateComponents(["sys_fs"])

    activateAndConnectDependencies("file_system_bootloader")
