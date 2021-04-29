---
parent: Appendix
title: UART Bootloader Protocol
has_toc: false
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# UART Bootloader Protocol

## Request Packet

**The uart bootloader protocol as shown in below figure is common for all the supported commands.**

<p align="center">
    <img src = "./images/uart_bootloader_protocol.png"/>
</p>

### GUARD
- The Guard value must be a constant value of **0x5048434D**

- This value provides protection against spurious commands

- Bootloader always checks for the Guard value at start of packet reception and proceeds further accordingly

### Data Size
- This field indicates the number of data bytes to be received

- This value varies for different commands

### Command
- Indicates the command to be processed. Each command is of 1 Byte width

- Below are the supported commands

| Command Type          | Command Code  | Description                                                       |
|-----------------------|---------------|-------------------------------------------------------------------|
| Unlock                | 0xA0          | Used to calculate application start address and end address       |
| Data                  | 0xA1          | Used to send the image data                                       |
| Verify                | 0xA2          | Used to verify the image data sent and programmed                 |
| Reset                 | 0xA3          | Used to trigger a reset to run the application                    |
| Bank Swap and reset   | 0xA4          | Used to Swap the bank and trigger a reset to run the application  |

### Data
- Contains the actual Data to be processed based on the command

- Length of the data to be received is indicated by Data Size field

- Bootloader receives data in size of words

- All data words must be sent in a little-endian (LSB first) format

## Response Codes

Bootloader will send a **single character response code** in response to each command. Sequential commands can only be sent after the response code is received for a previous command, or after 100 ms timeout without a response.

| Response Type | Response Code | Description                                               |
|---------------|---------------|-----------------------------------------------------------|
| OK            | 0x50          | Command was received and processed successfully           |
| Error         | 0x51          | There were errors during the processing of the command    |
| Invalid       | 0x52          | Invalid command is received                               |
| CRC OK        | 0x53          | CRC verification was successful                           |
| CRC Fail      | 0x54          | CRC verification failed                                   |

## Command Description

### Unlock Command

The Unlock Command sequence is as shown in below figure with corresponding responses.

<p align="center">
    <img src = "./images/uart_bootloader_unlock_command.png"/>
</p>

- Unlock command must be issued before the first Data command
    - It is used to calculate application start address and end address

    - This information will be used to validate if the addresses sent are within the range of flash memory

    - It will also be used to validate the address coming with data packet to be programmed are within the region for which the unlock command is invoked

- Number of bytes of data to be received is 8 Bytes (Start Address + Image Size)

- Start Address
    - It is the application Start Address of the flash memory
    - It is device dependent and should be always greater than or equal to the bootloader end address
    - It must be aligned at an Erase Unit Size boundary, which is also device dependent
    - To upgrade the bootloader itself this value must be set to 0 **(For CORTEX-M based MCUs)**

- Image size must be in increments of Erase Unit bytes which is also device dependent

### Data Command

The Data Command sequence is as shown in below figure with corresponding responses.

<p align="center">
    <img src = "./images/uart_bootloader_data_command.png"/>
</p>

- Data command is used to send the image data

- Data size is equal to sum of block start address (4 Bytes) and Erase Unit Size which is device dependent

- Block start address must be located inside the region previously unlocked via the Unlock command

- Attempts to request the write outside of the unlocked region will result in error and supplied data will be discarded

### Verify Command

The Verify Command sequence is as shown in below figure with corresponding responses.

<p align="center">
    <img src = "./images/uart_bootloader_verify_command.png"/>
</p>

- Verify command is used to verify the image data sent and programmed

- Image CRC is a standard IEEE CRC32 with a polynomial of **0xEDB88320**

- Internal CRC is calculated based on the values actually read from the Flash memory after programming, so it verifies the whole chain.

- Image CRC is calculated over the previously unlocked region.

### Reset Command

The Reset Command sequence is as shown in below figure with corresponding responses.

<p align="center">
    <img src = "./images/uart_bootloader_reset_command.png"/>
</p>

- Reset command is used to exit the bootloader and run the application

- It is necessary if the host has no control over the reset pin. It can also be useful even if host has control over the Reset

### Bank Swap and Reset Command

The Bank Swap and Reset Command sequence is as shown in below figure with corresponding responses

<p align="center">
    <img src = "./images/uart_bootloader_BankSwap_Reset_command.png"/>
</p>

- This command is enabled only when **Fail safe update** feature is selected for bootloader and the device has support for Dual Bank update

- Bank Swap and Reset command is used to **Swap the inactive bank to active bank** and trigger a reset to exit the bootloader and run the new application programmed in the inactive bank


### Note
As this bootloader supports simultaneous Flash memory write and reception of the next block of data, The next block of data may be transmitted as soon as the status code is returned for the first one.

Because of this behavior, the status code for the last block will be sent before this block is written into the Flash memory. To ensure that this block is written, host must send another command and wait for the response. So either Verify or Reset command must be sent after the last block of data.
