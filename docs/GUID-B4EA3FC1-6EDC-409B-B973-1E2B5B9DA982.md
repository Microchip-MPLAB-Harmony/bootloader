# UDP Bootloader Unified Host Script Help

**Downloading the host script**

To clone or download these host tools from Github,go to the [main page of this repository](https://github.com/Microchip-MPLAB-Harmony/bootloader) and then click Clone button to clone this repo or download as zip file. This content can also be download using MCC content manager

Path of the tool within the repository is **tools/UnifiedHost-\*/UnifiedHost-\*.jar**

Version and Support information

-   Refer to **tools/UnifiedHost-\*/readme.txt** for information on versions and known issues if any

-   **UART Protocol** is not supported in Harmony 3 using this tool


**Description**

-   This host script should be used to communicate with the USB Device HID Bootloader running on the device

-   It implements the Unified bootloader protocol required to communicate from host PC

-   It sends the **Normalized Hex File** of the application to be bootloaded


**Configuring and Using the Unified Host tool**

-   Configure the Host PC for setting up IP Address to communicate with the device

    -   Go to **Control Panel/Network and Internet/Network Connections**

    -   Open **Ethernet properties**


![udp_host_pc_ethernet_properties](GUID-A249767F-EB86-4230-A167-237A3AA8FC60-low.png)

```
- Double Click on **Internet Protocol Version 4 (TCP/IPv4)**
```

![udp_host_pc_ipv4_click](GUID-652C0679-1387-442D-951F-BC6AE9A7C759-low.png)\>

```
- Configure the IP Address as shown below
    - **IP address : 192.168.1.12**
    - **Subnet Mask : 255.255.255.0**
```

![udp_host_pc_ip_address](GUID-D85D28EE-E635-47CA-B60E-B757CAB4231C-low.png)

-   Double click on **tools/UnifiedHost-\*/UnifiedHost-\*.jar** file to launch the Host application

-   Select the **Device architecture** and **Protocol** as shown below


![unified_host_device_arch](GUID-AE6C9355-F186-47A7-9685-DC44610A8DA3-low.png)

-   Select **UDP Protocol**

    -   Click on configure button to configure UDP port Number and IP Address


![unified_host_udp_setting](GUID-B3585DA5-EFDE-41CA-9105-6F167C93DC86-low.png)

-   Load the test application hex file to be programmed using below option


![unified_host_load_hex](GUID-504E3163-B144-4931-B63B-5A56BDF281DE-low.png)

-   Open the **Console** window of the host application to view application bootloading sequence


![unified_host_tools_console](GUID-DCD70856-D306-4802-BEE0-5FD71D8DB9B0-low.png)

-   Click on **Program Device** button to program the loaded test application hex file on to the device


![unified_host_program_device_udp](GUID-494A850D-5011-463A-BA95-19AC133D86E1-low.png)

-   Following snapshot shows output of successfully programming the test application


![unified_host_success_udp](GUID-745AA08A-82CA-49D1-8265-0BAE4C291125-low.png)

**Using Unified Host Tool in debugging mode**

-   **On Windows:**

    -   Launch Windows Command prompt in **tools/UnifiedHost-\*/** directory

    -   Run below command to launch Unified Host Application in debugging mode

        ```c
        java -Djava.util.logging.config.file="logging.properties" -jar UnifiedHost-*.jar
        ```

-   **On Linux**

    -   For running Unified Host tool in debug mode on linux make use of MPLAB X's Java JRE

    -   Launch Linux Command prompt in **tools/UnifiedHost-\*/** directory

    -   Run below command to launch Unified Host Application in debugging mode

        ```c
        /opt/microchip/mplabx/<MPLAB X Version>/sys/java/zulu8.40.0.25-ca-fx-jre8.0.222-linux_x64/bin/java -Djava.util.logging.config.file="logging.properties" -jar UnifiedHost-*.jar
        ```

-   Once the tool is launched refer to steps mentioned above in Configuring and Using the Unified Host tool to program application hex

-   You can see the logs during programming sequence on the command prompt

-   Once done you can open the **tools/UnifiedHost-\*/app.log** file and check for the programming sequence logs


**Parent topic:**[UDP Bootloader](GUID-C2D4E98A-C367-48ED-9079-5AC48374542D.md)

