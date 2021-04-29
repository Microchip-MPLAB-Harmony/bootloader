---
parent: Bootloader Library Help
title: CAN Bootloader
has_children: true
has_toc: false
nav_order: 3
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# CAN Bootloader

The CAN bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger.

## Features

- Supported on CORTEX-M based MCUs
- Uses Harmony 3 CAN PLIB to communicate resulting in **smaller bootloader size**
- Supports Fail Safe update
- Takes **Binary File** as input
- Receives Binary from an **C Embedded Host Device**

**Running From SRAM (For SAM Devices)**

- Has capability to self update as it is running from SRAM

    <p align="center">
        <img src = "../images/bootloader_ram_layout.png"/>
    </p>

- At reset the bootloader Reset handler copies the entire bootloader firmware into SRAM from Start location and start executing from SRAM
- Once the application is called from bootloader, applications startup code takes control over SRAM and starts executing

## CAN Bootloader Block Diagram

<p align="center">
    <img src = "./images/can_bootloader_block_diagram.png"/>
</p>

1. **Input Task:**
    - This task is responsible for receiving data from Embedded Host through the CAN interface

    - The task keeps polling for data to be received when bootloader is in idle mode

    - Once the packet reception is completed it gives control to **Command Task**

2. **Command Task:**
    - The task first validates the incoming packet from host with expected header information

    - The task processes the commands received from **Input Task** and provides response back to host accordingly

    - If the command received is a **Data command** it gives control to the **Flash Task**

3. **Flash Task:**
    - This task is responsible to program the internal flash memory with data packet received

    - The task uses the NVM peripheral library to perform the Unlock/Erase/Write Operations


| Topic                                                                             | Description                                           |
|-----------------------------------------------------------------------------------|-------------------------------------------------------|
| [How The Library Works](./can_bootloader_how_library_works.md)                    | This section describes how the CAN Bootloader Library Works |
| [Bootloader System Execution Flow](./can_bootloader_system_execution_flow.md)     | This section describes the bootloader system level execution flow |
| [Bootloader Configurations](./can_bootloader_configurations.md)                   | This section provides information on how to configure CAN Bootloader library |
| [Application Configurations](./can_application_configurations.md)                 | This section provides information on how to configure an application to be bootloaded |
| [Library Interface](./can_bootloader_library_interface.md)                        | This section describes the Application Programming Interface (API) functions of the CAN Bootloader library |
| [Tools Help](./can_bootloader_tools_help.md)                                      | This section provides information on Host script used for CAN bootloader |
| [Debugging Help](./can_debugging.md)                                              | This section provides information on debugging CAN bootloader and application|

