---
grand_parent: Bootloader Library Help
parent: File System Bootloader
title: Serial Memory Bootloader Configurations
has_toc: false
nav_order: 5
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Serial Memory Bootloader Configurations

## Bootloader Specific User Configurations

<p align="center">
    <img src = "./images/fs_bootloader_mhc_config_serial.png"/>
</p>

- **Bootloader Media Type:**
    - Change the Media Type to **Serial Memory**

- **Bootloader NVM Memory Used:**
    - Specifies the memory peripheral used by bootloader to perform flash operations
    - The name of the peripheral will vary from device to device

- **Bootloader Size (Bytes):**
    - Specifies the maximum size of flash required by the bootloader
    - This size is calculated based on Bootloader type and Memory used
    - This size will vary from device to device and should always be aligned to device erase unit size

- **Enable Bootloader Trigger From Firmware:**
    - This Option can be used to Force Trigger bootloader from application firmware after a soft reset. It does so by reserving the specified number of bytes in SRAM from the start of the RAM. The reserved memory is updated by the application with a pre-defined pattern. The bootloader firmware in the [bootloader_Trigger()](./fs_bootloader_library_interface.md#bootloader_trigger) routine, can check the reserved memory for the pre-defined pattern and enter bootloader mode if the pattern matches.

    - **Number Of Bytes To Reserve From Start Of RAM:**
        - This option adds the provided offset to RAM Start address in bootloader linker script.
        - Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader to check at reset in [bootloader_Trigger()](./fs_bootloader_library_interface.md#bootloader_trigger) function

- **Application Binary Image Path:**
    - Application binary image file name with path. If only file name is mentioned bootloader will try to open the file from the root directory

    - **Default: image.bin**

    - Can be used to specify custom paths based on requirement
        - **Example: dir1/dir2/app.bin**

## File System Configurations

<p align="center">
    <img src = "./images/fs_bootloader_mhc_config_serial_fs.png"/>
</p>

- **Use File System Auto Mount Feature:**
    - Enabled by default when File System Bootloader is added

- **Media Type:**
    - Change the Media Type to **SYS_FS_MEDIA_TYPE_SPIFLASH**

- **Make FAT File System Read-only:**
    - Enabled by default when File System Bootloader is added as there are no write operations to be done

    - Enabling this option also saves significant amount of flash memory

## Bootloader System Configurations

<p align="center">
    <img src = "./images/fs_bootloader_mhc_config_serial_system.png"/>
</p>

- **Application Start Address (Hex):**
    - Start address of the application which will programmed by bootloader
    - This value is filled by bootloader when its loaded which is equal to the bootloader size. It can be modified as per user need
    - This value will be used by bootloader to Jump to application at device reset

## Bootloader Linker Pre Processor Macros for CORTEX-M based MCUs

- Based on the configurations the above linker pre processor macros will be generated in MPLAB X xc32-ld settings
    - ROM_LENGTH specifies the size of the bootloader

    <p align="center">
        <img src = "./images/fs_bootloader_serial_linker_setting.png"/>
    </p>

## Additional Information

- Refer to [MIPS Bootloader Linker Script Configurations](../../../mips/docs/mips_bootloader_linker_config.md) for information on bootloader linker script generated by MHC for MIPS based MCUs

- Refer to [Bootloader Sizing And Considerations](../../../docs/bootloader_sizing_and_considerations.md) for information on bootloader size change considerations
