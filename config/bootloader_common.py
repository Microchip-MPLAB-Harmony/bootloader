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

global bootloaderTypes
global getBootloaderType
global flashNames
global calcBootloaderSize
global createCommonSymbols
global setCustomAppStartAddress
global btlCustomAppStartAddress
global setAddrEnableVisible
global setCommentVisible

global ram_start
global ram_size

global flash_start
global flash_size
global flash_erase_size

flash_start         = 0
flash_size          = 0
flash_erase_size    = 256

flashNames          = ["EFC", "NVMCTRL"]

bootloaderTypes     =  ["", "UART"]
btlTypeUsed         = None

flashNode           = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space")
flashNode_children  = flashNode.getChildren()

for mem_idx in range(0, len(flashNode_children)):
    mem_seg     = flashNode_children[mem_idx].getAttribute("name")
    mem_type    = flashNode_children[mem_idx].getAttribute("type")

    if ("FLASH" in mem_seg and mem_type == "flash"):
        flash_start = int(flashNode_children[mem_idx].getAttribute("start"), 16)
        flash_size  = int(flashNode_children[mem_idx].getAttribute("size"), 16)

periphNode          = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
modules             = periphNode.getChildren()

periphName          = ""
periphFound         = False

for module in range (0, len(modules)):
    periphName = str(modules[module].getAttribute("name"))

    for i in range(0, len(flashNames)):
        if (periphName == flashNames[i]):
            periphFound = True
            break
    if (periphFound == True):
        break

#Parse ATDF for Flash parameters if it is not EFC
if (periphName != flashNames[0]):
    flashParamNode  = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals/module@[name=\"" + periphName + "\"]/instance@[name=\"" + periphName + "\"]/parameters")

    param_values    = flashParamNode.getChildren()

    for index in range(0, len(param_values)):
        if "ROW_SIZE" in param_values[index].getAttribute("name"):
            flash_erase_size = int(param_values[index].getAttribute("value"), 16)
else:
    flash_erase_size = 8192


addr_space          = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space")
addr_space_children = addr_space.getChildren()

for mem_idx in range(0, len(addr_space_children)):
    mem_seg         = addr_space_children[mem_idx].getAttribute("name")
    mem_type        = addr_space_children[mem_idx].getAttribute("type")

    if ("RAM" in mem_seg and mem_type == "ram"):
        ram_start   = addr_space_children[mem_idx].getAttribute("start")
        ram_size    = addr_space_children[mem_idx].getAttribute("size")

def calcBootloaderSize(btl_type, min_flash_erase_size):
    # Calculated values with highest Optimization level -Os
    max_uart_btl_size   = 1536
    max_i2c_btl_size    = 2048
    btl_size            = 0

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

def getBootloaderType():
    global btlTypeUsed

    return btlTypeUsed.getValue()

def setCustomAppStartAddress(symbol, event):
    global flash_start
    global flash_size
    global flash_erase_size

    if (event["id"] == "BTL_CUSTOM_APP_START_ADDR_ENABLE"):
        symbol.setVisible(event["value"])
    elif (event["id"] == "BTL_TYPE"):
        btl_size = calcBootloaderSize(event["value"], flash_erase_size)

        custom_app_start_addr = str(hex(flash_start + btl_size))

        symbol.setValue(custom_app_start_addr[2:])

def setAddrEnableVisible(symbol, event):
    if (event["value"] != ""):
        symbol.setVisible(True)
    elif (event["value"] == ""):
        symbol.setVisible(False)

def setCommentVisible(symbol, event):
    global flash_start
    global flash_size
    global flash_erase_size
    global btlCustomAppStartAddress
    global btlCustomAppAddressEnable

    comment_enable      = False
    custom_addr_enable  = btlCustomAppAddressEnable.getValue()

    custom_app_start_addr = int(btlCustomAppStartAddress.getValue(), 16)
    btl_size = calcBootloaderSize(getBootloaderType(), flash_erase_size)

    if (custom_app_start_addr < (flash_start + btl_size)):
        symbol.setLabel("***  WARNING!!! Application Start Address Should be equal to or Greater than Bootloader Size ***")
        comment_enable = True
    elif (custom_app_start_addr >= (flash_start + flash_size)):
        symbol.setLabel("*** WARNING!!! Application Start Address is exceeding the Flash Memory Space ***")
        comment_enable = True

    if (custom_addr_enable == True and comment_enable == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def createCommonSymbols(component):
    global btlTypeUsed
    global setCustomAppStartAddress
    global btlCustomAppAddressEnable
    global btlCustomAppStartAddress
    global setAddrEnableVisible
    global setCommentVisible

    global ram_start
    global ram_size

    global flash_start
    global flash_size
    global flash_erase_size

    btlTypeUsed = component.createComboSymbol("BTL_TYPE", None, bootloaderTypes)
    btlTypeUsed.setLabel("Bootloader Type")
    btlTypeUsed.setDefaultValue("")

    btlRamStart = component.createStringSymbol("BTL_RAM_START", None)
    btlRamStart.setDefaultValue(ram_start)
    btlRamStart.setReadOnly(True)
    btlRamStart.setVisible(False)

    btlRamSize = component.createStringSymbol("BTL_RAM_SIZE", None)
    btlRamSize.setDefaultValue(ram_size)
    btlRamSize.setReadOnly(True)
    btlRamSize.setVisible(False)

    btlCustomAppAddressEnable = component.createBooleanSymbol("BTL_CUSTOM_APP_START_ADDR_ENABLE", None)
    btlCustomAppAddressEnable.setLabel("Use Custom Application Start Address?")
    btlCustomAppAddressEnable.setDefaultValue(False)
    btlCustomAppAddressEnable.setVisible((btlTypeUsed.getValue() != ""))
    btlCustomAppAddressEnable.setDependencies(setAddrEnableVisible, ["BTL_TYPE"])

    btl_size = calcBootloaderSize(getBootloaderType(), flash_erase_size)

    custom_app_start_addr = str(hex(flash_start + btl_size))

    btlCustomAppStartAddress = component.createStringSymbol("BTL_CUSTOM_APP_START_ADDR", btlCustomAppAddressEnable)
    btlCustomAppStartAddress.setLabel("Application Start Address")
    btlCustomAppStartAddress.setDefaultValue(custom_app_start_addr[2:])
    btlCustomAppStartAddress.setVisible(btlCustomAppAddressEnable.getValue())
    btlCustomAppStartAddress.setDependencies(setCustomAppStartAddress, ["BTL_CUSTOM_APP_START_ADDR_ENABLE", "BTL_TYPE"])

    btlCustomAppAddrComment = component.createCommentSymbol("BTL_CUSTOM_APP_START_ADDR_COMMENT", btlCustomAppAddressEnable)
    btlCustomAppAddrComment.setVisible(False)
    btlCustomAppAddrComment.setDependencies(setCommentVisible, ["BTL_CUSTOM_APP_START_ADDR", "BTL_CUSTOM_APP_START_ADDR_ENABLE"])
