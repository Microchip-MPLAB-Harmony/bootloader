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
global flashNames

global ram_start
global ram_size

global flash_start
global flash_size
global flash_erase_size

global btl_start

global btlMemUsedStartAddr
global btlMemUsedSize

flash_start         = 0
flash_size          = 0
flash_erase_size    = 0

btl_start           = "0x0"

NvmMemoryNames      = ["NVM", "NVMCTRL", "EFC", "HEFC"]
FlashNames          = ["FLASH", "IFLASH"]
RamNames            = ["HSRAM", "HRAMC0", "HMCRAMC0", "IRAM", "FlexRAM", "DRAM"]

addr_space          = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space")
addr_space_children = addr_space.getChildren()

periphNode          = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
peripherals         = periphNode.getChildren()

for mem_idx in range(0, len(addr_space_children)):
    mem_seg     = addr_space_children[mem_idx].getAttribute("name")
    mem_type    = addr_space_children[mem_idx].getAttribute("type")

    if ((any(x == mem_seg for x in FlashNames) == True) and (mem_type == "flash")):
        flash_start = int(addr_space_children[mem_idx].getAttribute("start"), 16)
        flash_size  = int(addr_space_children[mem_idx].getAttribute("size"), 16)

    if ((any(x == mem_seg for x in RamNames) == True) and (mem_type == "ram")):
        ram_start   = addr_space_children[mem_idx].getAttribute("start")
        ram_size    = addr_space_children[mem_idx].getAttribute("size")

    btl_start = str(hex(flash_start))

def activateAndConnectDependencies(component):
    nvmMemoryName = ""

    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))

        if ((any(x == periphName for x in NvmMemoryNames) == True)):
            nvmMemoryName = periphName.lower()
            break

    nvmMemoryCapabilityId = nvmMemoryName.upper() + "_MEMORY"

    btlActivateTable = [nvmMemoryName]
    btlConnectTable  = [
        [component, "btl_MEMORY_dependency", nvmMemoryName, nvmMemoryCapabilityId]
    ]

    res = Database.activateComponents(btlActivateTable)
    res = Database.connectDependencies(btlConnectTable)

def calcBootloaderSize():
    global flash_erase_size

    coreArch     = Database.getSymbolValue("core", "CoreArchitecture")

    # Get the Maximum bootloader size value defined in bootloader protocol python file
    max_btl_size = getMaxBootloaderSize(coreArch)

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
    global flash_erase_size
    global btlMemUsedStartAddr

    memUsed_addr = btlMemUsedStartAddr.getValue()

    if (event["id"] == "BTL_SIZE"):
        btlSize = int(event["value"],10)

        if ( (memUsed_addr != 0) and (memUsed_addr != flash_start) ):
            custom_app_start_addr = str(hex(memUsed_addr))
        else:
            if ((btlSize != 0) and (flash_erase_size != 0)):
                appStartAligned = btlSize

                # If the bootloader size is not aligned to Erase Block Size
                if ((btlSize % flash_erase_size) != 0):
                    appStartAligned = btlSize + (flash_erase_size - (btlSize % flash_erase_size))

                custom_app_start_addr = str(hex(flash_start + appStartAligned))
            else:
                custom_app_start_addr = str(hex(flash_start))

        Database.setSymbolValue("core", "APP_START_ADDRESS", custom_app_start_addr[2:])
    elif (event["id"] == "BTL_MEM_START_ADDR"):
        if ( (memUsed_addr != 0) and (memUsed_addr != flash_start) ):
            custom_app_start_addr = str(hex(memUsed_addr))

            Database.setSymbolValue("core", "APP_START_ADDRESS", custom_app_start_addr[2:])
    else:
        comment_enable      = True

        custom_app_start_addr = int(Database.getSymbolValue("core", "APP_START_ADDRESS"), 16)
        btl_size = calcBootloaderSize()

        if ( (memUsed_addr != 0) and (memUsed_addr != flash_start) ):
            btl_mem_addr = memUsed_addr
            btl_mem_size = btlMemUsedSize
        else:
            btl_mem_addr = flash_start
            btl_mem_size = flash_size

        if ( (btl_mem_addr == btl_start) and (custom_app_start_addr < (btl_mem_addr + btl_size)) ):
            symbol.setLabel("WARNING!!! Application Start Address Should be equal to or Greater than Bootloader Size !!!")
        elif (custom_app_start_addr >= (btl_mem_addr + btl_mem_size)):
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
        if (Database.getSymbolValue(event["value"].lower(), "FLASH_USERROW_START_ADDRESS") != None):
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
    global btlMemUsedStartAddr

    btlMemUsed = bootloaderComponent.createStringSymbol("MEM_USED", None)
    btlMemUsed.setHelp(btl_helpkeyword)
    btlMemUsed.setLabel("Bootloader NVM Memory Used")
    btlMemUsed.setReadOnly(True)
    btlMemUsed.setDefaultValue("")

    btlMemUsedStartAddr = bootloaderComponent.createIntegerSymbol("BTL_MEM_START_ADDR", None)
    btlMemUsedStartAddr.setLabel("Bootloader Memory Used start address")
    btlMemUsedStartAddr.setVisible(False)
    btlMemUsedStartAddr.setDefaultValue(0)

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
    btlAppAddrComment.setDependencies(setAppStartAndCommentVisible, ["core.APP_START_ADDRESS", "BTL_SIZE", "BTL_MEM_START_ADDR"])

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

def generateFuseProgrammingAndWDTSymbols(bootloaderComponent):
    btlFuseProgramEnable = bootloaderComponent.createBooleanSymbol("BTL_FUSE_PROGRAM_ENABLE", None)
    btlFuseProgramEnable.setLabel("Enable Fuse Programming")
    btlFuseProgramEnable.setHelp(btl_helpkeyword)
    btlFuseProgramEnable.setDefaultValue(False)
    btlFuseProgramEnable.setVisible(False)
    btlFuseProgramEnable.setDependencies(setFuseProgram, ["MEM_USED"])

    btlWdogEnable = bootloaderComponent.createBooleanSymbol("BTL_WDOG_ENABLE", None)
    btlWdogEnable.setLabel("Enable Watchdog Refresh If Enabled Through FUSE")
    btlWdogEnable.setHelp(btl_helpkeyword)
    btlWdogEnable.setDefaultValue(False)
    btlWdogEnable.setDependencies(setWDTEnable, ["BTL_WDOG_ENABLE"])

def generateHwCRCGeneratorSymbol(bootloaderComponent):
    global btl_helpkeyword
    crcEnable = False

    coreComponent = Database.getComponentByID("core")

    # Enable PAC and DSU component if present
    for module in range (0, len(peripherals)):
        if Variables.get("__TRUSTZONE_ENABLED") != None and Variables.get("__TRUSTZONE_ENABLED") == "true":
            crcEnable=False
            break

        periphName = str(peripherals[module].getAttribute("name"))
        if (periphName == "PAC"):
            coreComponent.getSymbolByID("PAC_USE").setValue(True)
            if (Database.getSymbolValue("core", "PAC_INTERRRUPT_MODE") != None):
                coreComponent.getSymbolByID("PAC_INTERRRUPT_MODE").setValue(False)
        elif (periphName == "DSU"):
            res = Database.activateComponents(["dsu"])
            crcEnable = True

    btlHwCrc = bootloaderComponent.createBooleanSymbol("BTL_HW_CRC_GEN", None)
    btlHwCrc.setHelp(btl_helpkeyword)
    btlHwCrc.setLabel("Bootloader Hardware CRC Generator")
    btlHwCrc.setReadOnly(True)
    btlHwCrc.setVisible(False)
    btlHwCrc.setDefaultValue(crcEnable)

def generateLinkerFileSymbol(bootloaderComponent):
    # Disable Default linker script generation
    Database.setSymbolValue("core", "ADD_LINKER_FILE", False)

    # Generate Bootloader Linker Script
    btlLinkerPath = "../bootloader/templates/arm/bootloader_linker_optimized.ld.ftl"

    # Generate Bootloader Linker Script
    btlLinkerFile = bootloaderComponent.createFileSymbol("BOOTLOADER_LINKER_FILE", None)
    btlLinkerFile.setSourcePath(btlLinkerPath)
    btlLinkerFile.setOutputName("btl.ld")
    btlLinkerFile.setMarkup(True)
    btlLinkerFile.setOverwrite(True)
    btlLinkerFile.setType("LINKER")

    if Variables.get("__TRUSTZONE_ENABLED") != None and Variables.get("__TRUSTZONE_ENABLED") == "true":
        btlLinkerFile.setSourcePath("../bootloader/templates/arm/bootloader_linker_optimized_secure.ld.ftl")
        btlLinkerFile.setSecurity("SECURE")

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

    if Variables.get("__TRUSTZONE_ENABLED") != None and Variables.get("__TRUSTZONE_ENABLED") == "true":
        btlCommonSourceFile.setSecurity("SECURE")
        btlCommonHeaderFile.setSecurity("SECURE")

# Used by Optimized Bootloaders
def generateXC32SettingsAndFileSymbol(bootloaderComponent):
    configName = Variables.get("__CONFIGURATION_NAME")

    # generate startup_xc32.c file
    btlStartSourceFile = bootloaderComponent.createFileSymbol("STARTUP_BOOTLOADER_C", None)
    btlStartSourceFile.setSourcePath("../bootloader/templates/arm/startup_xc32_optimized.c.ftl")
    btlStartSourceFile.setOutputName("startup_xc32.c")
    btlStartSourceFile.setMarkup(True)
    btlStartSourceFile.setOverwrite(True)
    btlStartSourceFile.setDestPath("")
    btlStartSourceFile.setProjectPath("config/" + configName + "/")
    btlStartSourceFile.setType("SOURCE")

    # set XC32 option to not use the CRT0 startup code
    xc32NoCRT0StartupCodeSym = bootloaderComponent.createSettingSymbol("XC32_NO_CRT0_STARTUP_CODE", None)
    xc32NoCRT0StartupCodeSym.setCategory("C32-LD")
    xc32NoCRT0StartupCodeSym.setKey("no-startup-files")
    xc32NoCRT0StartupCodeSym.setValue("true")

    # Clear Placing data into its own section
    xc32ClearDataSection = bootloaderComponent.createSettingSymbol("XC32_CLEAR_DATA_SECTION", None)
    xc32ClearDataSection.setCategory("C32")
    xc32ClearDataSection.setKey("place-data-into-section")
    xc32ClearDataSection.setValue("false")

    if Variables.get("__TRUSTZONE_ENABLED") != None and Variables.get("__TRUSTZONE_ENABLED") == "true":
        btlStartSourceFile.setSecurity("SECURE")
        xc32NoCRT0StartupCodeSym.setSecurity("SECURE")
        xc32ClearDataSection.setSecurity("SECURE")

def setOptimizationLevel(bootloaderComponent, optimizationLevel):
    # Set Optimization level based on input
    xc32Optimization = bootloaderComponent.createSettingSymbol("XC32_OPTIMIZATION", None)
    xc32Optimization.setCategory("C32")
    xc32Optimization.setKey("optimization-level")
    xc32Optimization.setValue(optimizationLevel)

    if Variables.get("__TRUSTZONE_ENABLED") != None and Variables.get("__TRUSTZONE_ENABLED") == "true":
        xc32Optimization.setSecurity("SECURE")

