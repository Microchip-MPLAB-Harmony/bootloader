---
grand_parent: Appendix
parent: Tools Help
title: Binary to C Array script help
has_toc: false
nav_order: 2
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Binary to C Array script help

## Downloading the host script

To clone or download these host tools from Github,go to the [main page of this repository](https://github.com/Microchip-MPLAB-Harmony/bootloader) and then click Clone button to clone this repo or download as zip file. This content can also be download using content manager by following [these instructions](https://github.com/Microchip-MPLAB-Harmony/contentmanager/wiki)

### Path of the tool within the repository is **tools/btl_bin_to_c_array.py**

## Setting up the Host PC

- The Script is compatible with **Python 3.x** and higher

## Description

- This script should be used to convert the binary file to a C style array containing Hex output that can be directly included in target application code

- It is mainly used when programming the application using the **host_app_nvm application in I2C/CAN Bootloader**

- If size of the input binary file is not aligned to device erase boundary it appends 0xFF to the binary to make it aligned and then generates the Hex output

- User must specify the binary file to convert (-b), hex output file (-o) and the device (-d)

    <p align="center">
        <img src = "./images/btl_bin_to_c_array.png"/>
    </p>

## Usage Examples

### Below is the syntax to show help menu for the script

```
python <harmony3_path>/bootloader/tools/btl_bin_to_c_array.py --help
```

<p align="center">
    <img src = "./images/btl_bin_to_c_array_help_menu.png"/>
</p>

### Below is the syntax and an example on how to convert the binary file to a C style array containing Hex output
```
python <harmony3_path>/bootloader/tools/btl_bin_to_c_array.py -b <binary_file> -o <hex_file> -d <device>
```

```c
python <harmony3_path>/bootloader/tools/btl_bin_to_c_array.py -b <harmony3_path>/bootloader_apps_i2c/apps/i2c_bootloader/test_app/firmware/sam_d20_xpro.X/dist/sam_d20_xpro/production/sam_d20_xpro.X.production.bin -o <harmony3_path>/bootloader_apps_i2c/apps/i2c_bootloader/host_app_nvm/firmware/src/test_app_images/image_pattern_hex_sam_d20_xpro.h -d samd2x
```
