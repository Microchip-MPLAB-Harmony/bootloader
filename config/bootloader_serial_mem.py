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

btl_type = "SERIAL_MEM"
btl_helpkeyword = "mcc_h3_serial_bootloader_configurations"
bootloaderCore = ""

# Maximum Size for Bootloader [BYTES]
if ("PIC32M" in Variables.get("__PROCESSOR")):
    bootloaderCore = "bootloader_mips.py"
    btlSizes = {
                "PIC32MX"     : [12288],
                "PIC32MK"     : [12288],
                "PIC32MM1324" : [8192],
                "PIC32MM1387" : [8192],
                "PIC32MZDA"   : [10240],
                "PIC32MZEF"   : [10240],
                "PIC32MZW"    : [16384],
    }
else:
    bootloaderCore = "bootloader_arm.py"
    btlSizes = {
                "CORTEX-M0PLUS"     : [8192],
                "CORTEX-M23"        : [8192],
                "CORTEX-M4"         : [8192],
                "CORTEX-M7"         : [8192],
    }

def getMaxBootloaderSize(arch):

    if (arch in btlSizes):
        return btlSizes[arch][0]
    else:
        return 0

# Call bootloader core python
execfile(Module.getPath() + "/config/" + bootloaderCore)

def handleMessage(messageID, args):

    result_dict = {}

    return result_dict

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

def setupCoreComponentSymbols():

    coreComponent = Database.getComponentByID("core")

    # Disable core related file generation not required for bootloader
    coreComponent.getSymbolByID("XC32_LINKER_PREPROC_MARCOS").setEnabled(False)

def setSerialMemEraseEnable(symbol, event):
    symbol.setValue(event["value"])

def instantiateComponent(bootloaderComponent):
    configName = Variables.get("__CONFIGURATION_NAME")

    setupCoreComponentSymbols()

    btlDriverUsed = bootloaderComponent.createStringSymbol("DRIVER_USED", None)
    btlDriverUsed.setHelp(btl_helpkeyword)
    btlDriverUsed.setLabel("Bootloader Serial Memory Used")
    btlDriverUsed.setReadOnly(True)
    btlDriverUsed.setDefaultValue("")

    generateCommonSymbols(bootloaderComponent)

    generateHwCRCGeneratorSymbol(bootloaderComponent)

    btlSerialMemEraseEnable = bootloaderComponent.createBooleanSymbol("SERIAL_MEM_ERASE_ENABLE", None)
    btlSerialMemEraseEnable.setHelp(btl_helpkeyword)
    btlSerialMemEraseEnable.setLabel("Enable Erase for Serial Memory")
    btlSerialMemEraseEnable.setVisible(False)
    btlSerialMemEraseEnable.setDefaultValue(False)
    btlSerialMemEraseEnable.setReadOnly(True)
    btlSerialMemEraseEnable.setDependencies(setSerialMemEraseEnable, ["btl_MEMORY_dependency:ERASE_ENABLE"])

    #################### Code Generation ####################

    btlSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_SRC", None)
    btlSourceFile.setSourcePath("../bootloader/templates/src/optimized/bootloader_serial_mem.c.ftl")
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
        xc32LdPreprocessroMacroSym.setHelp("btl_helpkeyword")
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

    if (srcID == "btl_MEMORY_dependency"):
        flash_erase_size = int(Database.getSymbolValue(remoteID, "FLASH_ERASE_SIZE"))
        localComponent.getSymbolByID("MEM_USED").setValue(remoteID.upper())

        Database.setSymbolValue(remoteID, "INTERRUPT_ENABLE", False)

    elif (srcID == "btl_MEMORY_dependency_SERIAL"):
        localComponent.getSymbolByID("DRIVER_USED").clearValue()
        localComponent.getSymbolByID("DRIVER_USED").setValue(remoteID.upper())

        localComponent.getSymbolByID("SERIAL_MEM_ERASE_ENABLE").setValue(remoteComponent.getSymbolValue("ERASE_ENABLE"))

        # Set the number of buffer descriptor for SST26 with SQI peripheral on PIC32MZ devices
        if(Database.getSymbolValue(remoteID, remoteID.upper() + "_NUM_BUFFER_DESC") != None):
            remoteComponent.getSymbolByID(remoteID.upper() + "_NUM_BUFFER_DESC").setValue((flash_erase_size/ 256))

def onAttachmentDisconnected(source, target):
    global flash_erase_size

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    srcID = source["id"]
    targetID = target["id"]

    if (srcID == "btl_MEMORY_dependency"):
        flash_erase_size = 0
        localComponent.getSymbolByID("MEM_USED").clearValue()

    elif (srcID == "btl_MEMORY_dependency_SERIAL"):
        localComponent.getSymbolByID("DRIVER_USED").clearValue()
        localComponent.getSymbolByID("SERIAL_MEM_ERASE_ENABLE").clearValue()
        Database.clearSymbolValue(remoteID, remoteID.upper() + "_NUM_BUFFER_DESC")

def finalizeComponent(bootloaderComponent):
    activateAndConnectDependencies("serial_mem_bootloader")
