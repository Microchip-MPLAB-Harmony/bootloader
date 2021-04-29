---
grand_parent: Bootloader Library Help
parent: UDP Bootloader
title: How The Library Works
has_toc: false
nav_order: 1
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# How the UDP Bootloader library works

The UDP Bootloader firmware communicates with the **Unified Host application** running on Host PC by using a predefined communication protocol. 

The UDP Bootloader works in two different modes

## Basic Mode

- This mode is supported for all the devices

- Resides from
    - The starting location of the flash memory region for CORTEX-M based MCUs

    - The starting location of the Boot flash memory region or Program flash memory region for MIPS based MCUs devices

- The Bootloader performs flash erase/program/verify operations with the application hex sent from host PC using the Unified Bootloader Host Application while in the firmware upgrade mode
    - Bootloader always performs flash operation from the address received via hex record

    - The application can use the entire flash memory region starting from the end of bootloader space

- Jumps to the application once programming is completed

### Memory layout

- [Basic memory layout for CORTEX-M based MCUs](../../../../arm/docs/arm_bootloader_memory_layout_basic.md)

- [Basic memory layout for MIPS based MCUs](../../../../mips/docs/mips_bootloader_memory_layout_basic.md)

## Live Update Mode
- This mode is supported for the devices which have a Dual Bank flash memory

- Resides from
    - The starting location of the flash memory region of **both the banks** on CORTEX-M based MCUs along with application code

    - The starting location of the Program flash memory region of **both the banks** for MIPS based MCUs devices along with application code

- The Bootloader task performs flash erase/program/verify operations with the application hex sent from host PC using the Unified Bootloader Host Application in the **Inactive bank**

- Performs a bank swap and reset to run the application programmed in inactive bank on application task request

- **For more information refer to below memory layouts**

### Memory layout

- [Live Update memory layout for CORTEX-M based MCUs](../../../../arm/docs/arm_bootloader_memory_layout_live_update.md)

- [Live Update memory layout for MIPS based MCUs](../../../../mips/docs/mips_bootloader_memory_layout_live_update.md)

## Additional Information

- For information on protocol used refer to [UDP Bootloader Protocol](./udp_bootloader_protocol.md)
