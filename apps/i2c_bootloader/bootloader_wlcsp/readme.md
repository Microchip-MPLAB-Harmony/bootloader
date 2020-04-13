![Microchip logo](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_logo.png)
![Harmony logo small](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_mplab_harmony_logo_small.png)

# MPLAB® Harmony 3 I2C Bootloader for SAMD20E15BU and SAMD20E16BU
This application is a bootloader application which resides in the starting location of the device flash memory. The bootloader application uses SERCOM I2C in slave mode with interrupts disabled.

# Building the Application
| Application Path |  bootloader/apps/i2c_bootloader/bootloader_wlcsp/firmware |
|------------------|-----------------------------------------------------------|

To build the application, refer the following table and open the appropriate project file in the MPLAB X IDE v5.30.

| Project Name    | Description                                                |
|-----------------|------------------------------------------------------------|
| samd20e15bu_wlcsp.X    | Bootloader application for SAMD20E15BU              |
| samd20e16bu_wlcsp.X    | Bootloader application for SAMD20E16BU              |

# Hardware Setup
1. Project samd20e15bu_wlcsp.X
   * Hardware setup:
        * Connect the I2C SDA line (SERCOM2 PAD[0]/PA08) of SAMD20E15BU running the bootloader application to the I2C SDA line of the bootloader host application
        * Connect the I2C SCL line (SERCOM2 PAD[1]/PA09) of SAMD20E15BU running the bootloader application to the I2C SCL line of the bootloader host application
        * Connect a ground wire between the bootloader host and SAMD20E15BU
2. Project samd20e16bu_wlcsp.X
   * Hardware setup:
        * Connect the I2C SDA line (SERCOM2 PAD[0]/PA08) of SAMD20E16BU running the bootloader application to the I2C SDA line of the bootloader host application
        * Connect the I2C SCL line (SERCOM2 PAD[1]/PA09) of SAMD20E16BU running the bootloader application to the I2C SCL line of the bootloader host application
        * Connect a ground wire between the bootloader host and SAMD20E16BU

# Running the Application
1. The bootloader can be triggered in one of the following ways:
    * By driving both I2C SCL and SDA lines of SAMD20E15BU/SAMD20E16BU to logic low upon power up
    * By writing the 16 bytes of bootloader trigger pattern - 0x5048434D from the start of the RAM location - 0x20000000
    * Bootloader will automatically be entered if an application is not programmed. An application is considered as not being programmed, if the first word (32-bits) of the application (ie. Main Stack Pointer) contains 0xFFFFFFFF
2. To program the user application, one of the host application examples can be used or a custom host application can be developed by implementing the bootloader protocol.
	* [MPLAB® Harmony 3 Bootloader Host NVM Application Help](https://microchip-mplab-harmony.github.io/bootloader/00019.html)
	* [MPLAB® Harmony 3 Bootloader Host SD Card Application Help](https://microchip-mplab-harmony.github.io/bootloader/00024.html)

For more information, please refer the following bootloader help document.

- [MPLAB® Harmony 3 Bootloader Help](https://microchip-mplab-harmony.github.io/bootloader)
____

[![Follow us on Youtube](https://img.shields.io/badge/Youtube-Follow%20us%20on%20Youtube-red.svg)](https://www.youtube.com/user/MicrochipTechnology)
[![Follow us on LinkedIn](https://img.shields.io/badge/LinkedIn-Follow%20us%20on%20LinkedIn-blue.svg)](https://www.linkedin.com/company/microchip-technology)
[![Follow us on Facebook](https://img.shields.io/badge/Facebook-Follow%20us%20on%20Facebook-blue.svg)](https://www.facebook.com/microchiptechnology/)
[![Follow us on Twitter](https://img.shields.io/twitter/follow/MicrochipTech.svg?style=social)](https://twitter.com/MicrochipTech)


