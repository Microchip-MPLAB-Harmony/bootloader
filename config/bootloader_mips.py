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

global ram_start
global ram_size

global flash_start
global flash_size
global flash_erase_size

global mx_devCfg_addr
global btl_start

flash_start         = 0
flash_size          = 0
flash_erase_size    = 0

mx_devCfg_addr      = "0xBFC02FF0"

btl_start           = "0x9FC01000"

NvmMemoryNames      = ["NVM"]
BootFlashNames      = ["bootconfig"]
ProgramFlashNames   = ["code"]
RamNames            = ["kseg0_data_mem", "kseg1_data_mem"]

addr_space          = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space")
addr_space_children = addr_space.getChildren()

periphNode          = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
peripherals         = periphNode.getChildren()

for mem_idx in range(0, len(addr_space_children)):
    mem_seg     = addr_space_children[mem_idx].getAttribute("name")
    mem_type    = addr_space_children[mem_idx].getAttribute("type")

    if ((any(x == mem_seg for x in ProgramFlashNames) == True)):
        flash_start = int(addr_space_children[mem_idx].getAttribute("start"), 16)
        flash_size  = int(addr_space_children[mem_idx].getAttribute("size"), 16)

    if ((any(x == mem_seg for x in RamNames) == True)):
        if (mem_seg == "kseg0_data_mem"):
            ram_start   = "0x80000000"
        else:
            ram_start   = "0xA0000000"
        ram_size    = addr_space_children[mem_idx].getAttribute("size")

    if ((btl_type != "UART") and (btl_type != "I2C")):
        if (("PIC32MX" in Variables.get("__PROCESSOR")) or
            ("PIC32MK" in Variables.get("__PROCESSOR"))):
            # Bootloader start address is in Program Flash memory as
            # Bootloader size is greater than Boot Flash Memory (3KB and 12KB)
            btl_start = "0x9D000000"
    else:
        if ("PIC32MX" in Variables.get("__PROCESSOR")):
            if ((any(x == mem_seg for x in BootFlashNames) == True)):
                if (addr_space_children[mem_idx].getAttribute("size") == "0xbf0"):
                    # Bootloader start address is in Program Flash memory as Boot Flash Memory is only 3KB
                    btl_start = "0x9D000000"
                    mx_devCfg_addr = "0xBFC00BF0"
                else:
                    # The bootloader code will be placed after the startup code ending at 0x9FC00490
                    btl_start = "0x9FC00500"
                    mx_devCfg_addr = "0xBFC02FF0"

def activateAndConnectDependencies(component):
    global btl_type

    nvmMemoryName = ""

    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))

        if ((any(x == periphName for x in NvmMemoryNames) == True)):
            nvmMemoryName = periphName.lower()
            break

    nvmMemoryCapabilityId = nvmMemoryName.upper() + "_MEMORY"

    if (btl_type == "UART"):
        btlActivateTable = [nvmMemoryName, "core_timer"]
        btlConnectTable  = [
            [component, "btl_MEMORY_dependency", nvmMemoryName, nvmMemoryCapabilityId],
            [component, "btl_TIMER_dependency", "core_timer", "CORE_TIMER_TMR"]
        ]
    else:
        btlActivateTable = [nvmMemoryName]
        btlConnectTable  = [
            [component, "btl_MEMORY_dependency", nvmMemoryName, nvmMemoryCapabilityId]
        ]

    res = Database.activateComponents(btlActivateTable)
    res = Database.connectDependencies(btlConnectTable)

def calcBootloaderSize():
    global flash_erase_size

    coreFamily   = ATDF.getNode( "/avr-tools-device-file/devices/device" ).getAttribute( "family" )

    # Get the Maximum bootloader size value defined in bootloader protocol python file
    max_btl_size = getMaxBootloaderSize(coreFamily)

    if (max_btl_size == 0):
        return 0

    btl_size = 0

    if (flash_erase_size != 0):
        if (flash_erase_size >= max_btl_size):
            btl_size = flash_erase_size
        else:
            btl_size = max_btl_size

    return btl_size

def setBootloaderSize(symbol, event):
    btl_size = str(calcBootloaderSize())

    symbol.setValue(btl_size)

    if (btl_size != 0):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def setAppStartAndCommentVisible(symbol, event):
    global flash_start
    global flash_size

    # If Bootloader is placed in Program Flash Memory Space
    if (btl_start == "0x9D000000"):
        if (event["id"] == "BTL_SIZE"):
            btlSize = int(event["value"],10)

            if ((btlSize != 0) and (flash_erase_size != 0)):
                appStartAligned = btlSize

                # If the bootloader size is not aligned to Erase Block Size
                if ((btlSize % flash_erase_size) != 0):
                    appStartAligned = btlSize + (flash_erase_size - (btlSize % flash_erase_size))

                custom_app_start_addr = str(hex(flash_start + appStartAligned))
            else:
                custom_app_start_addr = str(hex(flash_start))

            Database.setSymbolValue("core", "APP_START_ADDRESS", custom_app_start_addr[2:])
        else:
            comment_enable      = True

            custom_app_start_addr = int(Database.getSymbolValue("core", "APP_START_ADDRESS"), 16)
            btl_size = calcBootloaderSize()

            if (custom_app_start_addr < (flash_start + btl_size)):
                symbol.setLabel("WARNING!!! Application Start Address Should be equal to or Greater than Bootloader Size !!!")
            elif (custom_app_start_addr >= (flash_start + flash_size)):
                symbol.setLabel("WARNING!!! Application Start Address is exceeding the Flash Memory Space !!!")
            elif ((flash_erase_size != 0) and (custom_app_start_addr % flash_erase_size != 0)):
                symbol.setLabel("WARNING!!! Application Start Address should be aligned to Erase block size ( "+ str(flash_erase_size) + " bytes ) of Flash memory !!!")
            else:
                comment_enable = False

            symbol.setVisible(comment_enable)

def setTriggerLenVisible(symbol, event):
    symbol.setVisible(event["value"])

def setFuseProgram(symbol, event):
    visibility = False

    if (event["value"] != ""):
        if (Database.getSymbolValue(event["value"].lower(), "FLASH_DEVCFG_START_ADDRESS") != None):
            visibility = True

    symbol.setVisible(visibility)

def setWDTEnable(symbol, event):
    result_dict = {}

    result_dict = Database.sendMessage("core", "WDT_ENABLE", {"isEnabled":event["value"]})

def generateCommonSymbols(bootloaderComponent):
    global ram_start
    global ram_size
    global btl_start
    global btl_type
    global btl_helpkeyword

    btlMemUsed = bootloaderComponent.createStringSymbol("MEM_USED", None)
    btlMemUsed.setHelp(btl_helpkeyword)
    btlMemUsed.setLabel("Bootloader NVM Memory Used")
    btlMemUsed.setReadOnly(True)
    btlMemUsed.setDefaultValue("")

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
    btlStart.setDefaultValue(btl_start)

    btl_size = calcBootloaderSize()

    btlSize = bootloaderComponent.createStringSymbol("BTL_SIZE", None)
    btlSize.setHelp(btl_helpkeyword)
    btlSize.setLabel("Bootloader Size (Bytes)")
    btlSize.setVisible(False)
    btlSize.setDefaultValue(str(btl_size))
    btlSize.setDependencies(setBootloaderSize, ["MEM_USED"])

    btlAppAddrComment = bootloaderComponent.createCommentSymbol("BTL_APP_START_ADDR_COMMENT", None)
    btlAppAddrComment.setVisible(False)
    btlAppAddrComment.setDependencies(setAppStartAndCommentVisible, ["core.APP_START_ADDRESS", "BTL_SIZE"])

    btlTriggerEnable = bootloaderComponent.createBooleanSymbol("BTL_TRIGGER_ENABLE", None)
    btlTriggerEnable.setHelp(btl_helpkeyword)
    btlTriggerEnable.setLabel("Enable Bootloader Trigger From Firmware")
    btlTriggerEnable.setDescription("This Option can be used to Force Trigger bootloader from application firmware after a soft reset.")

    btlTriggerLenDesc = "This option adds the provided offset to RAM Start address in bootloader linker script. \
                         Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader \
                         to check at reset."

    btlTriggerLen = bootloaderComponent.createStringSymbol("BTL_TRIGGER_LEN", btlTriggerEnable)
    btlTriggerLen.setHelp(btl_helpkeyword)
    btlTriggerLen.setLabel("Number Of Bytes To Reserve From Start Of RAM")
    btlTriggerLen.setVisible((btlTriggerEnable.getValue() == True))
    btlTriggerLen.setDefaultValue("0")
    btlTriggerLen.setDependencies(setTriggerLenVisible, ["BTL_TRIGGER_ENABLE"])
    btlTriggerLen.setDescription(btlTriggerLenDesc)

    btlRamStart = bootloaderComponent.createStringSymbol("BTL_RAM_START", None)
    btlRamStart.setDefaultValue(ram_start)
    btlRamStart.setReadOnly(True)
    btlRamStart.setVisible(False)

    btlRamSize = bootloaderComponent.createStringSymbol("BTL_RAM_SIZE", None)
    btlRamSize.setDefaultValue(ram_size)
    btlRamSize.setReadOnly(True)
    btlRamSize.setVisible(False)

    # Disable Control Register Locks
    result_dict = {}

    result_dict = Database.sendMessage("core", "CONTROL_REGISTER_LOCK", {"isEnabled":False})

def generateFuseProgrammingAndWDTSymbols(bootloaderComponent):
    global mx_devCfg_addr

    btlFuseProgramEnable = bootloaderComponent.createBooleanSymbol("BTL_FUSE_PROGRAM_ENABLE", None)
    btlFuseProgramEnable.setLabel("Enable Fuse Programming")
    btlFuseProgramEnable.setHelp(btl_helpkeyword)
    btlFuseProgramEnable.setDefaultValue(False)

    devCfgAddress = "0xBFC0FF40"

    if (re.match("PIC32MZ.[0-9]*EF", Variables.get("__PROCESSOR"))):
        devCfgAddress = "0xBFC0FF40"
    elif (re.match("PIC32MZ.[0-9]*DA", Variables.get("__PROCESSOR"))):
        devCfgAddress = "0xBFC0FF3C"
    elif (re.match("PIC32MZ.[0-9]*W", Variables.get("__PROCESSOR"))):
        devCfgAddress = "0xBFC55E88"
    elif ("PIC32MX" in Variables.get("__PROCESSOR")):
        devCfgAddress = mx_devCfg_addr
    elif ("PIC32MK" in Variables.get("__PROCESSOR")):
        devCfgAddress = "0xBFC03F40"

    btlDevCfgAddress = bootloaderComponent.createStringSymbol("BTL_DEVCFG_ADDRESS", None)
    btlDevCfgAddress.setLabel("Device Configuration Address")
    btlDevCfgAddress.setHelp(btl_helpkeyword)
    btlDevCfgAddress.setDefaultValue(devCfgAddress)
    btlDevCfgAddress.setVisible(False)

    btlWdogEnable = bootloaderComponent.createBooleanSymbol("BTL_WDOG_ENABLE", None)
    btlWdogEnable.setLabel("Enable Watchdog Refresh If Enabled Through FUSE")
    btlWdogEnable.setHelp(btl_helpkeyword)
    btlWdogEnable.setDefaultValue(False)
    btlWdogEnable.setDependencies(setWDTEnable, ["BTL_WDOG_ENABLE"])

def generateCommonFiles(bootloaderComponent):
    configName = Variables.get("__CONFIGURATION_NAME")

    btlCommonSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_COMMON_SOURCE", None)
    btlCommonSourceFile.setSourcePath("../bootloader/templates/src/bootloader_common.c.ftl")
    btlCommonSourceFile.setOutputName("bootloader_common.c")
    btlCommonSourceFile.setMarkup(True)
    btlCommonSourceFile.setOverwrite(True)
    btlCommonSourceFile.setDestPath("/bootloader/")
    btlCommonSourceFile.setProjectPath("config/" + configName + "/bootloader/")
    btlCommonSourceFile.setType("SOURCE")

    btlCommonHeaderFile = bootloaderComponent.createFileSymbol("BOOTLOADER_COMMON_HEADER", None)
    btlCommonHeaderFile.setSourcePath("../bootloader/templates/src/bootloader_common.h.ftl")
    btlCommonHeaderFile.setOutputName("bootloader_common.h")
    btlCommonHeaderFile.setMarkup(True)
    btlCommonHeaderFile.setOverwrite(True)
    btlCommonHeaderFile.setDestPath("/bootloader/")
    btlCommonHeaderFile.setProjectPath("config/" + configName + "/bootloader/")
    btlCommonHeaderFile.setType("HEADER")

def generateHwCRCGeneratorSymbol(bootloaderComponent):
    return

def generateLinkerFileSymbol(bootloaderComponent):
    # Disable Default linker script generation
    Database.setSymbolValue("core", "ADD_LINKER_FILE", False)

    # DS60001168 --> PIC32MX1XX/2XX
    # DS60001185 --> PIC32MX330/350/370/430/450/470
    # DS60001290 --> PIC32MX1XX/2XX/5XX
    # DS60001404 --> PIC32MX1XX/2XX XLP
    # DS60001156 --> PIC32MX5XX/6XX/7XX

    # DS60001402 -> PIC32MKXXXXGPD/GPE/MCF
    # DS60001570 -> PIC32MKXXXXGPG/MCJ
    # DS60001519 -> PIC32MKXXXXGPK/MCM
    # DS60001690 -> PIC32MKXXXXMCA

    # Get the (Datasheet Number) for the current Device Family
    deviceFamily = Database.getSymbolValue("core", "DEVICE_FAMILY")

    # Generate Bootloader Linker Script
    btlLinkerPath = "../bootloader/templates/mips/linkers/"

    btlLinkerFile = bootloaderComponent.createFileSymbol("BOOTLOADER_LINKER_FILE", None)

    if (re.match("PIC32MZ.[0-9]*EF", Variables.get("__PROCESSOR"))):
        btlLinkerFile.setSourcePath(btlLinkerPath + "bootloader_linker_mz_ef.ld.ftl")
    elif (re.match("PIC32MZ.[0-9]*DA", Variables.get("__PROCESSOR"))):
        btlLinkerFile.setSourcePath(btlLinkerPath + "bootloader_linker_mz_da.ld.ftl")
    elif (re.match("PIC32MZ.[0-9]*W", Variables.get("__PROCESSOR"))):
        btlLinkerFile.setSourcePath(btlLinkerPath + "bootloader_linker_mz_w1.ld.ftl")
    elif ("PIC32MX" in Variables.get("__PROCESSOR")):
        btlLinkerFile.setSourcePath(btlLinkerPath + "bootloader_linker_mx_" + deviceFamily + ".ld.ftl")
    elif ("PIC32MK" in Variables.get("__PROCESSOR")):
        btlLinkerFile.setSourcePath(btlLinkerPath + "bootloader_linker_mk_" + deviceFamily + ".ld.ftl")

    btlLinkerFile.setOutputName("btl.ld")
    btlLinkerFile.setMarkup(True)
    btlLinkerFile.setOverwrite(True)
    btlLinkerFile.setType("LINKER")

def generateXC32SettingsAndFileSymbol(bootloaderComponent):
    return

def setOptimizationLevel(bootloaderComponent, optimizationLevel):
    # Set Optimization level based on input
    xc32Optimization = bootloaderComponent.createSettingSymbol("XC32_OPTIMIZATION", None)
    xc32Optimization.setCategory("C32")
    xc32Optimization.setKey("optimization-level")
    xc32Optimization.setValue(optimizationLevel)
