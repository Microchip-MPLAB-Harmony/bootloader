---
grand_parent: Bootloader Library Help
parent: UDP Bootloader
title: Bootloader System Execution Flow
has_toc: false
nav_order: 2
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# UDP Bootloader system level execution flow

## Basic Bootloader system level execution flow

- The Bootloader code starts executing on a device Reset

- If there are no conditions to enter the firmware upgrade mode, the Bootloader starts executing the user application
    - Refer to [Bootloader Trigger Methods](../../../../docs/bootloader_trigger_methods.md) for different conditions to enter firmware upgrade mode

- The Bootloader performs Flash erase/program operations while in the firmware upgrade mode

    <p align="center">
        <img src = "../images/basic_bootloader_execution_flow.png"/>
    </p>

## Live Update Bootloader system level execution flow

- Supported for the devices which have a Dual Bank flash memory

### Cortex-M Based MCUs

- Special NVM Fuse setting **(AFIRST)** is used to identify which bank is mapped to NVM main address space after reset

- The bootloader live update code responsible to program the inactive bank is part of the application it self. Which means the programming operation can happen while the application is running
    - **Live Update Application = (Bootloader Code in Live Update mode + Application code)**

- The application code is responsible to send a request to bootloader live update code to perform a **bank swap and reset** to run the new firmware programmed in Inactive bank

<p align="center">
    <img src = "../images/live_update_bootloader_execution_flow_arm.png"/>
</p>

### MIPS Based MCUs

- Switcher Application in Boot flash memory is required to select the bank with latest firmware

    - At reset switcher first maps Bank 1 to lower region and reads the serial numbers from both banks

    - If Bank 2 serial number is greater than Bank 1 serial number, it maps Bank 2 to lower region by setting the Swap bit and runs the new firmware from BANK 2 else continues to run firmware from BANK 1

- The bootloader live update code responsible to program the inactive bank is part of the application it self. Which means the programming operation can happen while the application is running
    - **Live Update Application = (Bootloader Code in Live Update mode + Application code)**

- The bootloader live update code will always program the new image in the inactive bank

- The application code is responsible to send a request to bootloader live update code to perform a **bank swap and reset** to run the new firmware programmed in Inactive bank

- Once this request is received the bootloader live update code performs below operation before initiating a reset to run new firmware
    - **Inactive Serial number = Active serial number + 1**

    <p align="center">
        <img src = "../images/live_update_bootloader_execution_flow_mips.png"/>
    </p>

## Additional Information

- Refer to [Firmware Update Mode execution flow](./udp_bootloader_firmware_update_execution_flow.md) to understand how the firmware update takes place in bootloader
