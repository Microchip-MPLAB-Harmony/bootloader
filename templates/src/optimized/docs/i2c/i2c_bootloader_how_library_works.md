---
grand_parent: Bootloader Library Help
parent: I2C Bootloader
title: How The Library Works
has_toc: false
nav_order: 1
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# How the I2C Bootloader library works

The CAN Bootloader firmware communicates with the embedded host device by using a predefined communication protocol.

The I2C Bootloader works in two different modes

## Basic Mode

- This mode is supported for all the devices

- Resides from
    - The starting location of the flash memory region for CORTEX-M based MCUs

- The Bootloader performs flash erase/program/verify operations with the binary sent from host while in the firmware upgrade mode
    - The binary sent is only of the application to be programmed
    - Bootloader always performs flash operation from the address for (bootloader or application) binary sent from host
    - The application can use the entire flash memory region starting from the end of bootloader space

- Jumps to the application once verification is completed

### Memory layout

- [Basic memory layout for CORTEX-M based MCUs](../../../../arm/docs/arm_bootloader_memory_layout_basic.md)

## Fail Safe Update Mode
- This mode is supported for the devices which have a Dual Bank flash memory

- Resides from the starting location of the flash memory region of both the banks on **CORTEX-M based MCUs**

- The Bootloader performs flash erase/program/verify operations with the binary sent from host while in the firmware upgrade mode
    - Bootloader can perform flash operation in either of the banks based on the address sent by the host application

    - The application can use only the flash memory region of one bank.

- Performs a bank swap and reset to run the application programmed in opposite bank once verification is completed or a normal reset to run the application in current bank based on command sent from host

### Memory layout

- [Fail Safe Update memory layout for CORTEX-M based MCUs](../../../../arm/docs/arm_bootloader_memory_layout_fail_safe_update.md)

## Additional Information

- For information on protocol used refer to [I2C Bootloader Protocol](./i2c_bootloader_protocol.md)
