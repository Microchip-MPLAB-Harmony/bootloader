"""*****************************************************************************
* Copyright (C) 2023 Microchip Technology Inc. and its subsidiaries.
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
global btlDualBankEnable

btl_type = "OTA"
btl_helpkeyword = "mcc_h3_ota_bootloader_configurations"
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
# Call bootloader RTOS python
execfile(Module.getPath() + "/config/bootloader_rtos.py")

def handleMessage(messageID, args):

    result_dict = {}

    return result_dict

def getLinkerParams(btlLength, triggerLength):
    global ram_start
    global ram_size
    global place_btl_in_bfm

    romLen      = str(hex(btlLength))

    ramStart    = str(hex((int(ram_start, 16) + triggerLength)))
    ramLen      = str(hex((int(ram_size, 16) - triggerLength)))

    rom_length  = "ROM_LENGTH=" + romLen
    ram_origin  = "RAM_ORIGIN=" + ramStart
    ram_length  = "RAM_LENGTH=" + ramLen
    
    if place_btl_in_bfm == True:
        rom_origin  = "ROM_ORIGIN=BOOT_ROM_ORIGIN"
        return (rom_origin + ";" + rom_length + ";" + ram_origin + ";" + ram_length)
    else:
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

def setOTAMemEraseEnable(symbol, event):
    symbol.setValue(event["value"])

def setBtlDualBankCommentVisible(symbol, event):
    symbol.setVisible(event["value"])

def instantiateComponent(bootloaderComponent):
    global btlDualBankEnable

    configName = Variables.get("__CONFIGURATION_NAME")

    setupCoreComponentSymbols()

    otaBtlEnable = bootloaderComponent.createBooleanSymbol("OTA_BOOTLOADER_ENABLE", None)
    otaBtlEnable.setVisible(False)
    otaBtlEnable.setDefaultValue(True)

    btlDriverUsed = bootloaderComponent.createStringSymbol("DRIVER_USED", None)
    btlDriverUsed.setHelp(btl_helpkeyword)
    btlDriverUsed.setLabel("Bootloader OTA Memory Used")
    btlDriverUsed.setReadOnly(True)
    btlDriverUsed.setDefaultValue("")

    generateCommonSymbols(bootloaderComponent)
    btlDriverUsed.getComponent().getSymbolByID("BTL_TRIGGER_ENABLE").setValue(False)
    btlDriverUsed.getComponent().getSymbolByID("BTL_TRIGGER_ENABLE").setVisible(False)

    generateHwCRCGeneratorSymbol(bootloaderComponent)

    btlOTAMemEraseEnable = bootloaderComponent.createBooleanSymbol("OTA_MEM_ERASE_ENABLE", None)
    btlOTAMemEraseEnable.setHelp(btl_helpkeyword)
    btlOTAMemEraseEnable.setLabel("Enable Erase for OTA Memory")
    btlOTAMemEraseEnable.setVisible(False)
    btlOTAMemEraseEnable.setDefaultValue(False)
    btlOTAMemEraseEnable.setReadOnly(True)
    btlOTAMemEraseEnable.setDependencies(setOTAMemEraseEnable, ["btl_MEMORY_dependency_OTA:ERASE_ENABLE"])

    btlDualBankEnable = False

    if (("SAME5" in Variables.get("__PROCESSOR")) or ("SAMD5" in Variables.get("__PROCESSOR"))):
        btlDualBankEnable = True
    elif ("PIC32MZ" in Variables.get("__PROCESSOR")):
        if (re.match("PIC32MZ.[0-9]*EF", Variables.get("__PROCESSOR")) or
            re.match("PIC32MZ.[0-9]*DA", Variables.get("__PROCESSOR"))):
            btlDualBankEnable = True
    elif ("PIC32MK" in Variables.get("__PROCESSOR")):
        if (re.match("PIC32MK.[0-9]*GPG", Variables.get("__PROCESSOR")) or
            re.match("PIC32MK.[0-9]*GPH", Variables.get("__PROCESSOR")) or
            re.match("PIC32MK.[0-9]*MCJ", Variables.get("__PROCESSOR")) or
            re.match("PIC32MK.[0-9]*MCA", Variables.get("__PROCESSOR"))):
            btlDualBankEnable = False
        else:
            btlDualBankEnable = True

    btlDualBank = bootloaderComponent.createBooleanSymbol("BTL_DUAL_BANK", None)
    btlDualBank.setHelp(btl_helpkeyword)
    btlDualBank.setLabel("Use Dual Bank For Safe Flash Update")
    btlDualBank.setDefaultValue(btlDualBankEnable)
    btlDualBank.setVisible(btlDualBankEnable)
    btlDualBank.setReadOnly(True)

    btlDualBankComment = bootloaderComponent.createCommentSymbol("BTL_DUAL_BANK_COMMENT", None)
    btlDualBankComment.setHelp(btl_helpkeyword)
    btlDualBankComment.setLabel("!!! WARNING Only Half of the Flash memory will be available for Application !!!")
    btlDualBankComment.setVisible(False)
    btlDualBankComment.setDependencies(setBtlDualBankCommentVisible, ["BTL_DUAL_BANK"])

    btlNumOfAppImage = bootloaderComponent.createIntegerSymbol("NUM_OF_APP_IMAGE", None)
    btlNumOfAppImage.setHelp(btl_helpkeyword)
    btlNumOfAppImage.setLabel("Number of application image storage")
    btlNumOfAppImage.setDefaultValue(2)
    btlNumOfAppImage.setMin(1)
    btlNumOfAppImage.setMax(15)

    #################### Code Generation ####################

    btlSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_SRC", None)
    btlSourceFile.setSourcePath("../bootloader/templates/src/ota/bootloader_ota.c.ftl")
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

    btlOtaControlBlockHeaderFile = bootloaderComponent.createFileSymbol("BOOTLOADER_OTA_CONTROL_BLOCK_HEADER", None)
    btlOtaControlBlockHeaderFile.setSourcePath("../bootloader/templates/src/ota/ota_service_control_block.h.ftl")
    btlOtaControlBlockHeaderFile.setOutputName("ota_service_control_block.h")
    btlOtaControlBlockHeaderFile.setMarkup(True)
    btlOtaControlBlockHeaderFile.setOverwrite(True)
    btlOtaControlBlockHeaderFile.setDestPath("/bootloader/")
    btlOtaControlBlockHeaderFile.setProjectPath("config/" + configName + "/bootloader/")
    btlOtaControlBlockHeaderFile.setType("HEADER")

    coreComponent = Database.getComponentByID("core")
    coreComponent.getSymbolByID("CoreMainFile").setValue(False)
    # generate main.c file
    btlmainSourceFile = bootloaderComponent.createFileSymbol("MAIN_BOOTLOADER_C", None)
    btlmainSourceFile.setSourcePath("../bootloader/templates/src/optimized/main.c.ftl")
    btlmainSourceFile.setOutputName("main.c")
    btlmainSourceFile.setMarkup(True)
    btlmainSourceFile.setOverwrite(False)
    btlmainSourceFile.setDestPath("../../")
    btlmainSourceFile.setProjectPath("")
    btlmainSourceFile.setType("SOURCE")

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

    nvmMemoryName = ""
    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))
        if ((any(x == periphName for x in NvmMemoryNames) == True)):
            nvmMemoryName = periphName
            break

    otaBtlNVMMemUsed = bootloaderComponent.createStringSymbol("NVM_MEM_USED", None)
    otaBtlNVMMemUsed.setReadOnly(True)
    otaBtlNVMMemUsed.setVisible(False)
    otaBtlNVMMemUsed.setDefaultValue(nvmMemoryName)

    # Generate RTOS specific Symbols
    rtosSettings = False
    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") == None) or (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") == "BareMetal"):
        rtosSettings = False
    else:
        rtosSettings = True
    generateRTOSSymbols(bootloaderComponent, rtosSettings)

def onAttachmentConnected(source, target):
    global flash_erase_size
    global btlDualBankEnable

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    srcID = source["id"]
    targetID = target["id"]

    if (srcID == "btl_MEMORY_dependency"):
        flash_erase_size = int(Database.getSymbolValue(remoteID, "FLASH_ERASE_SIZE"))
        localComponent.getSymbolByID("MEM_USED").setValue(remoteID.upper())

        Database.setSymbolValue(remoteID, "INTERRUPT_ENABLE", False)

    elif (srcID == "btl_MEMORY_dependency_OTA"):
        localComponent.getSymbolByID("DRIVER_USED").clearValue()
        localComponent.getSymbolByID("DRIVER_USED").setValue(remoteID.upper())

        localComponent.getSymbolByID("OTA_MEM_ERASE_ENABLE").setValue(remoteComponent.getSymbolValue("ERASE_ENABLE"))
        coreComponent = Database.getComponentByID("core")

        if remoteID.upper() == localComponent.getSymbolByID("NVM_MEM_USED").getValue():
            localComponent.setDependencyEnabled("btl_MEMORY_dependency", False)
            if btlDualBankEnable == True:
                localComponent.getSymbolByID("BTL_DUAL_BANK").setValue(True)
                localComponent.getSymbolByID("NUM_OF_APP_IMAGE").setReadOnly(True)
                localComponent.getSymbolByID("NUM_OF_APP_IMAGE").clearValue()
            flash_erase_size = int(Database.getSymbolValue(remoteID, "FLASH_ERASE_SIZE"))
            localComponent.getSymbolByID("MEM_USED").setValue(remoteID.upper())
            Database.setSymbolValue(remoteID, "INTERRUPT_ENABLE", False)
            coreComponent.getSymbolByID("CoreMainFile").setValue(False)
            localComponent.getSymbolByID("MAIN_BOOTLOADER_C").setEnabled(True)
            localComponent.getSymbolByID("BOOTLOADER_SYS_TASK").setEnabled(False)
        else:
            coreComponent.getSymbolByID("CoreMainFile").setValue(True)
            localComponent.getSymbolByID("MAIN_BOOTLOADER_C").setEnabled(False)
            localComponent.getSymbolByID("BOOTLOADER_SYS_TASK").setEnabled(True)

        # Set the number of buffer descriptor for SST26 with SQI peripheral on PIC32MZ devices
        if(Database.getSymbolValue(remoteID, remoteID.upper() + "_NUM_BUFFER_DESC") != None):
            remoteComponent.getSymbolByID(remoteID.upper() + "_NUM_BUFFER_DESC").setValue((flash_erase_size/ 256))

def onAttachmentDisconnected(source, target):
    global flash_erase_size
    global btlDualBankEnable

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    srcID = source["id"]
    targetID = target["id"]

    if (srcID == "btl_MEMORY_dependency"):
        flash_erase_size = 0
        localComponent.getSymbolByID("MEM_USED").clearValue()

    elif (srcID == "btl_MEMORY_dependency_OTA"):
        coreComponent = Database.getComponentByID("core")
        if remoteID.upper() == localComponent.getSymbolByID("NVM_MEM_USED").getValue():
            localComponent.setDependencyEnabled("btl_MEMORY_dependency", True)
            if btlDualBankEnable == True:
                localComponent.getSymbolByID("BTL_DUAL_BANK").setValue(False)
                localComponent.getSymbolByID("NUM_OF_APP_IMAGE").setReadOnly(False)
            flash_erase_size = 0
            localComponent.getSymbolByID("MEM_USED").clearValue()
            coreComponent.getSymbolByID("CoreMainFile").setValue(True)
            localComponent.getSymbolByID("MAIN_BOOTLOADER_C").setEnabled(False)
            localComponent.getSymbolByID("BOOTLOADER_SYS_TASK").setEnabled(True)
        else:
            coreComponent.getSymbolByID("CoreMainFile").setValue(False)
            localComponent.getSymbolByID("MAIN_BOOTLOADER_C").setEnabled(True)
            localComponent.getSymbolByID("BOOTLOADER_SYS_TASK").setEnabled(False)

        localComponent.getSymbolByID("DRIVER_USED").clearValue()
        localComponent.getSymbolByID("OTA_MEM_ERASE_ENABLE").clearValue()
        Database.clearSymbolValue(remoteID, remoteID.upper() + "_NUM_BUFFER_DESC")

def finalizeComponent(bootloaderComponent):
    global btlDualBankEnable

    nvmMemoryName = ""

    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))

        if ((any(x == periphName for x in NvmMemoryNames) == True)):
            nvmMemoryName = periphName.lower()
            break

    nvmMemoryCapabilityId = nvmMemoryName.upper() + "_MEMORY"

    if (btlDualBankEnable == True) and (bootloaderComponent.getSymbolByID("BTL_DUAL_BANK").getValue() == True):
        nvmMemoryDependencyId = "btl_MEMORY_dependency_OTA"
    else:
        nvmMemoryDependencyId = "btl_MEMORY_dependency"

    btlActivateTable = [nvmMemoryName]
    btlConnectTable  = [
        ["ota_bootloader", nvmMemoryDependencyId, nvmMemoryName, nvmMemoryCapabilityId]
    ]

    res = Database.activateComponents(btlActivateTable)
    res = Database.connectDependencies(btlConnectTable)

