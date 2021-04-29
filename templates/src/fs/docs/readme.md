---
parent: Bootloader Library Help
title: File System Bootloader
has_children: true
has_toc: false
nav_order: 7
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# File System Bootloader

The File System bootloader library can be used to upgrade firmware on a target device without the need for an external programmer or debugger.

## Features

- Supported on CORTEX-M and MIPS based MCUs
- Uses Harmony 3 File System Service to communicate with underlying media
- Takes **Binary File** as input

## File System Bootloader Block Diagram

<p align="center">
    <img src = "./images/fs_bootloader_block_diagram.png"/>
</p>

- **Bootloader Task**
    - Uses File System Service to read the Binary file from the media

    - Erases the Flash memory

    - Programs the binary into Flash memory

    - Jumps to the Application

    - Runs in Cooperative mode with other tasks in the system

- **Supported Medias:**
    - **USB Host MSD**
    - **SDCARD**
    - **Serial Memory**
        - **I2C EEPROM**
        - **SPI EEPROM**
        - **SPI Flash**
        - **QSPI Flash**


| Topic                                                                                 | Description                                        |
|---------------------------------------------------------------------------------------|----------------------------------------------------|
| [How The Library Works](./fs_bootloader_how_library_works.md)                         | This section describes how the File System Bootloader Library Works |
| [Bootloader System Execution Flow](./fs_bootloader_system_execution_flow.md)          | This section describes the bootloader system level execution flow |
| [USB Host MSD Bootloader Configurations](./fs_bootloader_configurations_usb.md)       | This section provides information on how to configure File System Bootloader library with USB Host MSD Media|
| [SD Card Bootloader Configurations](./fs_bootloader_configurations_sdcard.md)         | This section provides information on how to configure File System Bootloader library with SD Card Media|
| [Serial Memory Bootloader Configurations](./fs_bootloader_configurations_serial.md)   | This section provides information on how to configure File System Bootloader library with Serial Memory Media|
| [Application Configurations](./fs_application_configurations.md)                      | This section provides information on how to configure an application to be bootloaded |
| [Library Interface](./fs_bootloader_library_interface.md)                             | This section describes the Application Programming Interface (API) functions of the File System Bootloader library |
| [Debugging Help](./fs_debugging.md)                                                   | This section provides information on debugging File System bootloader and application|

