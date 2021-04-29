---
grand_parent: Bootloader Library Help
parent: I2C Bootloader
title: Bootloader System Execution Flow
has_toc: false
nav_order: 2
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# I2C Bootloader system level execution flow

## Bootloader system level execution flow

- The Bootloader code starts executing on a device Reset

- If there are no conditions to enter the firmware upgrade mode, the Bootloader starts executing the user application
    - Refer to [Bootloader Trigger Methods](../../../../docs/bootloader_trigger_methods.md) for different conditions to enter firmware upgrade mode

- The Bootloader performs Flash erase/program operations while in the firmware upgrade mode

    <p align="center">
        <img src = "../images/basic_bootloader_execution_flow.png"/>
    </p>

## Additional Information

- Refer to [Firmware Update Mode execution flow](./i2c_bootloader_firmware_update_execution_flow.md) to understand how the firmware update takes place in bootloader
