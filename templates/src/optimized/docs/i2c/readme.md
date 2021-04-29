---
parent: Bootloader Library Help
title: I2C Bootloader
has_children: true
has_toc: false
nav_order: 2
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# I2C Bootloader

The I2C bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger.

## Features

- Supported Only on CortexM0+ and CortexM4 based Devices
- Uses Harmony 3 I2C PLIB to communicate resulting in **smaller bootloader size**
- Supports Fail Safe update
- Takes **Binary File** as input
- Receives Binary from an **I2C Embedded Host Device**

**Running From SRAM (For SAM Devices)**

- Has capability to self update as it is running from SRAM

    <p align="center">
        <img src = "../images/bootloader_ram_layout.png"/>
    </p>

- At reset the bootloader Reset handler copies the entire bootloader firmware into SRAM from Start location and start executing from SRAM
- Once the application is called from bootloader, applications startup code takes control over SRAM and starts executing

## I2C Bootloader Block Diagram

<p align="center">
    <img src = "./images/i2c_bootloader_block_diagram.png"/>
</p>

1. **I2C Event Processor Task:**

    - This task is responsible for receiving data from Embedded Host through the I2C communication interface

    - The task polls and processes the I2C events.

    - Based on the event received it gives control to **I2C Master Write Request** or **I2C Master Read Request** functions

    - This task is responsible for responding to the bootloader commands received

2. **I2C Master Write Request:**
    - This function is responsible to handle any write requests coming from I2C master

    - It processes the commands received and notifies the status to **I2C Event Process Task**

    - If the command received is a Erase/Prgram/Verify command it gives control to the **Flash task**

3. **I2C Master Read Request:**
    - This function is responsible to handle any read requests coming from I2C master

    - It sends the current status to I2C master if the command received is **Read Status**

4. **Flash Task:**
    - This task is responsible to Erase/Prgram/Verify the internal flash memory with data packet received

    - The task uses the NVM peripheral library to perform the Unlock/Erase/Write Operations


| Topic                                                                             | Description                                           |
|-----------------------------------------------------------------------------------|-------------------------------------------------------|
| [How The Library Works](./i2c_bootloader_how_library_works.md)                    | This section describes how the I2C Bootloader Library Works |
| [Bootloader System Execution Flow](./i2c_bootloader_system_execution_flow.md)     | This section describes the bootloader system level execution flow |
| [Bootloader Configurations](./i2c_bootloader_configurations.md)                   | This section provides information on how to configure I2C Bootloader library |
| [Application Configurations](./i2c_application_configurations.md)                 | This section provides information on how to configure an application to be bootloaded |
| [Library Interface](./i2c_bootloader_library_interface.md)                        | This section describes the Application Programming Interface (API) functions of the I2C Bootloader library |
| [Tools Help](./i2c_bootloader_tools_help.md)                                      | This section provides information on Host script used for I2C bootloader |
| [Debugging Help](./i2c_debugging.md)                                              | This section provides information on debugging I2C bootloader and application|

