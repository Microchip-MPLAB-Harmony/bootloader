---
grand_parent: Appendix
parent: Bootloader Memory Layout For MIPS Based MCUs
title: Basic Memory layout
has_toc: false
nav_order: 1
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Basic Memory layout for MIPS based MCUs

## Bootloader placement for various PIC32M product families

The bootloader is placed in **Boot Flash Memory (BFM)** or **Program Flash Memory (PFM)** based on the size of the bootloader and available Boot flash memory on the device.

- If the bootloader fits into the available BFM, it is placed in BFM. The user application can use the complete area of the program Flash memory.

- If the bootloader does not fit into the available BFM, its **reset handler** is placed in BFM and rest of code is placed in PFM. The user application can use the remaining area of the program Flash memory.

- The following table shows the available Boot Flash memory and the placement of different bootloaders by product family.

**Note:**

The Boot Flash and Program Flash memory end addresses may vary from device to device. Refer to respective Data sheets for details of Flash memory layout.

<p align="center">
    <img src = "../../docs/images/bootloader_placement.png"/>
</p>

## Basic Memory layout

<p align="center">
    <img src = "./images/mips_basic_memory_layout.png"/>
</p>

## Additional Information

- Refer to [Configurations for MIPS based MCUs](./mips_configurations.md) for more information on bootloader linker and application linker configurations
