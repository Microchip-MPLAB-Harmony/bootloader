---
parent: Appendix
title: Bootloader Trigger Methods
has_toc: false
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Bootloader Trigger Methods

### Bootloader can be invoked in number of ways:

1. Bootloader will run automatically if there is no valid application firmware.
    - Firmware is considered valid if the first word at application start address is not **0xFFFFFFFF**

    - Normally this word contains initial stack pointer value, so it will never be **0xFFFFFFFF** unless device is erased.

2. Bootloader application can implement the **bootloader_Trigger()** function which will be called during system initialization
    - A GPIO pin can be used as an external trigger to invoke bootloader at startup.

    - Bootloader can run on application (internal) request if the configured number of bytes from start of SRAM are equal to some trigger pattern.

### Example Implementation of bootloader_Trigger()

```c
#define BTL_TRIGGER_PATTERN  0x5048434D

static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START;

bool bootloader_Trigger(void)
{
    /* Check for Bootloader Trigger Pattern in first 16 Bytes of RAM to enter
     * Bootloader.
     */
    if (BTL_TRIGGER_PATTERN == ramStart[0] && BTL_TRIGGER_PATTERN == ramStart[1] &&
        BTL_TRIGGER_PATTERN == ramStart[2] && BTL_TRIGGER_PATTERN == ramStart[3])
    {
        ramStart[0] = 0;
        return true;
    }

    /* Check for Switch press to enter Bootloader */
    if (SWITCH_Get() == 0)
    {
        return true;
    }

    return false;
}

```

### Application code to trigger bootloader

```c
void invoke_bootloader(void)
{
    uint32_t *sram = (uint32_t *)BTL_TRIGGER_RAM_START;

    sram[0] = 0x5048434D;
    sram[1] = 0x5048434D;
    sram[2] = 0x5048434D;
    sram[3] = 0x5048434D;

    NVIC_SystemReset();
}

```
