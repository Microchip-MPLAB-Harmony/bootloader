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

# The bootloader_live_update python will be called from Bootloader specific Pythons

# Call RTOS Settings python
execfile(Module.getPath() + "/config/bootloader_rtos.py")

def setBtlLiveUpdate(symbol, event):
    global flash_size
    global btl_start

    component = symbol.getComponent()

    # Get the current Product Family
    productFamily = Database.getSymbolValue("core", "PRODUCT_FAMILY")

    if (event["value"] == True):
        component.getSymbolByID("BTL_SIZE").setReadOnly(True)

        component.getSymbolByID("BTL_TRIGGER_ENABLE").setVisible(False)

        component.getSymbolByID("BTL_APP_START_ADDR_COMMENT").setVisible(False)

        if (("PIC32MZ" in Variables.get("__PROCESSOR")) or
            ("PIC32MK" in Variables.get("__PROCESSOR"))):
            component.getSymbolByID("BTL_START").setValue("0x9D000000")

            # Setup Linker File symbol
            component.getSymbolByID("BOOTLOADER_LINKER_FILE").setOutputName("live_update.ld")
            component.getSymbolByID("BOOTLOADER_LINKER_FILE").setSourcePath("../bootloader/templates/mips/linkers/bootloader_linker_" + productFamily + "_live_update.ld.ftl")

        # Disable Custom initialization function from bootloader
        component.getSymbolByID("INITIALIZATION_BOOTLOADER_C").setEnabled(False)

        # Enable Initialization function from Core
        coreComponent = Database.getComponentByID("core")
        coreComponent.getSymbolByID("CoreSysInitFile").setValue(True)

    else:
        component.getSymbolByID("BTL_SIZE").setReadOnly(False)

        component.getSymbolByID("BTL_TRIGGER_ENABLE").setVisible(True)

        if (("PIC32MZ" in Variables.get("__PROCESSOR")) or
            ("PIC32MK" in Variables.get("__PROCESSOR"))):
            component.getSymbolByID("BTL_START").setValue(btl_start)

            # Reset Linker File symbol
            component.getSymbolByID("BOOTLOADER_LINKER_FILE").setOutputName("btl.ld")
            component.getSymbolByID("BOOTLOADER_LINKER_FILE").setSourcePath("../bootloader/templates/mips/linkers/bootloader_linker_" + productFamily + ".ld.ftl")

        # Enable Custom initialization function from bootloader 
        component.getSymbolByID("INITIALIZATION_BOOTLOADER_C").setEnabled(True)

        # Disable Initialization function from Core
        coreComponent = Database.getComponentByID("core")
        coreComponent.getSymbolByID("CoreSysInitFile").setValue(False)

    symbol.setVisible(event["value"])

def setBtlLiveUpdateReset(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

        # Clear User setting
        symbol.setReadOnly(True)
        symbol.setReadOnly(False)

def setBtlLiveUpdateSize(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def setupLiveUpdateSymbols(bootloaderComponent):
    global flash_size
    global btl_helpkeyword

    configName = Variables.get("__CONFIGURATION_NAME")

    btlLiveUpdateEnable = False

    if (("SAME5" in Variables.get("__PROCESSOR")) or ("SAMD5" in Variables.get("__PROCESSOR"))):
        btlLiveUpdateEnable = True
    elif ("PIC32MZ" in Variables.get("__PROCESSOR")):
        if (re.match("PIC32MZ.[0-9]*EF", Variables.get("__PROCESSOR")) or
            re.match("PIC32MZ.[0-9]*DA", Variables.get("__PROCESSOR"))):
            btlLiveUpdateEnable = True
    elif ("PIC32MK" in Variables.get("__PROCESSOR")):
        if (re.match("PIC32MK.[0-9]*GPG", Variables.get("__PROCESSOR")) or
            re.match("PIC32MK.[0-9]*MCJ", Variables.get("__PROCESSOR"))):
            btlLiveUpdateEnable = False
        else:
            btlLiveUpdateEnable = True

    btlLiveUpdate = bootloaderComponent.createBooleanSymbol("BTL_LIVE_UPDATE", None)
    btlLiveUpdate.setHelp(btl_helpkeyword)
    btlLiveUpdate.setLabel("Use Dual Bank For Live Update")
    btlLiveUpdate.setVisible(btlLiveUpdateEnable)

    length = str((flash_size / 2))

    btlLiveUpdateSize = bootloaderComponent.createStringSymbol("BTL_LIVE_UPDATE_SIZE", btlLiveUpdate)
    btlLiveUpdateSize.setHelp(btl_helpkeyword)
    btlLiveUpdateSize.setLabel("Live Update Flash Bank Size (Bytes)")
    btlLiveUpdateSize.setVisible(btlLiveUpdate.getValue())
    btlLiveUpdateSize.setDefaultValue(length)
    btlLiveUpdateSize.setDependencies(setBtlLiveUpdateSize, ["BTL_LIVE_UPDATE"])

    btlLiveUpdateReset = bootloaderComponent.createBooleanSymbol("BTL_LIVE_UPDATE_RESET", btlLiveUpdate)
    btlLiveUpdateReset.setHelp(btl_helpkeyword)
    btlLiveUpdateReset.setLabel("Trigger Reset After Live Update")
    btlLiveUpdateReset.setVisible(btlLiveUpdate.getValue())
    btlLiveUpdateReset.setDependencies(setBtlLiveUpdateReset, ["BTL_LIVE_UPDATE"])

    btlLiveUpdateComment = bootloaderComponent.createCommentSymbol("BTL_LIVE_UPDATE_COMMENT", None)
    btlLiveUpdateComment.setLabel("!!! WARNING Only Half of the Flash memory will be available for Application !!!")
    btlLiveUpdateComment.setVisible(False)
    btlLiveUpdateComment.setDependencies(setBtlLiveUpdate, ["BTL_LIVE_UPDATE"])

    # Generate RTOS specific Symbols
    generateRTOSSymbols(bootloaderComponent, btlLiveUpdate.getValue())
