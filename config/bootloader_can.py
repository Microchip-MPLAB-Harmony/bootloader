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
import re

global btlSizes
global btl_type
global btl_helpkeyword

btl_type = "CAN"
btl_helpkeyword = "mcc_h3_can_bootloader_configurations"

# Maximum Size for Bootloader [BYTES]
bootloaderCore = "bootloader_arm.py"
btlSizes = {
            "CORTEX-M0PLUS"     : [4096],
            "CORTEX-M4"         : [4096],
            "CORTEX-M7"         : [4096]
           }

def getMaxBootloaderSize(arch):

    if (arch in btlSizes):
        return btlSizes[arch][0]
    else:
        return 0

# Call bootloader core python
execfile(Module.getPath() + "/config/" + bootloaderCore)

def setBtlSymbolVisible(symbol, event):
    symbol.setVisible(event["value"])

def setupCoreComponentSymbols():

    coreComponent = Database.getComponentByID("core")

    # Disable core related file generation not required for bootloader
    coreComponent.getSymbolByID("CoreMainFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysInitFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysStartupFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysCallsFile").setValue(False)

    if ("PIC32M" not in Variables.get("__PROCESSOR")):
        coreComponent.getSymbolByID("CoreSysIntFile").setValue(False)

        coreComponent.getSymbolByID("CoreSysExceptionFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysStdioSyscallsFile").setValue(False)

    coreComponent.getSymbolByID("XC32_LINKER_PREPROC_MARCOS").setEnabled(False)

def instantiateComponent(bootloaderComponent):
    configName = Variables.get("__CONFIGURATION_NAME")

    setupCoreComponentSymbols()

    btlPeriphUsed = bootloaderComponent.createStringSymbol("PERIPH_USED", None)
    btlPeriphUsed.setHelp(btl_helpkeyword)
    btlPeriphUsed.setLabel("Bootloader Peripheral Used")
    btlPeriphUsed.setReadOnly(True)
    btlPeriphUsed.setDefaultValue("")

    btlPeriphName = bootloaderComponent.createStringSymbol("PERIPH_NAME", None)
    btlPeriphName.setHelp("btl_helpkeyword")
    btlPeriphName.setDefaultValue("")
    btlPeriphName.setVisible(False)

    btlCan = bootloaderComponent.createBooleanSymbol("BTL_CAN_PRESENT", None)
    btlCan.setHelp("btl_helpkeyword")
    btlCan.setDefaultValue(True)
    btlCan.setVisible(False)

    generateCommonSymbols(bootloaderComponent)

    generateFuseProgrammingAndWDTSymbols(bootloaderComponent)

    generateHwCRCGeneratorSymbol(bootloaderComponent)

    if (("SAME5" in Variables.get("__PROCESSOR")) or ("SAMD5" in Variables.get("__PROCESSOR"))):
        btlDualBankEnable = True
    else:
        btlDualBankEnable = False

    btlDualBank = bootloaderComponent.createBooleanSymbol("BTL_DUAL_BANK", None)
    btlDualBank.setHelp("btl_helpkeyword")
    btlDualBank.setLabel("Use Dual Bank For Safe Flash Update")
    btlDualBank.setVisible(btlDualBankEnable)

    btlDualBankComment = bootloaderComponent.createCommentSymbol("BTL_DUAL_BANK_COMMENT", None)
    btlDualBankComment.setHelp("btl_helpkeyword")
    btlDualBankComment.setLabel("!!! WARNING Only Half of the Flash memory will be available for Application !!!")
    btlDualBankComment.setVisible(False)
    btlDualBankComment.setDependencies(setBtlSymbolVisible, ["BTL_DUAL_BANK"])

    if Database.getSymbolValue("core", "CoreArchitecture") != "CORTEX-M0PLUS":
        btlMpuRegionNumber= bootloaderComponent.createComboSymbol("BTL_MPU_REGION_NUMBER", None, list(map(str, list(range(0, Database.getSymbolValue("core", "MPU_NUMBER_REGIONS"))))))
        btlMpuRegionNumber.setHelp("btl_helpkeyword")
        btlMpuRegionNumber.setLabel("Select MPU Region to configure non-cachable memory")
        btlMpuRegionNumber.setDefaultValue("0")
        btlMpuRegionNumber.setVisible(Database.getSymbolValue("core", "DATA_CACHE_ENABLE"))
        btlMpuRegionNumber.setDependencies(setBtlSymbolVisible, ["core.DATA_CACHE_ENABLE"])

        btlMpuRegionComment = bootloaderComponent.createCommentSymbol("BTL_MPU_REGION_COMMENT", None)
        btlMpuRegionComment.setHelp("btl_helpkeyword")
        btlMpuRegionComment.setLabel("!!! Configure minimum of 512 bytes region size for non-cacheble memory in MPU Configuration !!!")
        btlMpuRegionComment.setVisible(Database.getSymbolValue("core", "DATA_CACHE_ENABLE"))
        btlMpuRegionComment.setDependencies(setBtlSymbolVisible, ["core.DATA_CACHE_ENABLE"])

    #################### Code Generation ####################

    btlSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_SRC", None)
    btlSourceFile.setSourcePath("../bootloader/templates/src/optimized/bootloader_can_arm.c.ftl")
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

    # generate main.c file
    btlmainSourceFile = bootloaderComponent.createFileSymbol("MAIN_BOOTLOADER_C", None)
    btlmainSourceFile.setSourcePath("../bootloader/templates/src/optimized/main.c.ftl")
    btlmainSourceFile.setOutputName("main.c")
    btlmainSourceFile.setMarkup(True)
    btlmainSourceFile.setOverwrite(False)
    btlmainSourceFile.setDestPath("../../")
    btlmainSourceFile.setProjectPath("")
    btlmainSourceFile.setType("SOURCE")

    # Generate Initialization File
    btlInitFile = bootloaderComponent.createFileSymbol("INITIALIZATION_BOOTLOADER_C", None)
    btlInitFile.setSourcePath("../bootloader/templates/arm/initialization.c.ftl")
    btlInitFile.setOutputName("initialization.c")
    btlInitFile.setMarkup(True)
    btlInitFile.setOverwrite(True)
    btlInitFile.setDestPath("")
    btlInitFile.setProjectPath("config/" + configName + "/")
    btlInitFile.setType("SOURCE")

    btlSystemDefFile = bootloaderComponent.createFileSymbol("BTL_SYS_DEF_HEADER", None)
    btlSystemDefFile.setType("STRING")
    btlSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    btlSystemDefFile.setSourcePath("../bootloader/templates/system/definitions.h.ftl")
    btlSystemDefFile.setMarkup(True)

    if Variables.get("__TRUSTZONE_ENABLED") != None and Variables.get("__TRUSTZONE_ENABLED") == "true":
        btlSourceFile.setSecurity("SECURE")
        btlHeaderFile.setSecurity("SECURE")
        btlmainSourceFile.setSecurity("SECURE")
        btlInitFile.setSecurity("SECURE")
        btlInitFile.setSourcePath("../bootloader/templates/arm/initialization_secure.c.ftl")
        btlSystemDefFile.setSecurity("SECURE")
        btlSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_SECURE_H_INCLUDES")

    generateLinkerFileSymbol(bootloaderComponent)

    generateXC32SettingsAndFileSymbol(bootloaderComponent)

    generateCommonFiles(bootloaderComponent)

    setOptimizationLevel(bootloaderComponent, "-O2")

def onAttachmentConnected(source, target):
    global flash_erase_size

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    srcID = source["id"]
    targetID = target["id"]

    if (srcID == "btl_CAN_dependency"):
        localComponent.getSymbolByID("PERIPH_USED").clearValue()
        localComponent.getSymbolByID("PERIPH_USED").setValue(remoteID.upper())
        localComponent.getSymbolByID("PERIPH_NAME").setValue(re.sub('[0-9]', '', remoteID.upper()))
        Database.setSymbolValue(remoteID, "INTERRUPT_MODE", False)
        Database.setSymbolValue(remoteID, localComponent.getSymbolByID("PERIPH_NAME").getValue() + "_OPMODE", "CAN FD")
        Database.setSymbolValue(remoteID, "RXF1_USE", False)
        Database.setSymbolValue(remoteID, "RXF0_ELEMENTS", 5)
        Database.setSymbolValue(remoteID, "RXF0_BYTES_CFG", 7)
        Database.setSymbolValue(remoteID, "FILTERS_STD", 1)
        remoteComponent.getSymbolByID(localComponent.getSymbolByID("PERIPH_USED").getValue() + "_STD_FILTER1_SFID1").setValue(0x45A)
        remoteComponent.getSymbolByID(localComponent.getSymbolByID("PERIPH_USED").getValue() + "_STD_FILTER1_SFID2").setValue(0x45A)

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

    if (srcID == "btl_CAN_dependency"):
        localComponent.getSymbolByID("PERIPH_USED").clearValue()
        localComponent.getSymbolByID("PERIPH_NAME").clearValue()

    if (srcID == "btl_MEMORY_dependency"):
        flash_erase_size = 0
        localComponent.getSymbolByID("MEM_USED").clearValue()

def finalizeComponent(bootloaderComponent):
    activateAndConnectDependencies("can_bootloader")
