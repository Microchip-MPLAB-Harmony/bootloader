# Application project configurations for CORTEX-M based MCUs

**Application settings in MHC system configuration**

-   Launch MHC for the application project to be configured

-   Select **system** component from the project graph and configure the below highlighted settings


![arm_application_config_mhc](GUID-884E06F5-6D3B-4644-BF4E-489A0719D744-low.png)

-   **Disable Fuse Settings:**

    -   Fuse settings needs to be disabled for the application which will be boot-loaded as the fuse settings are supposed to be programmed through programming tool from bootloader code. Also the fuse settings are not programmable through firmware

    -   Enabling the fuse settings also increases the size of the binary when generated through the hex file

    -   When updating the bootloader itself, make sure that the fuse settings for the bootloader application are also disabled

-   **Specify the Application Start Address:**

    -   Specify the Start address from where the application will run under the **Application Start Address \(Hex\)** option in System block in MHC.

    -   This value should be equal to or greater than the bootloader size and must be aligned to the erase unit size on that device.

    -   As this value will be used by bootloader to Jump to application at device reset it should match the value provided to bootloader code

    -   The **Application Start Address \(Hex\)** will be used to generate XC32 compiler settings to place the code at intended address

    -   After the project is regenerated, the ROM\_ORIGIN and ROM\_LENGTH are the XC32 linker variables which will be overridden with value provided for **Application Start Address \(Hex\)** and can be verified under Options for xc32-ld in Project Properties in MPLABX IDE as shown below.


![arm_application_config_xc32_ld_rom](GUID-03318D93-39BD-4849-8316-6BCBEEDDC6FD-low.png)

**MPLAB X Settings**

**For Bootloading the application using binary file**

-   Below are the Bootloaders which use application binary \(.bin\) file as input

    -   **UART**

    -   **I2C**

    -   **CAN**

    -   **Serial Memory**

    -   **File System**

-   Specifying post build option to automatically generate the binary file from hex file once the build is complete


```c
${MP_CC_DIR}/xc32-objcopy -I ihex -O binary ${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.hex ${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.bin
```

![arm_application_config_post_build_script](GUID-E4E3DB3D-CEE5-4F32-94CC-5153840EEE7F-low.png)

**For Bootloading the application using Normalized Hex file**

-   Below are the Bootloaders which use Normalized application Hex \(.hex\) file as input

    -   **USB Device HID**

    -   **UDP**

-   Check the **Normalize hex file** option as shown below, as the **Unified bootloader host application** takes hex file as an input. **Normalizing the hex file will make sure the data in the hex file is arranged sequentially**


![arm_application_config_normalize_hex](GUID-8923AD3C-0894-4CEC-B766-B87E6CB459A7-low.png)

**Additional settings \(Optional\)**

-   **RAM\_ORIGIN** and **RAM\_LENGTH** values should be provided for reserving configured bytes from start of RAM to **trigger bootloader from firmware**

-   Under Project Properties, expand options for xc32-ld and define the values for **RAM\_ORIGIN** and **RAM\_LENGTH** under Additional options

-   This is optional and can be ignored if not required


![arm_application_config_xc32_ld_ram](GUID-4282A918-CB44-413D-83F6-B351D4FBC4C1-low.png)

**Parent topic:**[Configurations for the application to be bootloaded](GUID-81FF31CA-1770-4876-8AAB-FA0015038359.md)

