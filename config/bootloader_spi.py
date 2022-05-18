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

btl_type = "SPI"
btl_helpkeyword = "mcc_h3_spi_bootloader_configurations"
bootloaderCore = ""

# Maximum Size for Bootloader [BYTES]
if ("PIC32M" in Variables.get("__PROCESSOR")):
    bootloaderCore = "bootloader_mips.py"
    btlSizes = {
                "PIC32MX"     : [8192],
                "PIC32MK"     : [12288],
                "PIC32MM1324" : [6144],
                "PIC32MM1387" : [6144],
                "PIC32MZDA"   : [16384],
                "PIC32MZEF"   : [16384],
                "PIC32MZW"    : [12288],
    }
else:
    bootloaderCore = "bootloader_arm.py"
    btlSizes = {
                "CORTEX-M0PLUS"     : [4096],
                "CORTEX-M23"        : [4096],
                "CORTEX-M4"         : [4096],
                "CORTEX-M7"         : [4096],
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

    if (messageID == "REQUEST_CONFIG_PARAMS"):
        if args.get("localComponentID") != None:
            result_dict = Database.sendMessage(args["localComponentID"], "SPI_SLAVE_MODE", {"isEnabled":True, "isReadOnly":True})
            #result_dict = Database.sendMessage(args["localComponentID"], "SPI_SLAVE_RX_BUFFER_SIZE", {"size":300})
            #result_dict = Database.sendMessage(args["localComponentID"], "SPI_SLAVE_TX_BUFFER_SIZE", {"size":32})

    return result_dict

def setBtlDualBankCommentVisible(symbol, event):
    symbol.setVisible(event["value"])

def setupCoreComponentSymbols():

    coreComponent = Database.getComponentByID("core")

    # Disable core related file generation not required for bootloader
    coreComponent.getSymbolByID("CoreMainFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysInitFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysStartupFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysCallsFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysIntFile").setValue(True)

    coreComponent.getSymbolByID("CoreSysExceptionFile").setValue(True)

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

    generateCommonSymbols(bootloaderComponent)

    generateFuseProgrammingAndWDTSymbols(bootloaderComponent)

    generateHwCRCGeneratorSymbol(bootloaderComponent)

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
    btlDualBank.setVisible(btlDualBankEnable)

    btlDualBankComment = bootloaderComponent.createCommentSymbol("BTL_DUAL_BANK_COMMENT", None)
    btlDualBankComment.setHelp(btl_helpkeyword)
    btlDualBankComment.setLabel("!!! WARNING Only Half of the Flash memory will be available for Application !!!")
    btlDualBankComment.setVisible(False)
    btlDualBankComment.setDependencies(setBtlDualBankCommentVisible, ["BTL_DUAL_BANK"])

    #################### Code Generation ####################

    btlSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_SRC", None)
    if ("PIC32M" in Variables.get("__PROCESSOR")):
        btlSourceFile.setSourcePath("../bootloader/templates/src/optimized/bootloader_spi_mips.c.ftl")
    else:
        btlSourceFile.setSourcePath("../bootloader/templates/src/optimized/bootloader_spi_arm.c.ftl")
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

    if (srcID == "btl_SPI_dependency"):
        periph_name = Database.getSymbolValue(remoteID, "SPI_PLIB_API_PREFIX")

        localComponent.getSymbolByID("PERIPH_USED").clearValue()
        localComponent.getSymbolByID("PERIPH_USED").setValue(periph_name)

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
    dummyDict = {}

    if (srcID == "btl_SPI_dependency"):
        localComponent.getSymbolByID("PERIPH_USED").clearValue()

        dummyDict = Database.sendMessage(remoteID, "SPI_SLAVE_MODE", {"isReadOnly":False})

    if (srcID == "btl_MEMORY_dependency"):
        flash_erase_size = 0
        localComponent.getSymbolByID("MEM_USED").clearValue()

def finalizeComponent(bootloaderComponent):
    activateAndConnectDependencies("spi_bootloader")