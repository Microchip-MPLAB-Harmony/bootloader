---
parent: Appendix
title: UDP Bootloader Protocol
has_toc: false
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# UDP Bootloader Protocol

The Unified host application running on Host-PC uses below communication protocol to interact with the Bootloader firmware. The Unified host application acts as a master and issues commands to the Bootloader firmware to perform specific operations.

## Frame Format
The communication protocol follows the frame format, as shown below

[\<SOH\>...]\<SOH\>[\<DATA\>...]\<CRCL\>\<CRCH\>\<EOT\>

**Where:**

\<...\> Represents a byte

[...] Represents an optional or variable number of bytes

- The frame format remains the same in both directions, that is, from the host application to the Bootloader, and from the Bootloader to the host application.

- The frame starts with a control character, **Start of Header (SOH)**, and ends with another control character, **End of Transmission (EOT)**

- The integrity of the frame is protected by two bytes of Cyclic Redundancy Check (CRC)-16, represented by CRCL (low-byte) and CRCH (high-byte)

## Control Characters

Some bytes in the Data field may imitate the control characters, SOH and EOT. The Data Link Escape (DLE) character is used to escape such bytes that could be interpreted as control characters. The Bootloader always accepts the byte following a \<DLE\> as data, and always sends a \<DLE\> before any of the control characters.

| Control   | Hex Value | Description                       |
|-----------|-----------|-----------------------------------|
| \<SOH\>   | 0x01      | Marks the beginning of a frame    |
| \<EOT\>   | 0x04      | Marks the end of a frame          |
| \<DLE\>   | 0x10      | Data link escape                  |


## Commands
The PC host application can issue the commands listed in below to the Bootloader. The first byte in the data field carries the command.

| Command Value in Hexadecimal  | Description                               |
|-------------------------------|-------------------------------------------|
| 0x01                          | Read the Bootloader version information.  |
| 0x02                          | Erase the Flash.                          |
| 0x03                          | Program the Flash.                        |
| 0x04                          | Read the CRC.                             |
| 0x05                          | Jump to the application.                  |


## Read Bootloader Version Information

The Read Version command sequence is as shown in below table with corresponding response

| Request                                               | Response                                                                      |
|-------------------------------------------------------|-------------------------------------------------------------------------------|
| [\<SOH\>...]\<SOH\>[\<0x01\>]\<CRCL\>\<CRCH\>\<EOT\>  | [\<SOH\>...]\<SOH\>\<0x01\>\<MAJOR_VER\>\<MINOR_VER\>\<CRCL\>\<CRCH\>\<EOT\>  |

- The Bootloader responds to the PC request for version information in two bytes as shown above
    - MAJOR_VER = Major version of the Bootloader
    - MINOR_VER = Minor version of the Bootloader

## Erase Flash
The Erase Flash command sequence is as shown in below table with corresponding response

| Request                                               | Response                                                      |
|-------------------------------------------------------|---------------------------------------------------------------|
| [\<SOH\>...]\<SOH\>\<0x02\>\<CRCL\>\<CRCH\>\<EOT\>    | [\<SOH\>...]\<SOH\>\<0x02\>\<CRCL\>\<CRCH\>\<EOT\>            |


- On receiving the erase Flash command from the PC host application, the Bootloader erases that entire application program space starting from the application start address configured

- The Bootloader Task routine returns only after entire application space is erased

## Program Flash
The Program Flash command sequence is as shown in below table with corresponding response

| Request                                                               | Response                                              |
|-----------------------------------------------------------------------|-------------------------------------------------------|
| [\<SOH\>...]\<SOH\>\<0x03\>[\<HEX_RECORD\>...]\<CRCL\>\<CRCH\>\<EOT\> | [\<SOH\>...]\<SOH\>\<0x03\>\<CRCL\>\<CRCH\>\<EOT\>    |


- **HEX_RECORD** is the Intel Hex record in hexadecimal format

- The PC host application sends one or multiple hex records in Intel Hex format along with the program Flash command

- The MPLAB XC32 C/C++ Compiler generates the image in the Intel Hex format. Each line in the Intel hexadecimal file represents a hexadecimal record

- Each hexadecimal record starts with a colon (:) and is in ASCII format. The PC host application discards the colon and converts the remaining data from ASCII to hexadecimal, and then sends the data to the Bootloader

- The Bootloader extracts the destination address and data from the hex record, and writes the data into program Flash

## Read CRC (Currently Not Supported)
The Read CRC command sequence is as shown in below table with corresponding response

| Request                               | Response                                                      |
|---------------------------------------|---------------------------------------------------------------|
| [\<SOH\>...]\<SOH\>\<0x04\>\<ADRS_LB\>\<ADRS_HB\>\<ADRS_UB\>\<ADRS_MB\>\<NUMBYTES_LB\>\<NUMBYTES_HB\>\<NUMBYTES_UB\>\<NUMBYTES_MB\>\<CRCL\>\<CRCH\>\<EOT\> | [\<SOH\>...]\<SOH\>\<0x04\>\<FLASH_CRCL\>\<FLASH_CRCH\>\<CRCL\>\<CRCH\>\<EOT\>  |


- The read CRC command is used to verify the content of the program Flash after programming

- ADRS_LB, ADRS_HB, ADRS_UB and ADRS_MB represent the 32-bit Flash addresses from where the CRC calculation begins

- NUMBYTES_LB, NUMBYTES_HB, NUMBYTES_UB and NUMBYTES_MB represent the total number of bytes in 32-bit format for which the CRC is to be calculated

## Jump to Application
The Jump To Application command sequence is as shown in below table with corresponding response

| Request                                               | Response                                                      |
|-------------------------------------------------------|---------------------------------------------------------------|
| [\<SOH\>...]\<SOH\>\<0x05\>\<CRCL\>\<CRCH\>\<EOT\>    | [\<SOH\>...]\<SOH\>\<0x05\>\<CRCL\>\<CRCH\>\<EOT\>            |


- The Jump to Application command from the PC host application commands the Bootloader to execute the application

- Once response is sent it exits the firmware upgrade mode and begins executing the application
