---
parent: Bootloader Library Help
title: Serial Memory Bootloader
has_children: true
has_toc: false
nav_order: 4
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Serial Memory Bootloader

The Serial Memory bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger.

## Features

- Supported on CORTEX-M and MIPS based MCUs

- Uses Harmony 3 Serial Memory drivers to communicate with the associated serial memory. Below are the serial memory drivers used
    - **I2C EEPROM:** AT24 Driver
    - **SPI EEPROM:** AT25 Driver
    - **SPI Flash:**  SST26 Driver
    - **QSPI Flash:** SST26 Driver

## Serial Memory Bootloader Block Diagram

<p align="center">
    <img src = "./images/serial_bootloader_block_diagram.png"/>
</p>

- **Bootloader Task**
    - Uses Serial Memory driver to reads the application binary stored in serial memory.

    - Erases the Internal Flash memory

    - Programs the read binary into Flash memory

    - Verifies the programed application

    - Jumps to the Application

    - Runs in Cooperative mode with other tasks in the system


| Topic                                                                             | Description                                           |
|-----------------------------------------------------------------------------------|-------------------------------------------------------|
| [How The Library Works](./serial_bootloader_how_library_works.md)                 | This section describes how the Serial Memory Bootloader Library Works |
| [Bootloader Execution Flow](./serial_bootloader_execution_flow.md)                | This section describes the bootloader execution flow |
| [Bootloader Configurations](./serial_bootloader_configurations.md)                | This section provides information on how to configure Serial Memory Bootloader library |
| [Application Configurations](./serial_application_configurations.md)              | This section provides information on how to configure an application to be bootloaded |
| [Library Interface](./serial_bootloader_library_interface.md)                     | This section describes the Application Programming Interface (API) functions of the Serial Memory Bootloader library |
| [Debugging Help](./serial_debugging.md)                                           | This section provides information on debugging Serial Memory bootloader and application|

