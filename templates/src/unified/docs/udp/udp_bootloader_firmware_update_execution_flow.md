---
parent: Appendix
title: UDP Bootloader Firmware Update Execution Flow
has_toc: false
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# UDP Bootloader Firmware Update mode execution flow

## Bootloader Task Flow

- Erases the Flash memory 

- Programs the hex file records into Flash memory 

- Jumps to the Application 

- Calls the DataStream Task at end of its every state machine execution to receive any packet from the Host PC 

    <p align="center">
        <img src = "../images/bootloader_task_execution_flow.png"/>
        <img src = "../images/bootloader_process_command_execution_flow.png"/>
    </p>

## DataStream Task Flow

- This task is used to receive data bytes from host PC and to send response to host PC 

- It notifies the Bootloader task on completion of Data Reception or data transmit through callback 

    <p align="center">
        <img src = "../images/bootloader_datastream_task_execution_flow.png"/>
    </p>
