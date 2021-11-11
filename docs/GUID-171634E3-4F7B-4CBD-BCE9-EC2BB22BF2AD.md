# Bootloader Trigger Methods

**Bootloader can be invoked in number of ways:**

-. Bootloader will run automatically if there is no valid application firmware. - Firmware is considered valid if the first word at application start address is not **0xFFFFFFFF**

```
- Normally this word contains initial stack pointer value, so it will never be **0xFFFFFFFF** unless device is erased.
```

-   Bootloader application can implement the **bootloader\_Trigger\(\)** function which will be called during system initialization

    -   A GPIO pin can be used as an external trigger to invoke bootloader at startup.

    -   Bootloader can run on application \(internal\) request if the configured number of bytes from start of SRAM are equal to some trigger pattern.


**Example Implementation of bootloader\_Trigger\(\)**

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

**Application code to trigger bootloader**

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

**Parent topic:**[UART Bootloader system level execution flow](GUID-C34FDEFB-E3B0-4C31-9702-E3C457A1B6C7.md)

**Parent topic:**[I2C Bootloader system level execution flow](GUID-0F69B7CD-9FC1-43EC-BFBB-B52B8FBAFE9E.md)

**Parent topic:**[CAN Bootloader system level execution flow](GUID-58FF7035-084F-4CDE-A151-818752F0DCF2.md)

**Parent topic:**[Serial Memory Bootloader execution flow](GUID-A0B4A3D8-1681-4774-AF4E-2F076263772A.md)

**Parent topic:**[Bootloader system level execution flow](GUID-B1F2D637-5936-4FD2-BA57-9AEABCB58A3A.md)

**Parent topic:**[File System Bootloader system level execution flow](GUID-BF0771C3-3A36-4B29-9CD4-E9D7F6EC193F.md)

