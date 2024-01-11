![Microchip logo](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_logo.png)
![Harmony logo small](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_mplab_harmony_logo_small.png)

# MPLAB® Harmony 3 Bootloader Module

MPLAB® Harmony 3 is an extension of the MPLAB® ecosystem for creating
embedded firmware solutions for Microchip 32-bit SAM and PIC® microcontroller
and microprocessor devices. Refer to the following links for more information.

- [Microchip 32-bit MCUs](https://www.microchip.com/design-centers/32-bit)
- [Microchip 32-bit MPUs](https://www.microchip.com/design-centers/32-bit-mpus)
- [Microchip MPLAB X IDE](https://www.microchip.com/mplab/mplab-x-ide)
- [Microchip MPLAB Harmony](https://www.microchip.com/mplab/mplab-harmony)
- [Microchip MPLAB Harmony Pages](https://microchip-mplab-harmony.github.io/)

This repository contains the MPLAB® Harmony 3 Bootloader. The bootloader module
components provide framework to develop bootloaders for Microchip 32-bit SAM and PIC® microcontroller
and microprocessor devices. Refer to the following links for release notes, training materials,
and interface reference information.

- [Release Notes](./release_notes.md)
- [MPLAB® Harmony License](mplab_harmony_license.md)
- [MPLAB® Harmony 3 Bootloader Wiki](https://github.com/Microchip-MPLAB-Harmony/bootloader/wiki)
- [MPLAB® Harmony 3 Bootloader API Help](https://microchip-mplab-harmony.github.io/bootloader)

# Contents Summary

| Folder    | Description                                                |
|-----------|------------------------------------------------------------|
| config    | Bootloader module configuration scripts                    |
| docs      | Bootloader module library HTML help documentation          |
| templates | Bootloader and system file templates                       |
| tools     | Bootloader Host scripts                                    |

# Introduction

The Bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger.

A Bootloader is a small application that starts the operation of the device. A Bootloader does not fully operate the device, but can perform various functions prior to starting the main application.

**Such functions can include:**
- Firmware upgrades
- Application integrity
- Starting the application

**Supported bootloaders:** UART, I2C, SPI, CAN, Serial Memory, File System, USB, Ethernet and OTA 

# Bootloader Application Repositories

| Repo name                                                                                                 | Description                     |
|-----------------------------------------------------------------------------------------------------------|---------------------------------|
| [bootloader_apps_uart](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_uart)                   | UART Bootloader Applications    |
| [bootloader_apps_i2c](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_i2c)                     | I2C Bootloader Applications     |
| [bootloader_apps_can](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_can)                     | CAN Bootloader Applications     |
| [bootloader_apps_usb](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_usb)                     | USB Bootloader Applications     |
| [bootloader_apps_ethernet](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_ethernet)           | Ethernet Bootloader Applications|
| [bootloader_apps_sdcard](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_sdcard)               | SDCARD Bootloader Applications  |
| [bootloader_apps_serial_memory](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_serial_memory) | Serial Memory Bootloader Applications  |
| [bootloader_apps_spi](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_spi)                     | SPI Bootloader Applications     |
| [bootloader_apps_ota](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_ota)                     | OTA Bootloader Applications     |

____

[![License](https://img.shields.io/badge/license-Harmony%20license-orange.svg)](https://github.com/Microchip-MPLAB-Harmony/bootloader/blob/master/mplab_harmony_license.md)
[![Latest release](https://img.shields.io/github/release/Microchip-MPLAB-Harmony/bootloader.svg)](https://github.com/Microchip-MPLAB-Harmony/bootloader/releases/latest)
[![Latest release date](https://img.shields.io/github/release-date/Microchip-MPLAB-Harmony/bootloader.svg)](https://github.com/Microchip-MPLAB-Harmony/bootloader/releases/latest)
[![Commit activity](https://img.shields.io/github/commit-activity/y/Microchip-MPLAB-Harmony/bootloader.svg)](https://github.com/Microchip-MPLAB-Harmony/bootloader/graphs/commit-activity)
[![Contributors](https://img.shields.io/github/contributors-anon/Microchip-MPLAB-Harmony/bootloader.svg)]()

____

[![Follow us on Youtube](https://img.shields.io/badge/Youtube-Follow%20us%20on%20Youtube-red.svg)](https://www.youtube.com/user/MicrochipTechnology)
[![Follow us on LinkedIn](https://img.shields.io/badge/LinkedIn-Follow%20us%20on%20LinkedIn-blue.svg)](https://www.linkedin.com/company/microchip-technology)
[![Follow us on Facebook](https://img.shields.io/badge/Facebook-Follow%20us%20on%20Facebook-blue.svg)](https://www.facebook.com/microchiptechnology/)
[![Follow us on Twitter](https://img.shields.io/twitter/follow/MicrochipTech.svg?style=social)](https://twitter.com/MicrochipTech)

[![](https://img.shields.io/github/stars/Microchip-MPLAB-Harmony/core.svg?style=social)]()
[![](https://img.shields.io/github/watchers/Microchip-MPLAB-Harmony/core.svg?style=social)]()


