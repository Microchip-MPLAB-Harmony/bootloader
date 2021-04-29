---
grand_parent: Appendix
parent: Bootloader Memory Layout For CORTEX-M Based MCUs
title: Basic Memory layout
has_toc: false
nav_order: 1
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Basic Memory layout for CORTEX-M based MCUs

The placement of the Bootloader and the application in flash memory should be such that the application will not overwrite the Bootloader, and the Bootloader can properly program the application when it is downloaded.

- Bootloader code is always placed at start of the flash address

- The application code can be placed anywhere after the bootloader end address. The application start address should be **aligned to Erase Unit Size of the device**

- As the Bootloader code requires the application start address to be mentioned at compile time, it should match in both the application and bootloader

**Note:**

The start address and the end address of the Bootloader and the application will vary for different devices. Refer to respective Data sheets for details of Flash memory layout.

<p align="center">
    <img src = "./images/arm_basic_memory_layout.png"/>
</p>

## Additional Information

- Refer to [Configurations for CORTEX-M based MCUs](./arm_configurations.md) for more information on Bootloader linker and application configurations
