global min_flash_erase_size

btlTypes =  ["",
             "UART",
             "I2C"]

min_flash_erase_size = 0

# Calculated values with highest Optimization level -Os
max_uart_btl_size = int(Database.getSymbolValue("core", "BootloaderUartSizeMax"))
max_i2c_btl_size = int(Database.getSymbolValue("core", "BootloaderI2CSizeMax"))

def sort_alphanumeric(list):
    import re
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(list, key = alphanum_key)

def getAvaliablePins(btlComponent):
    availablePins = []
    children      = []

    val = ATDF.getNode("/avr-tools-device-file/pinouts/pinout")
    children = val.getChildren()

    for pad in range(0, len(children)):
        pin = children[pad].getAttribute("pad")
        if (pin[0] == "P") and (pin[-1].isdigit()):
            availablePins.append(pin)

    availablePins = sort_alphanumeric(availablePins)

    btlReqPin = btlComponent.createComboSymbol("BTL_REQ_PIN", None, availablePins)
    btlReqPin.setLabel("Bootloader Request Pin")

def getRamDetails(btlComponent):
    val = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space")
    children = val.getChildren()

    for mem_idx in range(0, len(children)):
        mem_seg = children[mem_idx].getAttribute("name")
        mem_type = children[mem_idx].getAttribute("type")

        if ("RAM" in mem_seg and mem_type == "ram"):
            ram_start = children[mem_idx].getAttribute("start")
            ram_size = children[mem_idx].getAttribute("size")

    btlRamStart = btlComponent.createStringSymbol("BTL_RAM_START", None)
    btlRamStart.setLabel("Ram Start")
    btlRamStart.setDefaultValue(ram_start)
    btlRamStart.setReadOnly(True)
    btlRamStart.setVisible(False)

    btlRamSize = btlComponent.createStringSymbol("BTL_RAM_SIZE", None)
    btlRamSize.setLabel("Ram Size")
    btlRamSize.setDefaultValue(ram_size)
    btlRamSize.setReadOnly(True)
    btlRamSize.setVisible(False)

def configureSystick():
    Database.setSymbolValue("core", "systickEnable", True, 1)

    #Set 100ms Delay
    Database.setSymbolValue("core", "SYSTICK_PERIOD_MS", float(100.0), 1)

def setDependency(symbol, event):
    component = symbol.getComponent()

    component.setDependencyEnabled("btl_I2C_dependency", False)
    component.setDependencyEnabled("btl_UART_dependency", False)

    if (event["value"] == "UART"):
        component.setDependencyEnabled("btl_UART_dependency", True)
    elif (event["value"] == "I2C"):
        component.setDependencyEnabled("btl_I2C_dependency", True)
    elif (event["value"] == ""):
        component.setDependencyEnabled("btl_I2C_dependency", True)
        component.setDependencyEnabled("btl_UART_dependency", True)
        
def calcBootloaderSize(btl_type):
    global min_flash_erase_size

    btl_size = 0

    if ((min_flash_erase_size != 0) and (btl_type != "")):
        if (btl_type == "UART"):
            if (min_flash_erase_size >= max_uart_btl_size):
                btl_size = min_flash_erase_size
            else:
                btl_size = max_uart_btl_size
        elif (btl_type == "I2C"):
            if (min_flash_erase_size >= max_i2c_btl_size):
                btl_size = min_flash_erase_size
            else:
                btl_size = max_i2c_btl_size

    return btl_size

def setBootloaderSize(symbol, event):
    component = symbol.getComponent()

    btl_type = component.getSymbolByID("BTL_TYPE").getValue()

    btl_size = str(calcBootloaderSize(btl_type))

    symbol.setValue(btl_size, 1)

def hasHwCRCGenerator():
    periphNode = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
    modules = periphNode.getChildren()

    for module in range (0, len(modules)):
        periphName = str(modules[module].getAttribute("name"))
        if (periphName == "DSU"):
            return True

    return False

def instantiateComponent(btlComponent):

    configName = Variables.get("__CONFIGURATION_NAME")

    Database.setSymbolValue("core", "BootloaderProject", True, 1)
    Database.setSymbolValue("core", "BootloaderEnable", True, 1)
    Database.setSymbolValue("core", "BootloaderAppEnable", False, 1)

    btlTypeUsed = btlComponent.createComboSymbol("BTL_TYPE", None, btlTypes)
    btlTypeUsed.setLabel("Bootloader Type")
    btlTypeUsed.setDefaultValue("")

    getAvaliablePins(btlComponent)

    getRamDetails(btlComponent)

#    configureSystick()

    btlRequestLen = btlComponent.createStringSymbol("BTL_REQUEST_LEN", None)
    btlRequestLen.setLabel("Bootloader Request Length")
    btlRequestLen.setReadOnly(True)
    btlRequestLen.setVisible(False)
    btlRequestLen.setDefaultValue("16")

    periphUsed = btlComponent.createStringSymbol("PERIPH_USED", None)
    periphUsed.setLabel("Bootloader Peripheral Used")
    periphUsed.setReadOnly(True)
    periphUsed.setDefaultValue("")
    periphUsed.setDependencies(setDependency, ["BTL_TYPE"])

    memUsed = btlComponent.createStringSymbol("MEM_USED", None)
    memUsed.setLabel("Bootloader Memory Used")
    memUsed.setReadOnly(True)
    memUsed.setDefaultValue("")

    btl_size = str(calcBootloaderSize(btlTypeUsed.getValue()))

    btlSize = btlComponent.createStringSymbol("BTL_SIZE", None)
    btlSize.setLabel("Bootloader SIZE")
    btlSize.setReadOnly(True)
    btlSize.setDefaultValue(btl_size)
    btlSize.setDependencies(setBootloaderSize, ["BTL_TYPE", "MEM_USED"])

    btlHwCrc = btlComponent.createBooleanSymbol("BTL_HW_CRC_GEN", None)
    btlHwCrc.setLabel("Bootloader Hardware CRC Generator")
    btlHwCrc.setReadOnly(True)
    btlHwCrc.setVisible(False)
    btlHwCrc.setDefaultValue(hasHwCRCGenerator())

    #################### Code Generation ####################

    btlSourceFile = btlComponent.createFileSymbol("BOOTLOADER_UART_SRC", None)
    btlSourceFile.setSourcePath("../bootloader/templates/bootloader_uart.c.ftl")
    btlSourceFile.setOutputName("bootloader.c")
    btlSourceFile.setMarkup(True)
    btlSourceFile.setOverwrite(True)
    btlSourceFile.setDestPath("/bootloader/")
    btlSourceFile.setProjectPath("config/" + configName + "/bootloader/")
    btlSourceFile.setType("SOURCE")
    btlSourceFile.setEnabled((btlTypeUsed.getValue() == "UART"))

    btlHeaderFile = btlComponent.createFileSymbol("BOOTLOADER_HEADER", None)
    btlHeaderFile.setSourcePath("../bootloader/bootloader.h")
    btlHeaderFile.setOutputName("bootloader.h")
    btlHeaderFile.setOverwrite(True)
    btlHeaderFile.setDestPath("/bootloader/")
    btlHeaderFile.setProjectPath("config/" + configName + "/bootloader/")
    btlHeaderFile.setType("HEADER")

    # generate startup_xc32.c file
    btlStartSourceFile = btlComponent.createFileSymbol("STARTUP_BOOTLOADER_C", None)
    btlStartSourceFile.setSourcePath("../bootloader/templates/startup_xc32.c.ftl")
    btlStartSourceFile.setOutputName("startup.c")
    btlStartSourceFile.setMarkup(True)
    btlStartSourceFile.setOverwrite(True)
    btlStartSourceFile.setDestPath("")
    btlStartSourceFile.setProjectPath("config/" + configName + "/")
    btlStartSourceFile.setType("SOURCE")

    # Generate Bootloader Linker Script
    btlLinkerFile = btlComponent.createFileSymbol("BOOTLOADER_LINKER_FILE", None)
    btlLinkerFile.setSourcePath("../bootloader/templates/bootloader_linker.ld.ftl")
    btlLinkerFile.setOutputName("btl.ld")
    btlLinkerFile.setMarkup(True)
    btlLinkerFile.setOverwrite(True)
    btlLinkerFile.setType("LINKER")
    btlLinkerFile.setEnabled((btlTypeUsed.getValue() != ""))

    #Bootloader Trigger
    qspiSystemInitFile = btlComponent.createFileSymbol("BOOTLOADER_TRIGGER_INIT", None)
    qspiSystemInitFile.setType("STRING")
    qspiSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_BOOTLOADER_TRIGGER")
    qspiSystemInitFile.setSourcePath("../bootloader/templates/system/system_initialize.c.ftl")
    qspiSystemInitFile.setMarkup(True)

    btlSystemDefFile = btlComponent.createFileSymbol("BTL_SYS_DEF_HEADER", None)
    btlSystemDefFile.setType("STRING")
    btlSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    btlSystemDefFile.setSourcePath("../bootloader/templates/system/system_definitions.h.ftl")
    btlSystemDefFile.setMarkup(True)

    # set XC32 option to not use the CRT0 startup code
    xc32NoCRT0StartupCodeSym = btlComponent.createSettingSymbol("XC32_NO_CRT0_STARTUP_CODE", None)
    xc32NoCRT0StartupCodeSym.setCategory("C32-LD")
    xc32NoCRT0StartupCodeSym.setKey("no-startup-files")
    xc32NoCRT0StartupCodeSym.setValue("true")

    # Clear Placing data into its own section
    xc32ClearDataSection = btlComponent.createSettingSymbol("XC32_CLEAR_DATA_SECTION", None)
    xc32ClearDataSection.setCategory("C32")
    xc32ClearDataSection.setKey("place-data-into-section")
    xc32ClearDataSection.setValue("false")

    # Set Optimization to -Os
    xc32ClearDataSection = btlComponent.createSettingSymbol("XC32_OPTIMIZATION", None)
    xc32ClearDataSection.setCategory("C32")
    xc32ClearDataSection.setKey("optimization-level")
    xc32ClearDataSection.setValue("-Os")

def onDependencyConnected(connectionInfo):
    global min_flash_erase_size

    localComponent = connectionInfo["localComponent"]

    remoteId = connectionInfo["remoteComponent"].getID()

    if (connectionInfo["dependencyID"] == "btl_UART_dependency"):
        localComponent.getSymbolByID("PERIPH_USED").clearValue()
        localComponent.getSymbolByID("PERIPH_USED").setValue(remoteId.upper(), 1)
        localComponent.getSymbolByID("BOOTLOADER_UART_SRC").setEnabled(True)
        localComponent.getSymbolByID("BOOTLOADER_LINKER_FILE").setEnabled(True)
        localComponent.setDependencyEnabled("btl_I2C_dependency", False)

        Database.setSymbolValue(remoteId, "INTERRUPT_MODE", False, 1)

    if (connectionInfo["dependencyID"] == "btl_I2C_dependency"):
        localComponent.getSymbolByID("PERIPH_USED").clearValue()
        localComponent.getSymbolByID("PERIPH_USED").setValue(remoteId.upper(), 1)
        localComponent.getSymbolByID("BOOTLOADER_UART_SRC").setEnabled(False)
        localComponent.getSymbolByID("BOOTLOADER_LINKER_FILE").setEnabled(True)
        localComponent.setDependencyEnabled("btl_UART_dependency", False)

    if (connectionInfo["dependencyID"] == "btl_MEMORY_dependency"):
        min_flash_erase_size = int(Database.getSymbolValue(remoteId, "FLASH_ERASE_SIZE"))
        localComponent.getSymbolByID("MEM_USED").setValue(remoteId.upper(), 1)

        Database.setSymbolValue(remoteId, "INTERRUPT_ENABLE", False, 1)

def onDependencyDisconnected(connectionInfo):
    global min_flash_erase_size

    localComponent = connectionInfo["localComponent"]

    if (connectionInfo["dependencyID"] == "btl_UART_dependency" or
        connectionInfo["dependencyID"] == "btl_I2C_dependency"):
        localComponent.getSymbolByID("PERIPH_USED").clearValue()
        localComponent.getSymbolByID("BOOTLOADER_UART_SRC").setEnabled(False)
        localComponent.getSymbolByID("BOOTLOADER_LINKER_FILE").setEnabled(False)

    if (connectionInfo["dependencyID"] == "btl_MEMORY_dependency"):
        min_flash_erase_size = 0
        localComponent.getSymbolByID("MEM_USED").clearValue()
