---
parent: Bootloader Library Help
title: UART Bootloader
has_children: true
has_toc: false
nav_order: 1
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# UART Bootloader

The UART bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger.

## Features

- Supported on CORTEX-M and MIPS based MCUs
- Uses Harmony 3 UART PLIB to communicate resulting in **smaller bootloader size**
- Supports Fail Safe update
- Takes **Binary File** as input
- Uses **command line host script** to receive binary from Host PC

**Running From SRAM (For SAM Devices)**

- Supports simultaneous Flash memory write and reception of the next block of data, Achieved by loading bootloader into flash and running from SRAM

- Has capability to self update as it is running from SRAM

    <p align="center">
        <img src = "../images/bootloader_ram_layout.png"/>
    </p>

- At reset the bootloader Reset handler copies the entire bootloader firmware into SRAM from Start location and start executing from SRAM
- Once the application is called from bootloader, applications startup code takes control over SRAM and starts executing

## UART Bootloader Block Diagram

<p align="center">
    <img src = "./images/uart_bootloader_block_diagram.png"/>
</p>

1. **Input Task:**
    - This task is responsible for receiving data from Embedded Host through the UART communication interface

    - The task keeps polling for data to be received when bootloader is in idle mode

    - The task also validates the incoming packet from host with expected header information

    - Once the packet reception is completed it gives control to **Command Task**

2. **Command Task:**
    - This task processes the commands received from **Input Task** and provides response back to host accordingly

    - If the command received is a **Data command** it gives control to the **Flash Task**

3. **Flash Task:**
    - This task is responsible to program the internal flash memory with data packet received

    - The task uses the NVM peripheral library to perform the Unlock/Erase/Write Operations

    - The task also invokes **Input Task** in parallel to receive next packet while waiting for the flash operation to complete for **CORTEX-M based MCUs**


| Topic                                                                             | Description                                           |
|-----------------------------------------------------------------------------------|-------------------------------------------------------|
| [How The Library Works](./uart_bootloader_how_library_works.md)                   | This section describes how the UART Bootloader Library Works |
| [Bootloader System Execution Flow](./uart_bootloader_system_execution_flow.md)    | This section describes the bootloader system level execution flow |
| [Bootloader Configurations](./uart_bootloader_configurations.md)                  | This section provides information on how to configure UART Bootloader library |
| [Application Configurations](./uart_application_configurations.md)                | This section provides information on how to configure an application to be bootloaded |
| [Library Interface](./uart_bootloader_library_interface.md)                       | This section describes the Application Programming Interface (API) functions of the UART Bootloader library |
| [Tools Help](../../../../../tools/docs/readme_btl_host.md)                        | This section provides information on Host script used for UART bootloader |
| [Debugging Help](./uart_debugging.md)                                             | This section provides information on debugging UART bootloader and application|

