[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Bootloader Unified Host Script Help

This document describes the usage of Unified Host Script

## Downloading the host script

To clone or download these host tools from Github,go to the [main page of this repository](https://github.com/Microchip-MPLAB-Harmony/bootloader) and then click Clone button to clone this repo or download as zip file. This content can also be download using content manager by following [these instructions](https://github.com/Microchip-MPLAB-Harmony/contentmanager/wiki)

### Path of the tool within the repository is **tools/UnifiedHost-\*/UnifiedHost-\*.jar**

### Version and Support information

- Refer to **tools/UnifiedHost-\*/readme.txt** for information on versions and known issues if any

- **UART Protocol** is not supported in Harmony 3 using this tool

## Description

- This host script should be used to communicate with the Bootloader running on the device via
    - **USB Device HID interface**
    - **UDP Interface**
- It implements the Unified bootloader protocol required to communicate from host PC
- It sends the **Normalized Hex File** of the application to be bootloaded

## Configuring and Using the Unified Host tool

- Double click on **tools/UnifiedHost-\*/UnifiedHost-\*.jar** file to launch the Host application
- Select the **Device architecture** and **Protocol** as shown below

    ![unified_host_device_arch](./images/unified_host_device_arch.png)

- Selecting the desired **Protocol**

    - If using **USB Device HID Bootloader** then select **USB** protocol
    - Click on configure button and select the USB Device product ID. Example **3C*

        ![unified_host_usb_setting](./images/unified_host_usb_setting.png)

    - If using **UDP Bootloader** then select **UDP** protocol
    - Click on configure button to configure UDP port Number and IP Address

        ![unified_host_udp_setting](./images/unified_host_udp_setting.png)

- Load the test application hex file to be programmed using below option

    ![unified_host_load_hex](./images/unified_host_load_hex.png)

- Open the **Console** window of the host application to view application bootloading sequence

    ![unified_host_tools_console](./images/unified_host_tools_console.png)

- Click on **Program Device** button to program the loaded test application hex file on to the device

    ![unified_host_program_device](./images/unified_host_program_device.png)

- Following snapshot shows output of successfully programming the test application

    ![unified_host_success](./images/unified_host_success.png)

## Using Unified Host Tool in debugging mode

- Launch Windows Command prompt in **tools/UnifiedHost-\*/** directory

- Run below command to launch Unified Host Application in debugging mode

      java -Djava.util.logging.config.file="logging.properties" -jar UnifiedHost-*.jar

- Once the tool is launched refer to steps mentioned above in **Configuring and Using the Unified Host tool** to program application binary

- You can see the logs during programming sequence on the command prompt

- Once done you can open the **tools/UnifiedHost-\*/app.log** file and check for the programming sequence logs
