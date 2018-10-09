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

min_flash_erase_size = 0

periphNode  = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
peripherals = periphNode.getChildren()

def sort_alphanumeric(list):
    import re
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(list, key = alphanum_key)

def getAvaliablePins(bootloaderComponent):
    availablePinsDictonary = {}
    availablePins = []

    availablePinsDictonary = Database.sendMessage("core", "PIN_LIST", availablePinsDictonary)
    availablePins = sort_alphanumeric(availablePinsDictonary.values())

    btlReqPin = bootloaderComponent.createComboSymbol("BTL_REQ_PIN", None, availablePins)
    btlReqPin.setLabel("Bootloader Request Pin")

    btlReqPinComment = bootloaderComponent.createCommentSymbol("BTL_REQ_PIN_COMMENT", None)
    btlReqPinComment.setLabel("!!! Configure selected pin to GPIO Input in pin settings for external trigger !!!")

def setDependency(symbol, event):
    component = symbol.getComponent()

    if (event["value"] == "UART"):
        component.setDependencyEnabled("btl_UART_dependency", True)
        component.setDependencyEnabled("btl_I2C_dependency", False)
    elif (event["value"] == "I2C"):
        component.setDependencyEnabled("btl_I2C_dependency", True)
        component.setDependencyEnabled("btl_UART_dependency", False)
    elif (event["value"] == ""):
        component.setDependencyEnabled("btl_I2C_dependency", True)
        component.setDependencyEnabled("btl_UART_dependency", True)
        
def setBootloaderSize(symbol, event):
    global calcBootloaderSize
    global min_flash_erase_size

    component = symbol.getComponent()

    btl_type = component.getSymbolByID("BTL_TYPE").getValue()

    btl_size = str(calcBootloaderSize(btl_type, min_flash_erase_size))

    symbol.setValue(btl_size, 1)

def hasHwCRCGenerator():
    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))
        if (periphName == "DSU"):
            res = Database.activateComponents(["dsu"])
            return True

    return False

def deactivateBootloadable():
    activeComponents = Database.getActiveComponentIDs()

    for i in range(0, len(activeComponents)):
        if (activeComponents[i] == "bootloadable"):
            res = Database.deactivateComponents(["bootloadable"])

def setupCoreComponentSymbols():

    coreComponent = Database.getComponentByID("core")

    # Disable core related file generation not required for bootloader
    coreComponent.getSymbolByID("CoreMainFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysInitFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysStartupFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysCallsFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysIntFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysExceptionFile").setValue(False)

    coreComponent.getSymbolByID("CoreSysStdioSyscallsFile").setValue(False)

    # Enable Systick.
    coreComponent.getSymbolByID("systickEnable").setValue(True)

    # Configure systick period to 100 ms
    coreComponent.getSymbolByID("SYSTICK_PERIOD_MS").setValue(100)

    # Enable PAC component if present
    for module in range (0, len(peripherals)):
        periphName = str(peripherals[module].getAttribute("name"))
        if (periphName == "PAC"):
            coreComponent.getSymbolByID("PAC_USE").setValue(True)
            if (Database.getSymbolValue("core", "PAC_INTERRRUPT_MODE") != None):
                coreComponent.getSymbolByID("PAC_INTERRRUPT_MODE").setValue(False)

def instantiateComponent(bootloaderComponent):
    global getBootloaderType
    global calcBootloaderSize
    global createCommonSymbols
    global min_flash_erase_size

    deactivateBootloadable()

    configName = Variables.get("__CONFIGURATION_NAME")

    execfile(Variables.get("__MODULE_ROOT") + "/config/bootloader_common.py")

    setupCoreComponentSymbols()

    createCommonSymbols(bootloaderComponent)

    getAvaliablePins(bootloaderComponent)

    btlRequestLen = bootloaderComponent.createStringSymbol("BTL_REQUEST_LEN", None)
    btlRequestLen.setReadOnly(True)
    btlRequestLen.setVisible(False)
    btlRequestLen.setDefaultValue("16")

    periphUsed = bootloaderComponent.createStringSymbol("PERIPH_USED", None)
    periphUsed.setLabel("Bootloader Peripheral Used")
    periphUsed.setReadOnly(True)
    periphUsed.setDefaultValue("")
    periphUsed.setDependencies(setDependency, ["BTL_TYPE"])

    memUsed = bootloaderComponent.createStringSymbol("MEM_USED", None)
    memUsed.setLabel("Bootloader Memory Used")
    memUsed.setReadOnly(True)
    memUsed.setDefaultValue("")

    btl_size = str(calcBootloaderSize(getBootloaderType(), min_flash_erase_size))

    btlSize = bootloaderComponent.createStringSymbol("BTL_SIZE", None)
    btlSize.setLabel("Bootloader Size")
    btlSize.setReadOnly(True)
    btlSize.setDefaultValue(btl_size)
    btlSize.setDependencies(setBootloaderSize, ["BTL_TYPE", "MEM_USED"])

    btlHwCrc = bootloaderComponent.createBooleanSymbol("BTL_HW_CRC_GEN", None)
    btlHwCrc.setLabel("Bootloader Hardware CRC Generator")
    btlHwCrc.setReadOnly(True)
    btlHwCrc.setVisible(False)
    btlHwCrc.setDefaultValue(hasHwCRCGenerator())

    #################### Code Generation ####################

    btlSourceFile = bootloaderComponent.createFileSymbol("BOOTLOADER_SRC", None)
    btlSourceFile.setOutputName("bootloader.c")
    btlSourceFile.setMarkup(True)
    btlSourceFile.setOverwrite(True)
    btlSourceFile.setDestPath("/bootloader/")
    btlSourceFile.setProjectPath("config/" + configName + "/bootloader/")
    btlSourceFile.setType("SOURCE")
    btlSourceFile.setEnabled(False)

    btlHeaderFile = bootloaderComponent.createFileSymbol("BOOTLOADER_HEADER", None)
    btlHeaderFile.setSourcePath("../bootloader/bootloader.h")
    btlHeaderFile.setOutputName("bootloader.h")
    btlHeaderFile.setOverwrite(True)
    btlHeaderFile.setDestPath("/bootloader/")
    btlHeaderFile.setProjectPath("config/" + configName + "/bootloader/")
    btlHeaderFile.setType("HEADER")

    # generate main.c file
    btlmainSourceFile = bootloaderComponent.createFileSymbol("MAIN_BOOTLOADER_C", None)
    btlmainSourceFile.setSourcePath("../bootloader/templates/system/main.c.ftl")
    btlmainSourceFile.setOutputName("main.c")
    btlmainSourceFile.setMarkup(True)
    btlmainSourceFile.setOverwrite(False)
    btlmainSourceFile.setDestPath("../../")
    btlmainSourceFile.setProjectPath("")
    btlmainSourceFile.setType("SOURCE")

    # generate startup_xc32.c file
    btlStartSourceFile = bootloaderComponent.createFileSymbol("STARTUP_BOOTLOADER_C", None)
    btlStartSourceFile.setSourcePath("../bootloader/templates/system/startup_xc32.c.ftl")
    btlStartSourceFile.setOutputName("startup_xc32.c")
    btlStartSourceFile.setMarkup(True)
    btlStartSourceFile.setOverwrite(True)
    btlStartSourceFile.setDestPath("")
    btlStartSourceFile.setProjectPath("config/" + configName + "/")
    btlStartSourceFile.setType("SOURCE")

    #Bootloader Trigger
    btlInitFile = bootloaderComponent.createFileSymbol("INITIALIZATION_BOOTLOADER_C", None)
    btlInitFile.setSourcePath("../bootloader/templates/system/initialization.c.ftl")
    btlInitFile.setOutputName("initialization.c")
    btlInitFile.setMarkup(True)
    btlInitFile.setOverwrite(True)
    btlInitFile.setDestPath("")
    btlInitFile.setProjectPath("config/" + configName + "/")
    btlInitFile.setType("SOURCE")

    # Generate Bootloader Linker Script
    btlLinkerFile = bootloaderComponent.createFileSymbol("BOOTLOADER_LINKER_FILE", None)
    btlLinkerFile.setSourcePath("../bootloader/templates/bootloader_linker.ld.ftl")
    btlLinkerFile.setOutputName("btl.ld")
    btlLinkerFile.setMarkup(True)
    btlLinkerFile.setOverwrite(True)
    btlLinkerFile.setType("LINKER")
    btlLinkerFile.setEnabled(False)

    btlSystemDefFile = bootloaderComponent.createFileSymbol("BTL_SYS_DEF_HEADER", None)
    btlSystemDefFile.setType("STRING")
    btlSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    btlSystemDefFile.setSourcePath("../bootloader/templates/system/definitions.h.ftl")
    btlSystemDefFile.setMarkup(True)

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

    # Set Optimization to -Os
    xc32ClearDataSection = bootloaderComponent.createSettingSymbol("XC32_OPTIMIZATION", None)
    xc32ClearDataSection.setCategory("C32")
    xc32ClearDataSection.setKey("optimization-level")
    xc32ClearDataSection.setValue("-Os")

def onAttachmentConnected(source, target):
    global min_flash_erase_size

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if (connectID == "btl_UART_dependency"):
        periph_name = Database.getSymbolValue(remoteID, "USART_PLIB_API_PREFIX")

        localComponent.getSymbolByID("BTL_TYPE").setValue("UART")

        localComponent.getSymbolByID("PERIPH_USED").clearValue()
        localComponent.getSymbolByID("PERIPH_USED").setValue(periph_name)

        localComponent.getSymbolByID("BOOTLOADER_SRC").setSourcePath("../bootloader/templates/bootloader_uart.c.ftl")
        localComponent.getSymbolByID("BOOTLOADER_SRC").setEnabled(True)
        localComponent.getSymbolByID("BOOTLOADER_LINKER_FILE").setEnabled(True)

        localComponent.setDependencyEnabled("btl_I2C_dependency", False)

        Database.setSymbolValue(remoteID, "USART_INTERRUPT_MODE", False)

    if (connectID == "btl_I2C_dependency"):
        periph_name = Database.getSymbolValue(remoteID, "I2C_PLIB_API_PREFIX")

        localComponent.getSymbolByID("BTL_TYPE").setValue("I2C")

        localComponent.getSymbolByID("PERIPH_USED").clearValue()
        localComponent.getSymbolByID("PERIPH_USED").setValue(periph_name)

        localComponent.getSymbolByID("BOOTLOADER_SRC").setSourcePath("../bootloader/templates/bootloader_i2c.c.ftl")
        localComponent.getSymbolByID("BOOTLOADER_SRC").setEnabled(True)
        localComponent.getSymbolByID("BOOTLOADER_LINKER_FILE").setEnabled(True)

        localComponent.setDependencyEnabled("btl_UART_dependency", False)

    if (connectID == "btl_MEMORY_dependency"):
        min_flash_erase_size = int(Database.getSymbolValue(remoteID, "FLASH_ERASE_SIZE"))
        localComponent.getSymbolByID("MEM_USED").setValue(remoteID.upper())

        Database.setSymbolValue(remoteID, "INTERRUPT_ENABLE", False)

def onAttachmentDisconnected(source, target):
    global min_flash_erase_size

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]

    if (connectID == "btl_UART_dependency" or
        connectID == "btl_I2C_dependency"):
        localComponent.getSymbolByID("BTL_TYPE").setValue("")
        localComponent.getSymbolByID("PERIPH_USED").clearValue()
        localComponent.getSymbolByID("BOOTLOADER_SRC").setEnabled(False)
        localComponent.getSymbolByID("BOOTLOADER_LINKER_FILE").setEnabled(False)

    if (connectID == "btl_MEMORY_dependency"):
        min_flash_erase_size = 0
        localComponent.getSymbolByID("MEM_USED").clearValue()
