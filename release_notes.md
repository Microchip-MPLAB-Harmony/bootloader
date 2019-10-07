![Microchip logo](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_logo.png)
![Harmony logo small](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_mplab_harmony_logo_small.png)

# Microchip MPLAB® Harmony 3 Release Notes

## Bootloader Release v3.1.2
### New Features

- **New part support** - This release introduces initial support of UART bootloader for [SAM DA1](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-d-mcus), [SAM D09/D10/D11](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-d-mcus), [PIC32MX 1XX/2XX](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mx-family), [PIC32MX 1XX/2XX XLP](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mx-family), [PIC32MX 1XX/2XX/5XX](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mx-family), [PIC32MX 3XX/4XX](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mx-family), [PIC32MX5XX/6XX/7XX](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mx-family), [PIC32MZ EF](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mz-ef-family), [PIC32MZ DA](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mz-da-family), [PIC32MK](https://www.microchip.com/design-centers/32-bit/pic-32-bit-mcus/pic32mk-family), PIC32MK GPH/GPG/MCJ, PIC32MK GPK/GPL/MCM, family of 32-bit microcontrollers.

- **Development kit and demo application support** - The following table provides number of demo application available for different development kits newly added in this release.

    | Development kits | Bootloader applications |
    | --- | --- |
    | PIC32MK GPL Curiosity Pro | 2 |
    | PIC32MK MCJ Curiosity Pro | 2 |
    | [PIC32MX1/2/5 Starter Kit](https://www.microchip.com/developmenttools/productdetails/dm320100) | 2 |
    | [Curiosity PIC32MX470 Development Board](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320103) | 2 |
    | [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto)](https://www.microchip.com/DevelopmentTools/ProductDetails/DM320010-C) | 2 |
    | [PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit](https://www.microchip.com/Developmenttools/ProductDetails/Dm320007) | 2 |
    | [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMC21-XPRO) | 2 |
    | [SAM D11 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/atsamd11-xpro) | 2 |
    | [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO) | 2 |
    | [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO) | 2 |
    | [SAM DA1 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/ATSAMDA1-XPRO) | 2 |
    | [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAME54-XPRO) | 4 |
    | [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 2 |
    | [SAM G55 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/atsamg55-xpro) | 2 |
    | [SAM L10 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320204) | 2 |
    | [SAM L21 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML21-XPRO-B) | 2 |
    | [SAM L22 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML22-XPRO-B) | 2 |

- Updated the Bootloader host scripts in bootloader/tools to be compatible with Python 3.x

- Moved the Bootloader host scripts compatible with Python 2.7.x to bootloader/tools_archive folder. These scripts may be removed in future.

### Known Issues

The current known issues are as follows:

* Configuration fuse macros are not generated for SAM D09/D10/D11 devices. 

* PIC32MK GPK/GPL/MCM will be supported in the next version of MPLAB X IDE release.

* SAME70 Bootloader application may not work on lower system frequency with high UART Baud-Rate.

* Interactive help using the Show User Manual Entry in the Right-click menu for configuration options provided by this module is not yet available from within the MPLAB Harmony Configurator (MHC).
  Please see the *Configuring the Library* section in the help documentation in the doc folder for this Harmony 3 module instead. Help is available in CHM format.

### Development Tools

* [MPLAB® X IDE v5.25](https://www.microchip.com/mplab/mplab-x-ide)
* [MPLAB® XC32 C/C++ Compiler v2.30](https://www.microchip.com/mplab/compilers)
* MPLAB® X IDE plug-ins:
  * MPLAB® Harmony Configurator (MHC) v3.3.0.1 and above.

## Bootloader Release v3.1.1

* Added MPLAB® Harmony License File

## Bootloader Release v3.1.0
### New Features

- **New part support** - This release introduces initial support of UART bootloader for [SAML10](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-l-mcus)
and [SAMG55](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-g-mcus) family of 32-bit microcontrollers.

- **Development kit and demo application support** - The following table provides number of demo application available for different development kits newly added in this release.

    | Development kits | Bootloader applications |
    | --- | --- |
    | [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMC21-XPRO) | 2 |
    | [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO) | 2 |
    | [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO) | 2 |
    | [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAME54-XPRO) | 4 |
    | [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 2 |
    | [SAM G55 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/atsamg55-xpro) | 2 |
    | [SAM L10 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails/dm320204) | 2 |
    | [SAM L21 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML21-XPRO-B) | 2 |
    | [SAM L22 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML22-XPRO-B) | 2 |

### Known Issues

The current known issues are as follows:

- SAME70 Bootloader application may not work on lower system frequency with high UART Baud-Rate.

### Development Tools

* [MPLAB® X IDE v5.20](https://www.microchip.com/mplab/mplab-x-ide)
* [MPLAB® XC32 C/C++ Compiler v2.20](https://www.microchip.com/mplab/compilers)
* MPLAB® X IDE plug-ins:
  * MPLAB® Harmony Configurator (MHC) v3.3.0.1 and above.

## Bootloader Release v3.0.0
### New Features

- **New part support** - This release introduces initial support for [SAM C20/C21](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-c-mcus), [SAM D20/D21](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-d-mcus), [SAM S70](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-s-mcus), [SAM E70](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-e-mcus), [SAM V70/V71](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-v-mcus), [SAME5x](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-e-mcus), [SAMD5x](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-d-mcus), [SAML21](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-l-mcus), [SAML22](https://www.microchip.com/design-centers/32-bit/sam-32-bit-mcus/sam-l-mcus) family of 32-bit microcontrollers.

- Added support for UART bootloader.

- **Development kit and demo application support** - The following table provides number of demo application available for different development kits newly added in this release.

    | Development kits | Bootloader applications |
    | --- | --- |
    | [SAM C21N Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMC21-XPRO) | 2 |
    | [SAM D20 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD20-XPRO) | 2 |
    | [SAM D21 Xplained Pro Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAMD21-XPRO) | 2 |
    | [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAME54-XPRO) | 4 |
    | [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 2 |
    | [SAM L21 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML21-XPRO-B) | 2 |
    | [SAM L22 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/ATSAML22-XPRO-B) | 2 |

### Known Issues

The current known issues are as follows:

- SAME70 Bootloader application may not work on lower system frequency with high UART Baud-Rate.

### Development Tools

* [MPLAB® X IDE v5.20](https://www.microchip.com/mplab/mplab-x-ide)
* [MPLAB® XC32 C/C++ Compiler v2.20](https://www.microchip.com/mplab/compilers)
* MPLAB® X IDE plug-ins:
  * MPLAB® Harmony Configurator (MHC) v3.3.0.1 and above.
