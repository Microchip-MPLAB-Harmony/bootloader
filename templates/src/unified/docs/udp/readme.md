---
parent: Bootloader Library Help
title: UDP Bootloader
has_children: true
has_toc: false
nav_order: 6
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# UDP Bootloader

The UDP bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger.

## Features

- Supported on CORTEX-M and MIPS based MCUs
- Uses Harmony 3 TCIP Stack to communicate 
- Supports Live update
- Takes **Normalized Hex File** as input
- Uses **Unified Host application** to receive the hex file from Host PC

## UDP Bootloader Block Diagram

<p align="center">
    <img src = "./images/udp_bootloader_block_diagram.png"/>
</p>

**The Bootloader framework is divided into 2 sub-systems**

1. **Bootloader Task:**
    - Erases the Flash memory

    - Programs the hex file records into Flash memory

    - Computes a CRC check of the Application in Program Memory

    - Jumps to the Application

    - Calls the DataStream Task at end of its every state machine execution

    - This Task routine takes an interface-agnostic approach to the actual communication medium

    - **Runs in Cooperative mode with other tasks in the system**

2. **Datastream Task:**
    - This Task implements the UDP communication interface to the receive the hex file from the **Unified Host Application** running on Host PC

    - This Task is called from Bootloader Task routine


| Topic                                                                             | Description                                           |
|-----------------------------------------------------------------------------------|-------------------------------------------------------|
| [How The Library Works](./udp_bootloader_how_library_works.md)                    | This section describes how the UDP Bootloader Library Works |
| [Bootloader System Execution Flow](./udp_bootloader_system_execution_flow.md)     | This section describes the bootloader system level execution flow |
| [Bootloader Configurations](./udp_bootloader_configurations.md)                   | This section provides information on how to configure UDP Bootloader library |
| [Application Configurations](./udp_application_configurations.md)                 | This section provides information on how to configure an application to be bootloaded |
| [Library Interface](./udp_bootloader_library_interface.md)                        | This section describes the Application Programming Interface (API) functions of the UDP Bootloader library |
| [Tools Help](../../../../../tools/docs/readme_UnifiedHost_udp.md)                 | This section provides information on Host script used for UDP bootloader |
| [Debugging Help](./udp_debugging.md)                                              | This section provides information on debugging UDP bootloader and application|

