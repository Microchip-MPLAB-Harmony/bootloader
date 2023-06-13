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
global btl_dram_start

btl_dram_start = {
                     "CORTEX-A5"   : "0x26F00000",
                     "CORTEX-A7"   : "0x66F00000",
                     "ARM926EJ-S"  : "0x23F00000"
                 }

def activateAndConnectDependencies(component):
    return

def calcBootloaderSize():
    coreArch     = Database.getSymbolValue("core", "CoreArchitecture")

    # Get the Maximum bootloader size value defined in bootloader protocol python file
    btl_size = getMaxBootloaderSize(coreArch)

    return btl_size

def setBtlStartCommentVisible(symbol, event):
    if (int(Database.getSymbolValue("core", "APP_START_ADDRESS"), 16) != int(Database.getSymbolValue("uart_bootloader", "BTL_START"), 16)):
        symbol.setLabel("WARNING!!! Bootloader Start Address Should be set to " + Database.getSymbolValue("uart_bootloader", "BTL_START") + " !!!")
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def generateSysfsFileSymbol(bootloaderComponent):
    btlSystemTasksFile = bootloaderComponent.createFileSymbol("BOOTLOADER_SYS_TASK", None)
    btlSystemTasksFile.setType("STRING")
    btlSystemTasksFile.setOutputName("core.LIST_SYSTEM_TASKS_C_CALL_DRIVER_TASKS")
    btlSystemTasksFile.setSourcePath("../bootloader/templates/system/tasks.c.ftl")
    btlSystemTasksFile.setMarkup(True)

def generateApplicationSymbol(bootloaderComponent):
    global btlStart
    global btlSize

    btlAppImagePath = bootloaderComponent.createStringSymbol("BTL_APP_IMAGE_PATH", None)
    btlAppImagePath.setHelp("btl_helpkeyword")
    btlAppImagePath.setLabel("Application Binary Image Path")
    btlAppImagePath.setVisible(True)
    btlAppImagePath.setDefaultValue("harmony.bin")

    btlAppStart = bootloaderComponent.createStringSymbol("BTL_APP_START", None)
    btlAppStart.setHelp(btl_helpkeyword)
    btlAppStart.setLabel("Application Start Address")
    btlAppStart.setDefaultValue(Database.getSymbolValue("core", "DDRAM_CACHE_START_ADDR"))

def generateCommonSymbols(bootloaderComponent):
    global btl_dram_start
    global btl_type
    global btl_helpkeyword
    global btlStart
    global btlSize

    btlType = bootloaderComponent.createStringSymbol("BTL_TYPE", None)
    btlType.setHelp(btl_helpkeyword)
    btlType.setLabel("Bootloader Type")
    btlType.setReadOnly(True)
    btlType.setVisible(False)
    btlType.setDefaultValue(btl_type)

    btlStart = bootloaderComponent.createStringSymbol("BTL_START", None)
    btlStart.setHelp(btl_helpkeyword)
    btlStart.setLabel("Bootloader Start Address")
    btlStart.setVisible(False)
    btlStart.setDefaultValue(btl_dram_start[ATDF.getNode("/avr-tools-device-file/devices/device").getAttribute("architecture")])

    btl_size = calcBootloaderSize()

    btlSize = bootloaderComponent.createStringSymbol("BTL_SIZE", None)
    btlSize.setHelp(btl_helpkeyword)
    btlSize.setLabel("Bootloader Size (Bytes)")
    btlSize.setVisible(False)
    btlSize.setDefaultValue(str(btl_size))

    btlAddrComment = bootloaderComponent.createCommentSymbol("BTL_START_ADDR_COMMENT", None)
    btlAddrComment.setVisible(False)
    btlAddrComment.setDependencies(setBtlStartCommentVisible, ["core.APP_START_ADDRESS", "BTL_START"])

    btl_start_addr = {}
    btl_start_addr = Database.sendMessage("core", "APP_START_ADDRESS", {"start_address": btlStart.getValue()})

    generateSysfsFileSymbol(bootloaderComponent)

    generateApplicationSymbol(bootloaderComponent)

    btlDriverUsed = bootloaderComponent.createStringSymbol("DRIVER_USED", None)
    btlDriverUsed.setHelp(btl_helpkeyword)
    btlDriverUsed.setLabel("Bootloader Memory Used")
    btlDriverUsed.setReadOnly(True)
    btlDriverUsed.setDefaultValue("")
    btlDriverUsed.setVisible(False)

    btlExternalMemoryImageAddr = bootloaderComponent.createStringSymbol("BTL_EXT_MEM_IMG_ADDR", btlDriverUsed)
    btlExternalMemoryImageAddr.setHelp(btl_helpkeyword)
    btlExternalMemoryImageAddr.setLabel("External Memory App Image Address")
    btlExternalMemoryImageAddr.setDefaultValue("0x00200000")

    btlExternalMemoryMetadataAddr = bootloaderComponent.createStringSymbol("BTL_EXT_MEM_METADATA_ADDR", btlDriverUsed)
    btlExternalMemoryMetadataAddr.setHelp(btl_helpkeyword)
    btlExternalMemoryMetadataAddr.setLabel("External Memory Metadata Address")
    btlExternalMemoryMetadataAddr.setDefaultValue("0x00180000")

def generateHwCRCGeneratorSymbol(bootloaderComponent):
    global btl_helpkeyword

    btlHwCrc = bootloaderComponent.createBooleanSymbol("BTL_HW_CRC_GEN", None)
    btlHwCrc.setHelp(btl_helpkeyword)
    btlHwCrc.setLabel("Bootloader Hardware CRC Generator")
    btlHwCrc.setReadOnly(True)
    btlHwCrc.setVisible(False)
    btlHwCrc.setDefaultValue(False)

def generateCommonFiles(bootloaderComponent):
    configName = Variables.get("__CONFIGURATION_NAME")

    btlCommonSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_COMMON_SOURCE", None)
    btlCommonSourceFile.setSourcePath("../bootloader/templates/src/bootloader_common_mpu.c.ftl")
    btlCommonSourceFile.setOutputName("bootloader_common.c")
    btlCommonSourceFile.setMarkup(True)
    btlCommonSourceFile.setOverwrite(True)
    btlCommonSourceFile.setDestPath("/bootloader/")
    btlCommonSourceFile.setProjectPath("config/" + configName + "/bootloader/")
    btlCommonSourceFile.setType("SOURCE")

    btlCommonHeaderFile = bootloaderComponent.createFileSymbol("BOOTLOADER_COMMON_HEADER", None)
    btlCommonHeaderFile.setSourcePath("../bootloader/templates/src/bootloader_common_mpu.h.ftl")
    btlCommonHeaderFile.setOutputName("bootloader_common.h")
    btlCommonHeaderFile.setMarkup(True)
    btlCommonHeaderFile.setOverwrite(True)
    btlCommonHeaderFile.setDestPath("/bootloader/")
    btlCommonHeaderFile.setProjectPath("config/" + configName + "/bootloader/")
    btlCommonHeaderFile.setType("HEADER")

    btlMpuStorageSrcFile = bootloaderComponent.createFileSymbol("BOOTLOADER_STORAGE_SOURCE", None)
    btlMpuStorageSrcFile.setSourcePath("../bootloader/templates/src/mpu/bootloader_storage_fs.c.ftl")
    btlMpuStorageSrcFile.setOutputName("bootloader_storage.c")
    btlMpuStorageSrcFile.setMarkup(True)
    btlMpuStorageSrcFile.setOverwrite(True)
    btlMpuStorageSrcFile.setDestPath("/bootloader/")
    btlMpuStorageSrcFile.setProjectPath("config/" + configName + "/bootloader/")
    btlMpuStorageSrcFile.setType("SOURCE")

    btlMpuStorageHeaderFile = bootloaderComponent.createFileSymbol("BOOTLOADER_STORAGE_HEADER", None)
    btlMpuStorageHeaderFile.setSourcePath("../bootloader/templates/src/mpu/bootloader_storage.h.ftl")
    btlMpuStorageHeaderFile.setOutputName("bootloader_storage.h")
    btlMpuStorageHeaderFile.setMarkup(True)
    btlMpuStorageHeaderFile.setOverwrite(True)
    btlMpuStorageHeaderFile.setDestPath("/bootloader/")
    btlMpuStorageHeaderFile.setProjectPath("config/" + configName + "/bootloader/")
    btlMpuStorageHeaderFile.setType("HEADER")

def setOptimizationLevel(bootloaderComponent, optimizationLevel):
    # Set Optimization level based on input
    xc32Optimization = bootloaderComponent.createSettingSymbol("XC32_OPTIMIZATION", None)
    xc32Optimization.setCategory("C32")
    xc32Optimization.setKey("optimization-level")
    xc32Optimization.setValue(optimizationLevel)
