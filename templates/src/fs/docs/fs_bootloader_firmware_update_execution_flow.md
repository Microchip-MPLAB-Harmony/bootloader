---
parent: Appendix
title: File System Bootloader Firmware Update Execution Flow
has_toc: false
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# File System Bootloader Firmware Update mode execution flow

## Bootloader Task Flow

- Erases the Flash memory 

- Programs the binary into Flash memory 

- Jumps to the Application 

### USB Host MSD Bootloader Task Flow

<p align="center">
    <img src = "./images/bootloader_task_execution_flow_usb.png"/>
</p>

### SD Card and Serial Memory Bootloader Task Flow

<p align="center">
    <img src = "./images/bootloader_task_execution_flow_sdcard_serial.png"/>
</p>
