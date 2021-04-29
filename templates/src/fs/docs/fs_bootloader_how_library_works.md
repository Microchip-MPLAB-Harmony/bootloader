---
grand_parent: Bootloader Library Help
parent: File System Bootloader
title: How The Library Works
has_toc: false
nav_order: 1
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# How the File System Bootloader library works

The File System Bootloader firmware uses the File System API's to communicates with the underlying Media.

The File System Bootloader works in two different modes

- Bootloader resides from
    - The starting location of the flash memory region for CORTEX-M based MCUs

    - The starting location of the Boot flash memory region or Program flash memory region for MIPS based MCUs devices

- The Bootloader performs flash erase/program operations with the application binary received from the media in the firmware upgrade mode
    - Bootloader always performs flash operation from the application start address used during compile time

    - The application can use the entire flash memory region starting from the end of bootloader space

- Jumps to the application once programming is completed

### Memory layout

- [Basic memory layout for CORTEX-M based MCUs](../../../arm/docs/arm_bootloader_memory_layout_basic.md)

- [Basic memory layout for MIPS based MCUs](../../../mips/docs/mips_bootloader_memory_layout_basic.md)
