# How the I2C Bootloader library works

The CAN Bootloader firmware communicates with the embedded host device by using a predefined communication protocol.

The I2C Bootloader works in two different modes

**Basic Mode**

-   This mode is supported for all the devices

-   Resides from

    -   The starting location of the flash memory region for CORTEX-M based MCUs

-   The Bootloader performs flash erase/program/verify operations with the binary sent from host while in the firmware upgrade mode

    -   The binary sent is only of the application to be programmed

    -   Bootloader always performs flash operation from the address for \(bootloader or application\) binary sent from host

    -   The application can use the entire flash memory region starting from the end of bootloader space

-   Jumps to the application once verification is completed


**Fail Safe Update Mode**

-   This mode is supported for the devices which have a Dual Bank flash memory

-   Resides from the starting location of the flash memory region of both the banks on **CORTEX-M based MCUs**

-   The Bootloader performs flash erase/program/verify operations with the binary sent from host while in the firmware upgrade mode

    -   Bootloader can perform flash operation in either of the banks based on the address sent by the host application

    -   The application can use only the flash memory region of one bank.

-   Performs a bank swap and reset to run the application programmed in opposite bank once verification is completed or a normal reset to run the application in current bank based on command sent from host


-   **[Basic Memory layout for CORTEX-M based MCUs](GUID-8DC24BD7-3112-401A-A207-3A1FC3A416AB.md)**  

-   **[Fail Safe Update Memory layout for CORTEX-M based MCUs](GUID-A6CA4BD5-4F43-4E12-8624-3AA1328B3DFE.md)**  

-   **[I2C Bootloader Protocol](GUID-3942704D-13D2-4E8E-A9DC-4055E7F6D5AB.md)**  


**Parent topic:**[I2C Bootloader](GUID-DAABEA91-BE58-400D-B1FE-1808457896A8.md)

