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

def getFlashParams(btl_type):
    global ram_start
    global ram_size
    global flash_start
    global flash_size

    if (btl_type == ""):
        return ""

    app_start   = btlCustomAppStartAddress.getValue()
    app_offset  = (int(app_start,16) - flash_start)
    app_len     = str(hex(flash_size - app_offset))

    rom_origin  = "ROM_ORIGIN=0x" + app_start
    rom_length  = "ROM_LENGTH=" + app_len

    ram_begin   = str(hex(int(ram_start, 16) + 16))
    ram_len     = str(hex(int(ram_size, 16) - 16))

    ram_origin  = "RAM_ORIGIN=" + ram_begin
    ram_length  = "RAM_LENGTH=" + ram_len

    return (rom_origin + ";" + rom_length + ";" + ram_origin + ";" + ram_length)

def setFlashParams(symbol, event):
    flashParams = getFlashParams(event["value"])

    symbol.setValue(flashParams)

def deactivateBootloader():
    activeComponents = Database.getActiveComponentIDs()

    for i in range(0, len(activeComponents)):
        if (activeComponents[i] == "bootloader"):
            res = Database.deactivateComponents(["bootloader"])

def instantiateComponent(bootloadableComponent):
    global getBootloaderType

    deactivateBootloader()

    configName = Variables.get("__CONFIGURATION_NAME")

    execfile(Variables.get("__MODULE_ROOT") + "/config/bootloader_common.py")

    createCommonSymbols(bootloadableComponent)

    flashParams = getFlashParams(getBootloaderType())

    coreComponent = Database.getComponentByID("core")

    # Disable Fuse Setting generation for Bootloadable Application
    coreComponent.getSymbolByID("DEVICE_CONFIG_SYSTEM_INIT").setEnabled(False)

    # set XC32-LD option to Modify ROM Start address and length
    xc32PreprocessroMacroSym = bootloadableComponent.createSettingSymbol("XC32_LINKER_PREPROC_MARCOS", None)
    xc32PreprocessroMacroSym.setCategory("C32-LD")
    xc32PreprocessroMacroSym.setKey("preprocessor-macros")
    xc32PreprocessroMacroSym.setValue(flashParams)
    xc32PreprocessroMacroSym.setDependencies(setFlashParams, ["BTL_TYPE", "BTL_CUSTOM_APP_START_ADDR"])

def destroyComponent(bootloadableComponent):
    coreComponent = Database.getComponentByID("core")

    # Disable Fuse Setting generation for Bootloadable Application
    coreComponent.getSymbolByID("DEVICE_CONFIG_SYSTEM_INIT").setEnabled(True)
