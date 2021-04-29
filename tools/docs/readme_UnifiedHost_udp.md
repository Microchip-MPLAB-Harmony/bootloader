---
grand_parent: Bootloader Library Help
parent: UDP Bootloader
title: Tools Help
nav_order: 6
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# UDP Bootloader Unified Host Script Help

## Downloading the host script

To clone or download these host tools from Github,go to the [main page of this repository](https://github.com/Microchip-MPLAB-Harmony/bootloader) and then click Clone button to clone this repo or download as zip file. This content can also be download using content manager by following [these instructions](https://github.com/Microchip-MPLAB-Harmony/contentmanager/wiki)

### Path of the tool within the repository is **tools/UnifiedHost-\*/UnifiedHost-\*.jar**

### Version and Support information

- Refer to **tools/UnifiedHost-\*/readme.txt** for information on versions and known issues if any

- **UART Protocol** is not supported in Harmony 3 using this tool

## Description

- This host script should be used to communicate with the UDP Bootloader running on the device

- It implements the Unified bootloader protocol required to communicate from host PC

- It sends the **Normalized Hex File** of the application to be bootloaded

## Configuring and Using the Unified Host tool

- Configure the Host PC for setting up IP Address to communicate with the device
    - Go to **Control Panel/Network and Internet/Network Connections**
    - Open **Ethernet properties**

    <p align="center">
        <img src = "./images/udp_host_pc_ethernet_properties.png"/>
    </p>

    - Double Click on **Internet Protocol Version 4 (TCP/IPv4)**

    <p align="center">
        <img src = "./images/udp_host_pc_ipv4_click.png"/>
    </p>

    - Configure the IP Address as shown below
        - **IP address : 192.168.1.12**
        - **Subnet Mask : 255.255.255.0**

    <p align="center">
        <img src = "./images/udp_host_pc_ip_address.png"/>
    </p>

- Double click on **tools/UnifiedHost-\*/UnifiedHost-\*.jar** file to launch the Host application

- Select the **Device architecture** and **Protocol** as shown below

    <p align="center">
        <img src = "./images/unified_host_device_arch.png"/>
    </p>

- Select **UDP Protocol**
    - Click on configure button to configure UDP port Number and IP Address

    <p align="center">
        <img src = "./images/unified_host_udp_setting.png"/>
    </p>

- Load the test application hex file to be programmed using below option

    <p align="center">
        <img src = "./images/unified_host_load_hex.png"/>
    </p>

- Open the **Console** window of the host application to view application bootloading sequence

    <p align="center">
        <img src = "./images/unified_host_tools_console.png"/>
    </p>

- Click on **Program Device** button to program the loaded test application hex file on to the device

    <p align="center">
        <img src = "./images/unified_host_program_device_udp.png"/>
    </p>

- Following snapshot shows output of successfully programming the test application

    <p align="center">
        <img src = "./images/unified_host_success_udp.png"/>
    </p>

## Using Unified Host Tool in debugging mode

- Launch Windows Command prompt in **tools/UnifiedHost-\*/** directory

- Run below command to launch Unified Host Application in debugging mode

      java -Djava.util.logging.config.file="logging.properties" -jar UnifiedHost-*.jar

- Once the tool is launched refer to steps mentioned above in [Configuring and Using the Unified Host tool](#configuring-and-using-the-unified-host-tool) to program application hex

- You can see the logs during programming sequence on the command prompt

- Once done you can open the **tools/UnifiedHost-\*/app.log** file and check for the programming sequence logs
