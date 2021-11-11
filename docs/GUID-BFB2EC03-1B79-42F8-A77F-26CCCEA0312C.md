# How the USB Device HID Bootloader library works

The USB Device HID Bootloader firmware communicates with the **Unified Host application** running on Host PC by using a predefined communication protocol.

The USB Device HID Bootloader works in two different modes

**Basic Mode**

-   This mode is supported for all the devices

-   Resides from

    -   The starting location of the flash memory region for CORTEX-M based MCUs

    -   The starting location of the Boot flash memory region or Program flash memory region for MIPS based MCUs devices

-   The Bootloader performs flash erase/program/verify operations with the application hex sent from host PC using the Unified Bootloader Host Application while in the firmware upgrade mode

    -   Bootloader always performs flash operation from the address received via hex record

    -   The application can use the entire flash memory region starting from the end of bootloader space

-   Jumps to the application once programming is completed


**Live Update Mode**

-   This mode is supported for the devices which have a Dual Bank flash memory

-   Resides from

    -   The starting location of the flash memory region of **both the banks** on CORTEX-M based MCUs along with application code

    -   The starting location of the Program flash memory region of **both the banks** for MIPS based MCUs devices along with application code

-   The Bootloader task performs flash erase/program/verify operations with the application hex sent from host PC using the Unified Bootloader Host Application in the **Inactive bank**

-   Performs a bank swap and reset to run the application programmed in inactive bank on application task request


-   **[Basic Memory layout for CORTEX-M based MCUs](GUID-8DC24BD7-3112-401A-A207-3A1FC3A416AB.md)**  

-   **[Basic Memory layout for MIPS based MCUs](GUID-C2AA810E-4247-4971-99CA-8F3D78A9DD2F.md)**  

-   **[Live Update Memory layout for CORTEX-M based MCUs](GUID-6AFE1F49-ABB7-45E3-B783-95058156850B.md)**  

-   **[Live Update Memory layout for MIPS based MCUs](GUID-FE2D4DDB-3A4B-4304-A86D-0A227017B23D.md)**  

-   **[USB Device HID Bootloader Protocol](GUID-9D8745A3-BF8B-4B77-B2B0-D0322693C210.md)**  


**Parent topic:**[USB Device HID Bootloader](GUID-EEB0BC77-4006-44EF-8E7F-A9B4D5948189.md)

