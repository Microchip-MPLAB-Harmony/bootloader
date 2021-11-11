# I2C Bootloader system level execution flow

**Bootloader system level execution flow**

-   The Bootloader code starts executing on a device Reset

-   If there are no conditions to enter the firmware upgrade mode, the Bootloader starts executing the user application

    -   Refer to Bootloader Trigger Methods for different conditions to enter firmware upgrade mode

-   The Bootloader performs Flash erase/program operations while in the firmware upgrade mode


![basic_bootloader_execution_flow](GUID-2B877A41-C096-4466-9E49-8F1DE26FD97F-low.png)

-   **[Bootloader Trigger Methods](GUID-171634E3-4F7B-4CBD-BCE9-EC2BB22BF2AD.md)**  

-   **[I2C Bootloader Firmware Update mode execution flow](GUID-61DDF8DF-119C-4515-A818-68C933260DB9.md)**  


**Parent topic:**[I2C Bootloader](GUID-DAABEA91-BE58-400D-B1FE-1808457896A8.md)

