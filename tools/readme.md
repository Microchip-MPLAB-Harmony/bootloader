---
parent: Appendix
title: Tools Help
has_children: true
has_toc: false
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Tools Help

This document describes the usage of bootloader host tools

## Downloading the host tools

To clone or download these host tools from Github,go to the [main page of this repository](https://github.com/Microchip-MPLAB-Harmony/bootloader) and then click Clone button to clone this repo or download as zip file. This content can also be download using content manager by following [these instructions](https://github.com/Microchip-MPLAB-Harmony/contentmanager/wiki)

### Following host tools are provided to be used with different bootloaders

| Host Script                                                                       | Description                                           |
| ----------------------------------------------------------------------------------|-------------------------------------------------------|
| [btl_host.py](./docs/readme_btl_host.md)                                          | Used to communicate with the Bootloader running on the device via **UART** interface      |
| [btl_app_merge_bin.py](./docs/readme_btl_app_merge_bin.md)                        | Used to merge the bootloader binary and application binary                                |
| [btl_bin_to_c_array.py](./docs/readme_btl_bin_to_c_array.md)                      | Used to convert the binary output to a C style array containing Hex output                |
| [UnifiedHost for UDP](./docs/readme_UnifiedHost_udp.md)                           | Used to communicate with the UDP Bootloader running on the device |
| [UnifiedHost for USB Device HID](./docs/readme_UnifiedHost_usb_device_hid.md)     | Used to communicate with the USB Device HID Bootloader running on the device |
