---
grand_parent: Bootloader Library Help
parent: File System Bootloader
title: Library Interface
has_toc: true
nav_order: 7
---

# File System Bootloader Library Interface
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## System functions

### bootloader_Tasks

```c
void bootloader_Tasks(void)
```

**Summary**

Starts bootloader execution.

**Description**

This function can be used to start bootloader execution.

The function receives the application binary from the media using the File System service to program it into internal flash memory.

Once the complete application is received and programmed successfully, it resets the device to jump into programmed application.

**Precondition**

[bootloader_Trigger()](#bootloader_trigger) must be called to check for bootloader triggers at startup.

**Parameters**

None

**Returns**

None

**Example**

```c
bootloader_Tasks();
```

---

### bootloader_Trigger

```c
bool bootloader_Trigger(void);
```

**Summary**

Checks if Bootloader has to be executed at startup.

**Description**

This function can be used to check for a External HW trigger or Internal firmware trigger to execute bootloader at startup.

This function has to be implemented by the bootloader application to override the **WEAK implementation** in bootloader.c

The checks in trigger function should happen before any system resources are initialized apart for PORT, As the same system resource can be Re-initialized by the application if bootloader jumps to it and may cause issues.

- **External Trigger:**
    - Can be achieved by triggering a GPIO_PIN at startup.

- **Firmware Trigger:**
    - Application firmware which wants to execute bootloader at startup needs to fill first n bytes of ram location with a request pattern.
    The Number of bytes to be reserved for storing the pattern has to be configured in bootloader component configuration in MHC.

```c
uint32_t *sram = (uint32_t *)BTL_TRIGGER_RAM_START;

sram[0] = 0x5048434D;
sram[1] = 0x5048434D;
sram[2] = 0x5048434D;
sram[3] = 0x5048434D;
```

**Precondition**

PORT/PIO Initialize must have been called.

**Parameters**

None

**Returns**

- True  : If any of trigger is detected.
- False : If no trigger is detected..

**Example**

```c
#define BTL_TRIGGER_PATTERN  0x5048434D

static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START;

bool bootloader_Trigger(void)
{
    // Check for Bootloader Trigger Pattern in first 16 Bytes of RAM to enter Bootloader.
    if (BTL_TRIGGER_PATTERN == ramStart[0] && BTL_TRIGGER_PATTERN == ramStart[1] &&
        BTL_TRIGGER_PATTERN == ramStart[2] && BTL_TRIGGER_PATTERN == ramStart[3])
    {
        ramStart[0] = 0;
        return true;
    }

    // Check for Switch press to enter Bootloader
    if (SWITCH_Get() == 0)
    {
        return true;
    }

    return false;
}

void SYS_Initialize()
{
    NVMCTRL_Initialize();

    PORT_Initialize();

    if (bootloader_Trigger() == false)
    {
        run_Application();
    }

    CLOCK_Initialize();
}

```

---

### run_Application

```c
void run_Application(void);
```

**Summary**

Runs the programmed application at startup.

**Description**

This function can be used to run programmed application though bootloader at startup.

If the first 4Bytes of Application Memory is **not 0xFFFFFFFF** then it jumps to the application start address to run the application programmed through bootloader and never returns.

If the first 4Bytes of Application Memory **is 0xFFFFFFFF** then it returns from function and executes bootloader for accepting a new application firmware.

**Precondition**

[bootloader_Trigger()](#bootloader_trigger) must be called to check for bootloader triggers at startup.

**Parameters**

None

**Returns**

None

**Example**

```c
void SYS_Initialize()
{
    NVMCTRL_Initialize();

    PORT_Initialize();

    if (bootloader_Trigger() == false)
    {
        run_Application();
    }

    CLOCK_Initialize();
}

```
