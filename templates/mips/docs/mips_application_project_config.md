---
grand_parent: Appendix
parent: Configurations for MIPS based MCUs
title: Application Project Configurations
has_toc: false
nav_order: 3
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Project configurations for the application to be bootloaded

## Application Settings in MHC System Configuration

- Disable default linker file generation in system settings from MHC, As the application to be bootloaded will be using a custom linker file

    <p align="center">
        <img src = "./images/mips_application_config_mhc.png"/>
    </p>

## MPLAB X Settings

### For Bootloading the application using binary file

- Below are the Bootloaders which use application binary (.bin) file as input
    - **UART**
    - **I2C**
    - **CAN**
    - **Serial Memory**
    - **File System**

- Specifying post build option to automatically generate the binary file from hex file once the build is complete

    ```
${MP_CC_DIR}/xc32-objcopy -I ihex -O binary ${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.hex ${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.bin
    ```

    <p align="center">
        <img src = "./images/mips_application_config_post_build_script.png"/>
    </p>

### For Bootloading the application using Normalized Hex file

- Below are the Bootloaders which use Normalized application Hex (.hex) file as input
    - **USB Device HID**
    - **UDP**

- Check the **Normalize hex file** option as shown below, as the **Unified bootloader host application** takes hex file as an input. **Normalizing the hex file will make sure the data in the hex file is arranged sequentially**

    <p align="center">
        <img src = "./images/mips_application_config_normalize_hex.png"/>
    </p>
