---
parent: Appendix
title: Debugging Bootloaders For CORTEX-M based MCUs
has_toc: false
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Debugging UART, I2C and CAN Bootloaders for CORTEX-M based MCUs

The UART, I2C and CAN bootloaders for CORTEX-M based MCU's are designed to run from SRAM to support
- Simultaneous Flash memory write and reception of the next block of data

- Self update

    <p align="center">
        <img src = "../../src/optimized/docs/images/bootloader_ram_layout.png"/>
    </p>

- **For debugging these bootloaders make use of software breakpoints instead of Hardware breakpoints**

## Steps to enable software breakpoints and start debugging

1. Enable software breakpoint from the project configuration dashboard by clicking on the button as shown below

    <p align="center">
        <img src = "./images/arm_bootloader_debug_enable_soft_breakpoint.png"/>
    </p>

2. **Software breakpoints inside main() when running from SRAM do not work when set before starting the debugger.**
    - For them to work first set a Breakpoint in **startup_xc32.c** file as it is running from flash

    <p align="center">
        <img src = "./images/arm_bootloader_debug_set_startup_breakpoint.png"/>
    </p>

3. Start the debugger from MPLAB IDE and the **software break point** in startup file will be hit

    <p align="center">
        <img src = "./images/arm_bootloader_debug_startup_breakpoint_hit.png"/>
    </p>

4. Once the breakpoint is hit in startup file, then set breakpoints anywhere you want, like in **main()** function as shown below

    <p align="center">
        <img src = "./images/arm_bootloader_debug_set_main_breakpoint.png"/>
    </p>

5. Resume the debugger and you should be able to now debug as usual

    <p align="center">
        <img src = "./images/arm_bootloader_debug_main_breakpoint_hit.png"/>
    </p>

## Additional Information

- Refer to [Debugging Bootloader And Application](../../docs/debugging_bootloader_and_application.md) for debugging the application to be bootloaded along with bootloader
