var myVariable = `
{"0": {
    "doc": "Appendix",
    "title": "Bootloader Appendix",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/docs/appendix.html#bootloader-appendix",
    "relUrl": "/templates/docs/appendix.html#bootloader-appendix"
  },"1": {
    "doc": "Appendix",
    "title": "Common sections",
    "content": "| Topic | Description | . | Bootloader Memory layout for CORTEX-M based MCUs | This section provides information on Bootloader Memory layout for CORTEX-M based MCUs | . | Bootloader Memory layout for MIPS based MCUs | This section provides information on Bootloader Memory layout for MIPS based MCUs | . | Bootloader Sizing And Considerations | This section provides information on bootloader size change considerations | . | Bootloader Trigger Methods | This section provides information on bootloader size change considerations | . | Configurations for CORTEX-M based MCUs | This section provides information on Bootloader and Application configurations for CORTEX-M based MCUs | . | Configurations for MIPS based MCUs | This section provides information on Bootloader and Application configurations for MIPS based MCUs | . | Debugging Bootloader And Application | This section provides information on how to debug the application along with bootloader | . | Debugging Bootloaders For CORTEX-M based MCUs | This section provides information on how to debug bootloaders running from SRAM | . | Tools Help | This section provides information on how to use different bootloader host tools | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/appendix.html#common-sections",
    "relUrl": "/templates/docs/appendix.html#common-sections"
  },"2": {
    "doc": "Appendix",
    "title": "UART Bootloader",
    "content": "| Topic | Description | . | UART Bootloader Firmware Update Execution Flow | This section provides information on Firmware Update Execution Flow for UART bootloader | . | UART Bootloader Protocol | This section provides information on protocol used by UART bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/appendix.html#uart-bootloader",
    "relUrl": "/templates/docs/appendix.html#uart-bootloader"
  },"3": {
    "doc": "Appendix",
    "title": "I2C Bootloader",
    "content": "| Topic | Description | . | I2C Bootloader Firmware Update Execution Flow | This section provides information on Firmware Update Execution Flow for I2C bootloader | . | I2C Bootloader Protocol | This section provides information on protocol used by I2C bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/appendix.html#i2c-bootloader",
    "relUrl": "/templates/docs/appendix.html#i2c-bootloader"
  },"4": {
    "doc": "Appendix",
    "title": "CAN Bootloader",
    "content": "| Topic | Description | . | CAN Bootloader Firmware Update Execution Flow | This section provides information on Firmware Update Execution Flow for CAN bootloader | . | CAN Bootloader Protocol | This section provides information on protocol used by CAN bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/appendix.html#can-bootloader",
    "relUrl": "/templates/docs/appendix.html#can-bootloader"
  },"5": {
    "doc": "Appendix",
    "title": "USB Device HID Bootloader",
    "content": "| Topic | Description | . | USB Device HID Bootloader Firmware Update Execution Flow | This section provides information on Firmware Update Execution Flow for USB Device HID bootloader | . | USB Device HID Bootloader Protocol | This section provides information on protocol used by USB Device HID bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/appendix.html#usb-device-hid-bootloader",
    "relUrl": "/templates/docs/appendix.html#usb-device-hid-bootloader"
  },"6": {
    "doc": "Appendix",
    "title": "UDP Bootloader",
    "content": "| Topic | Description | . | UDP Bootloader Firmware Update Execution Flow | This section provides information on Firmware Update Execution Flow for UDP bootloader | . | UDP Bootloader Protocol | This section provides information on protocol used by UDP bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/appendix.html#udp-bootloader",
    "relUrl": "/templates/docs/appendix.html#udp-bootloader"
  },"7": {
    "doc": "Appendix",
    "title": "File System Bootloader",
    "content": "| Topic | Description | . | File System Bootloader Firmware Update Execution Flow | This section provides information on Firmware Update Execution Flow for File System bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/appendix.html#file-system-bootloader",
    "relUrl": "/templates/docs/appendix.html#file-system-bootloader"
  },"8": {
    "doc": "Appendix",
    "title": "Appendix",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/docs/appendix.html",
    "relUrl": "/templates/docs/appendix.html"
  },"9": {
    "doc": "Application Project Configurations",
    "title": "Project configurations for the application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_application_project_config.html#project-configurations-for-the-application-to-be-bootloaded",
    "relUrl": "/templates/arm/docs/arm_application_project_config.html#project-configurations-for-the-application-to-be-bootloaded"
  },"10": {
    "doc": "Application Project Configurations",
    "title": "Application settings in MHC system configuration",
    "content": ". | Launch MHC for the application project to be configured | Select system component from the project graph and configure the below highlighted settings . | Disable Fuse Settings: . | Fuse settings needs to be disabled for the application which will be boot-loaded as the fuse settings are supposed to be programmed through programming tool from bootloader code. Also the fuse settings are not programmable through firmware . | Enabling the fuse settings also increases the size of the binary when generated through the hex file . | When updating the bootloader itself, make sure that the fuse settings for the bootloader application are also disabled . | . | Specify the Application Start Address: . | Specify the Start address from where the application will run under the Application Start Address (Hex) option in System block in MHC. | This value should be equal to or greater than the bootloader size and must be aligned to the erase unit size on that device. | As this value will be used by bootloader to Jump to application at device reset it should match the value provided to bootloader code . | The Application Start Address (Hex) will be used to generate XC32 compiler settings to place the code at intended address . | After the project is regenerated, the ROM_ORIGIN and ROM_LENGTH are the XC32 linker variables which will be overridden with value provided for Application Start Address (Hex) and can be verified under Options for xc32-ld in Project Properties in MPLABX IDE as shown below. | . | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_application_project_config.html#application-settings-in-mhc-system-configuration",
    "relUrl": "/templates/arm/docs/arm_application_project_config.html#application-settings-in-mhc-system-configuration"
  },"11": {
    "doc": "Application Project Configurations",
    "title": "MPLAB X Settings",
    "content": "For Bootloading the application using binary file . | Below are the Bootloaders which use application binary (.bin) file as input . | UART | I2C | CAN | Serial Memory | File System | . | Specifying post build option to automatically generate the binary file from hex file once the build is complete . \${MP_CC_DIR}/xc32-objcopy -I ihex -O binary \${DISTDIR}/\${PROJECTNAME}.\${IMAGE_TYPE}.hex \${DISTDIR}/\${PROJECTNAME}.\${IMAGE_TYPE}.bin . | . For Bootloading the application using Normalized Hex file . | Below are the Bootloaders which use Normalized application Hex (.hex) file as input . | USB Device HID | UDP | . | Check the Normalize hex file option as shown below, as the Unified bootloader host application takes hex file as an input. Normalizing the hex file will make sure the data in the hex file is arranged sequentially . | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_application_project_config.html#mplab-x-settings",
    "relUrl": "/templates/arm/docs/arm_application_project_config.html#mplab-x-settings"
  },"12": {
    "doc": "Application Project Configurations",
    "title": "Additional settings (Optional)",
    "content": ". | RAM_ORIGIN and RAM_LENGTH values should be provided for reserving configured bytes from start of RAM to trigger bootloader from firmware . | Under Project Properties, expand options for xc32-ld and define the values for RAM_ORIGIN and RAM_LENGTH under Additional options . | This is optional and can be ignored if not required . | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_application_project_config.html#additional-settings-optional",
    "relUrl": "/templates/arm/docs/arm_application_project_config.html#additional-settings-optional"
  },"13": {
    "doc": "Application Project Configurations",
    "title": "Application Project Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_application_project_config.html",
    "relUrl": "/templates/arm/docs/arm_application_project_config.html"
  },"14": {
    "doc": "Debugging Bootloaders For CORTEX-M based MCUs",
    "title": "Debugging UART, I2C and CAN Bootloaders for CORTEX-M based MCUs",
    "content": "The UART, I2C and CAN bootloaders for CORTEX-M based MCU’s are designed to run from SRAM to support . | Simultaneous Flash memory write and reception of the next block of data . | Self update . | For debugging these bootloaders make use of software breakpoints instead of Hardware breakpoints . | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_debugging.html#debugging-uart-i2c-and-can-bootloaders-for-cortex-m-based-mcus",
    "relUrl": "/templates/arm/docs/arm_bootloader_debugging.html#debugging-uart-i2c-and-can-bootloaders-for-cortex-m-based-mcus"
  },"15": {
    "doc": "Debugging Bootloaders For CORTEX-M based MCUs",
    "title": "Steps to enable software breakpoints and start debugging",
    "content": ". | Enable software breakpoint from the project configuration dashboard by clicking on the button as shown below . | Software breakpoints inside main() when running from SRAM do not work when set before starting the debugger. | For them to work first set a Breakpoint in startup_xc32.c file as it is running from flash | . | Start the debugger from MPLAB IDE and the software break point in startup file will be hit . | Once the breakpoint is hit in startup file, then set breakpoints anywhere you want, like in main() function as shown below . | Resume the debugger and you should be able to now debug as usual . | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_debugging.html#steps-to-enable-software-breakpoints-and-start-debugging",
    "relUrl": "/templates/arm/docs/arm_bootloader_debugging.html#steps-to-enable-software-breakpoints-and-start-debugging"
  },"16": {
    "doc": "Debugging Bootloaders For CORTEX-M based MCUs",
    "title": "Additional Information",
    "content": ". | Refer to Debugging Bootloader And Application for debugging the application to be bootloaded along with bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_debugging.html#additional-information",
    "relUrl": "/templates/arm/docs/arm_bootloader_debugging.html#additional-information"
  },"17": {
    "doc": "Debugging Bootloaders For CORTEX-M based MCUs",
    "title": "Debugging Bootloaders For CORTEX-M based MCUs",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_debugging.html",
    "relUrl": "/templates/arm/docs/arm_bootloader_debugging.html"
  },"18": {
    "doc": "Bootloader Linker Configurations",
    "title": "Linker configurations for the UART, I2C and CAN Bootloaders",
    "content": ". | Bootloader library uses a custom linker script which is generated through MHC . | The values populated in the linker script are based on the Bootloader component MHC configurations . | Bootloader is configured to run from RAM in this linker script to achieve simultaneous Flash memory write and reception of the next block of data. | Note: The below sections provides overview of changes done to bootloader linker scripts when compared to default linker script. The &lt;bootloader_start&gt; address and &lt;bootloader_length&gt; may vary based on the specific device used . | . #define ROM_START &lt;bootloader_start&gt; /* Bootloader size is calculated with below criteria with optimization level -O2 * bootloader size = Minimum Flash Erase Size Or actual bootloader ELF size (Rounded of to nearest erase boundary) whichever is greater. */ #define ROM_SIZE &lt;bootloader_length&gt; /* Bootloader Trigger pattern needs to be stored in starting &lt;trigger_len&gt; Bytes * of Ram by the application if it wants to run bootloader at startup without any * external trigger. * Example: * ram[0] = 0x5048434D; * ram[1] = 0x5048434D; * .... * ram[n] = 0x5048434D; */ #define RAM_START (&lt;ram_start&gt; + &lt;trigger_len&gt;) #define RAM_SIZE (&lt;ram_length&gt; - trigger_len) MEMORY { rom (rx) : ORIGIN = ROM_START, LENGTH = ROM_SIZE ram (rwx) : ORIGIN = RAM_START, LENGTH = RAM_SIZE } SECTIONS { /* * Configure to place the vector table in Flash but to be run from RAM */ .vectors : { . = ALIGN(4); _sfixed = .; KEEP(*(.vectors .vectors.*)) } &gt; ram AT &gt; rom .text : { . = ALIGN(4); ....... = ALIGN(4); _efixed = .; /* End of text section */ } &gt; rom ....... = ALIGN(4); _etext = .; /* Locate text/rodata in special data section to be copied to RAM in startup sequence. */ .data : { . = ALIGN(4); __data_start__ = .; _sdata = .; *(.dinit) *(.text) *(.text.*) *(.rodata) *(.rodata.*) . = ALIGN(4); __data_end__ = .; _edata = .; } &gt; ram AT &gt; rom .... } . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_linker_config.html#linker-configurations-for-the-uart-i2c-and-can-bootloaders",
    "relUrl": "/templates/arm/docs/arm_bootloader_linker_config.html#linker-configurations-for-the-uart-i2c-and-can-bootloaders"
  },"19": {
    "doc": "Bootloader Linker Configurations",
    "title": "Custom startup file for UART, I2C and CAN Bootloaders",
    "content": ". | To reduce the size of the binary these bootloaders make use of custom startup file which is generated by MHC . | This startup file places only the Reset handler in vector table instead of populating all the device vectors there by reducing the size of final .vector section . | This startup file also copies the entire bootloader code placed in .data section above from flash to RAM as it is built to run from RAM . | . /* Declaration of Reset handler (may be custom) */ void __attribute__((noinline)) Reset_Handler(void); __attribute__ ((used, section(\\\".vectors\\\"))) void (* const vectors[])(void) = { &amp;_ram_end_, Reset_Handler, }; ..... /* Linker-defined symbols for data initialization. */ extern uint32_t _sdata, _edata, _etext; extern uint32_t _sbss, _ebss; void __attribute__((noinline, section(\\\".romfunc.Reset_Handler\\\"))) Reset_Handler(void) { uint32_t *pSrc, *pDst;; pSrc = (uint32_t *) &amp;_etext; /* flash functions start after .text */ pDst = (uint32_t *) &amp;_sdata; /* boundaries of .data area to init */ /* Copy code from flash to RAM using .data section */ while (pDst &lt; &amp;_edata) *pDst++ = *pSrc++; /* Init .bss */ pDst = &amp;_sbss; while (pDst &lt; &amp;_ebss) *pDst++ = 0; ....... } . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_linker_config.html#custom-startup-file-for-uart-i2c-and-can-bootloaders",
    "relUrl": "/templates/arm/docs/arm_bootloader_linker_config.html#custom-startup-file-for-uart-i2c-and-can-bootloaders"
  },"20": {
    "doc": "Bootloader Linker Configurations",
    "title": "MPLAB X Setting for UART, I2C and CAN Bootloaders",
    "content": ". | Below MPLAB X option is enabled by MHC for these bootloaders to remove the XC32 crt0 startup code . | By disabling this crt0 startup code we further reduce the size as it removes the default initialization mechanism code by XC32. | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_linker_config.html#mplab-x-setting-for-uart-i2c-and-can-bootloaders",
    "relUrl": "/templates/arm/docs/arm_bootloader_linker_config.html#mplab-x-setting-for-uart-i2c-and-can-bootloaders"
  },"21": {
    "doc": "Bootloader Linker Configurations",
    "title": "Bootloader Linker Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_linker_config.html",
    "relUrl": "/templates/arm/docs/arm_bootloader_linker_config.html"
  },"22": {
    "doc": "Bootloader Memory Layout For CORTEX-M Based MCUs",
    "title": "Bootloader Memory layout for CORTEX-M based MCUs",
    "content": ". | Basic Memory Layout . | Fail Safe Update Memory Layout . | Live Update Memory Layout . | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_memory_layout.html#bootloader-memory-layout-for-cortex-m-based-mcus",
    "relUrl": "/templates/arm/docs/arm_bootloader_memory_layout.html#bootloader-memory-layout-for-cortex-m-based-mcus"
  },"23": {
    "doc": "Bootloader Memory Layout For CORTEX-M Based MCUs",
    "title": "Bootloader Memory Layout For CORTEX-M Based MCUs",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_memory_layout.html",
    "relUrl": "/templates/arm/docs/arm_bootloader_memory_layout.html"
  },"24": {
    "doc": "Basic Memory layout",
    "title": "Basic Memory layout for CORTEX-M based MCUs",
    "content": "The placement of the Bootloader and the application in flash memory should be such that the application will not overwrite the Bootloader, and the Bootloader can properly program the application when it is downloaded. | Bootloader code is always placed at start of the flash address . | The application code can be placed anywhere after the bootloader end address. The application start address should be aligned to Erase Unit Size of the device . | As the Bootloader code requires the application start address to be mentioned at compile time, it should match in both the application and bootloader . | . Note: . The start address and the end address of the Bootloader and the application will vary for different devices. Refer to respective Data sheets for details of Flash memory layout. ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_memory_layout_basic.html#basic-memory-layout-for-cortex-m-based-mcus",
    "relUrl": "/templates/arm/docs/arm_bootloader_memory_layout_basic.html#basic-memory-layout-for-cortex-m-based-mcus"
  },"25": {
    "doc": "Basic Memory layout",
    "title": "Additional Information",
    "content": ". | Refer to Configurations for CORTEX-M based MCUs for more information on Bootloader linker and application configurations | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_memory_layout_basic.html#additional-information",
    "relUrl": "/templates/arm/docs/arm_bootloader_memory_layout_basic.html#additional-information"
  },"26": {
    "doc": "Basic Memory layout",
    "title": "Basic Memory layout",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_memory_layout_basic.html",
    "relUrl": "/templates/arm/docs/arm_bootloader_memory_layout_basic.html"
  },"27": {
    "doc": "Fail Safe Update Memory layout",
    "title": "Fail Safe Update Memory layout for CORTEX-M based MCUs",
    "content": ". | Supported for the devices which have a Dual Bank flash memory . | Internal Flash memory is split into two equal banks. Special NVM Fuse setting (AFIRST) is used to identify which bank is mapped to NVM main address space after reset. | Start address of Active Bank is always start of Internal Flash memory . | Start address of Inactive Bank is from mid of the Internal flash memory which can vary from device to device. Refer to respective Data sheets for details of Flash memory layout. | . | Bootloader must be placed at start location of both banks . | The application code can be placed anywhere after the bootloader end address till mid of flash. The application start address should be aligned to Erase Unit Size of the device . | As the Bootloader code requires the application start address to be mentioned at compile time, it should match in both the application and bootloader . | Bootloader running from Active bank will program the new image in inactive bank . | Bootloader is responsible to perform a bank swap and reset to run the new firmware programmed in Inactive bank . | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_memory_layout_fail_safe_update.html#fail-safe-update-memory-layout-for-cortex-m-based-mcus",
    "relUrl": "/templates/arm/docs/arm_bootloader_memory_layout_fail_safe_update.html#fail-safe-update-memory-layout-for-cortex-m-based-mcus"
  },"28": {
    "doc": "Fail Safe Update Memory layout",
    "title": "Additional Information",
    "content": ". | Refer to Configurations for CORTEX-M based MCUs for more information on Bootloader linker and application configurations | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_memory_layout_fail_safe_update.html#additional-information",
    "relUrl": "/templates/arm/docs/arm_bootloader_memory_layout_fail_safe_update.html#additional-information"
  },"29": {
    "doc": "Fail Safe Update Memory layout",
    "title": "Fail Safe Update Memory layout",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_memory_layout_fail_safe_update.html",
    "relUrl": "/templates/arm/docs/arm_bootloader_memory_layout_fail_safe_update.html"
  },"30": {
    "doc": "Live Update Memory layout",
    "title": "Live Update Memory layout for CORTEX-M based MCUs",
    "content": ". | Supported for the devices which have a Dual Bank flash memory . | Internal Flash memory is split into two equal banks. Special NVM Fuse setting (AFIRST) is used to identify which bank is mapped to NVM main address space after reset. | Start address of Active Bank is always start of Internal Flash memory . | Start address of Inactive Bank is from mid of the Internal flash memory which can vary from device to device. Refer to respective Data sheets for details of Flash memory layout. | . | The bootloader live update code responsible to program the inactive bank is part of the application it self. Which means the programming operation can happen while the application is running . | Live Update Application = (Bootloader Code in Live Update mode + Application code) . | Having the bootloader as part of application itself avoids the overhead of memory partitioning and saves flash memory. | . | The application code is responsible to send a request to bootloader live update code to perform a bank swap and reset to run the new firmware programmed in Inactive bank . | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_memory_layout_live_update.html#live-update-memory-layout-for-cortex-m-based-mcus",
    "relUrl": "/templates/arm/docs/arm_bootloader_memory_layout_live_update.html#live-update-memory-layout-for-cortex-m-based-mcus"
  },"31": {
    "doc": "Live Update Memory layout",
    "title": "Live Update Memory layout",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_bootloader_memory_layout_live_update.html",
    "relUrl": "/templates/arm/docs/arm_bootloader_memory_layout_live_update.html"
  },"32": {
    "doc": "Configurations for CORTEX-M based MCUs",
    "title": "Configurations for CORTEX-M based MCUs",
    "content": ". | Bootloader Linker Script Configurations . | Application project Configurations . | . ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_configurations.html#configurations-for-cortex-m-based-mcus",
    "relUrl": "/templates/arm/docs/arm_configurations.html#configurations-for-cortex-m-based-mcus"
  },"33": {
    "doc": "Configurations for CORTEX-M based MCUs",
    "title": "Configurations for CORTEX-M based MCUs",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/arm/docs/arm_configurations.html",
    "relUrl": "/templates/arm/docs/arm_configurations.html"
  },"34": {
    "doc": "Bootloader Sizing And Considerations",
    "title": "Bootloader Sizing And Considerations",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/docs/bootloader_sizing_and_considerations.html#bootloader-sizing-and-considerations",
    "relUrl": "/templates/docs/bootloader_sizing_and_considerations.html#bootloader-sizing-and-considerations"
  },"35": {
    "doc": "Bootloader Sizing And Considerations",
    "title": "Bootloader Sizes",
    "content": ". | The example Bootloaders provided have XC32 optimization settings to -O2 . | However, in terms of size, this option does not produce the most optimal code. Turning on the -Os will reduce the size of the Bootloader. | Note: By default the bootloader size will be rounded off to the nearest erase unit size of the device . | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/bootloader_sizing_and_considerations.html#bootloader-sizes",
    "relUrl": "/templates/docs/bootloader_sizing_and_considerations.html#bootloader-sizes"
  },"36": {
    "doc": "Bootloader Sizing And Considerations",
    "title": "Size change considerations",
    "content": ". | It must be ensured that the user applications memory region does not overlap with the memory region reserved for the Bootloader. | The Bootloader generated by MHC should be considered a starting point for your products Bootloader. As such, adding new features may cause the Bootloader to exceed the default size calculated . | If the size of the Bootloader changes, the following steps should be performed to adjust both the Bootloader and the application in order to make sure that both fit and make best use of the device memory . | Increase the Bootloader Size in Bootloader MHC config menu to some approximate value and regenerate the code . | Determine the new ending address of the Bootloader. This can be done by using either the .map file generated by MPLAB X IDE with the respective Compiler, or by using the ELFViewer plug-in for MPLAB X IDE . | Round the size from the map file to the nearest ERASE unit size value . | Enter the new value again in Bootloader Size in Bootloader MHC config menu . | Change the Application start Address from system settings in both Bootloader and application projects accordingly if it is falling inside bootloader region . | Recompile both the Bootloader and the application . | . | If only the Application start address needs to be modified for application then perform following steps: . | Change the Application start Address from system settings in both Bootloader and application projects accordingly . | Recompile both the Bootloader and the application . | . | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/bootloader_sizing_and_considerations.html#size-change-considerations",
    "relUrl": "/templates/docs/bootloader_sizing_and_considerations.html#size-change-considerations"
  },"37": {
    "doc": "Bootloader Sizing And Considerations",
    "title": "Bootloader Sizing And Considerations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/docs/bootloader_sizing_and_considerations.html",
    "relUrl": "/templates/docs/bootloader_sizing_and_considerations.html"
  },"38": {
    "doc": "Bootloader Trigger Methods",
    "title": "Bootloader Trigger Methods",
    "content": "Bootloader can be invoked in number of ways: . | Bootloader will run automatically if there is no valid application firmware. | Firmware is considered valid if the first word at application start address is not 0xFFFFFFFF . | Normally this word contains initial stack pointer value, so it will never be 0xFFFFFFFF unless device is erased. | . | Bootloader application can implement the bootloader_Trigger() function which will be called during system initialization . | A GPIO pin can be used as an external trigger to invoke bootloader at startup. | Bootloader can run on application (internal) request if the configured number of bytes from start of SRAM are equal to some trigger pattern. | . | . Example Implementation of bootloader_Trigger() . #define BTL_TRIGGER_PATTERN 0x5048434D static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START; bool bootloader_Trigger(void) { /* Check for Bootloader Trigger Pattern in first 16 Bytes of RAM to enter * Bootloader. */ if (BTL_TRIGGER_PATTERN == ramStart[0] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[1] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[2] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[3]) { ramStart[0] = 0; return true; } /* Check for Switch press to enter Bootloader */ if (SWITCH_Get() == 0) { return true; } return false; } . Application code to trigger bootloader . void invoke_bootloader(void) { uint32_t *sram = (uint32_t *)BTL_TRIGGER_RAM_START; sram[0] = 0x5048434D; sram[1] = 0x5048434D; sram[2] = 0x5048434D; sram[3] = 0x5048434D; NVIC_SystemReset(); } . ",
    "url": "http://localhost:4000/bootloader/templates/docs/bootloader_trigger_methods.html#bootloader-trigger-methods",
    "relUrl": "/templates/docs/bootloader_trigger_methods.html#bootloader-trigger-methods"
  },"39": {
    "doc": "Bootloader Trigger Methods",
    "title": "Bootloader Trigger Methods",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/docs/bootloader_trigger_methods.html",
    "relUrl": "/templates/docs/bootloader_trigger_methods.html"
  },"40": {
    "doc": "Application Configurations",
    "title": "Configurations for the application to be bootloaded",
    "content": ". | Refer to Application project Configurations for information on how to configure an application to be bootloaded for CORTEX-M based MCus | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_application_configurations.html#configurations-for-the-application-to-be-bootloaded",
    "relUrl": "/templates/src/optimized/docs/can/can_application_configurations.html#configurations-for-the-application-to-be-bootloaded"
  },"41": {
    "doc": "Application Configurations",
    "title": "Application Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_application_configurations.html",
    "relUrl": "/templates/src/optimized/docs/can/can_application_configurations.html"
  },"42": {
    "doc": "Bootloader Configurations",
    "title": "CAN Bootloader Configurations",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_configurations.html#can-bootloader-configurations",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_configurations.html#can-bootloader-configurations"
  },"43": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Specific User Configurations",
    "content": "For devices with Dual Bank support and No Data Cache . For devices with No Dual Bank support and Data Cache . | Bootloader Peripheral Used: . | Specifies the communication peripheral used by bootloader to receive the application | The name of the peripheral will vary from device to device | . | Bootloader NVM Memory Used: . | Specifies the memory peripheral used by bootloader to perform flash operations | The name of the peripheral will vary from device to device | . | Bootloader Size (Bytes): . | Specifies the maximum size of flash required by the bootloader | This size is calculated based on Bootloader type and Memory used | This size will vary from device to device and should always be aligned to device erase unit size | . | Enable Bootloader Trigger From Firmware: . | This Option can be used to Force Trigger bootloader from application firmware after a soft reset. It does so by reserving the specified number of bytes in SRAM from the start of the RAM. The reserved memory is updated by the application with a pre-defined pattern. The bootloader firmware in the bootloader_Trigger() routine, can check the reserved memory for the pre-defined pattern and enter bootloader mode if the pattern matches. | Number Of Bytes To Reserve From Start Of RAM: . | This option adds the provided offset to RAM Start address in bootloader linker script. | Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader to check at reset in bootloader_Trigger() function | . | . | Use Dual Bank For Safe Flash Update: . | Used to configure bootloader to use Dual banks of device to upload the application | This option is visible only for devices supporting Dual flash banks | . | Select MPU Region to configure non-cacheable memory: . | Used to select the MPU region for which he SRAM has been configured as non-cahceable space . | Configure the region selected above in MPU settings of MHC as shown in Bootloader MPU Configurations . | A seperate section will be created for this region in the custom linker script generated for bootloader . | This option is visible only for devices which have Data cache. | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_configurations.html#bootloader-specific-user-configurations",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_configurations.html#bootloader-specific-user-configurations"
  },"44": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader MPU Configurations",
    "content": ". | Open MPU settings from MHC-&gt;Tools option. Select Enable MPU . | Configure the region selected in Bootloader component as ram_nocache with other parameters as shown . | . Bootloader Linker code for ram_nochache . | For CAN bootloader below xxx_message_ram section will be added to the custom linker file generated . | Note: xxx should be replaced with the CAN PLIB being used. | Example: MCAN1 | . | . MEMORY { rom (rx) : ORIGIN = ROM_START, LENGTH = ROM_SIZE ram (rwx) : ORIGIN = RAM_START, LENGTH = RAM_SIZE /* The address mentioned here should match with address mentioned in MPU settings */ ram_nocache (RWX) : ORIGIN = 0x2045f000, LENGTH = (1 &lt;&lt; (11 + 1)) } .....mcan1_message_ram (NOLOAD): { . = ALIGN(4); _s_mcan1_message_ram = .; *(.mcan1_message_ram) . = ALIGN(4); _e_mcan1_message_ram = .; } &gt; ram_nocache ... | CAN Bootloader will use this section to to allocate MCAN Message RAM configuration in contiguous non-cacheable buffer | . static uint8_t CACHE_ALIGN __attribute__((space(data), section (\\\".mcan1_message_ram\\\"))) mcan1MessageRAM[MCAN1_MESSAGE_RAM_CONFIG_SIZE]; /* Set MCAN1 Message RAM Configuration */ MCAN1_MessageRAMConfigSet(mcan1MessageRAM); . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_configurations.html#bootloader-mpu-configurations",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_configurations.html#bootloader-mpu-configurations"
  },"45": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader System Configurations",
    "content": ". | Application Start Address (Hex): . | Start address of the application which will programmed by bootloader | This value is filled by bootloader when its loaded which is equal to the bootloader size. It can be modified as per user need | This value will be used by bootloader to Jump to application at device reset | . | . Note . | For optimizing the code Bootloader component disables generation of default interrupt and exception files as shown below . | Enabling these interrupts explicitly may still not work as bootloader uses custom startup file which has its own Interrupt table populating only the reset handler . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_configurations.html#bootloader-system-configurations",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_configurations.html#bootloader-system-configurations"
  },"46": {
    "doc": "Bootloader Configurations",
    "title": "Additional Information",
    "content": ". | Refer to CORTEX-M Bootloader Linker Script Configurations for information on bootloader linker script generated by MHC for CORTEX-M based MCUs . | For CAN Bootloader the linker script generated in above section will have additional sections as described in Bootloader Linker code for ram_nochache | . | Refer to Bootloader Sizing And Considerations for information on bootloader size change considerations | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_configurations.html#additional-information",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_configurations.html#additional-information"
  },"47": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_configurations.html",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_configurations.html"
  },"48": {
    "doc": "CAN Bootloader Firmware Update Execution Flow",
    "title": "CAN Bootloader Firmware Update mode execution flow",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html#can-bootloader-firmware-update-mode-execution-flow",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html#can-bootloader-firmware-update-mode-execution-flow"
  },"49": {
    "doc": "CAN Bootloader Firmware Update Execution Flow",
    "title": "Bootloader Task Flow",
    "content": ". | Bootloader task is the main task which calls the Input sub-tasks in a forever loop. | It calls the Input task to poll for command packets from host . | Once complete packet is received Input Task calls Command task to process the received command . | If the command received was a data command Command task calls Flash Task to flash the application . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html#bootloader-task-flow",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html#bootloader-task-flow"
  },"50": {
    "doc": "CAN Bootloader Firmware Update Execution Flow",
    "title": "Input Task Flow",
    "content": ". | This task is used to receive the data bytes from embedded host . | The task keeps polling for data to be received when bootloader is in idle mode . | Once the packet reception is completed it gives control to Command Task . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html#input-task-flow",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html#input-task-flow"
  },"51": {
    "doc": "CAN Bootloader Firmware Update Execution Flow",
    "title": "Command Task Flow",
    "content": ". | The task first validates the incoming packet from host with expected header information . | The task processes the commands received from Input Task and provides response back to host accordingly . | If the command received is a Data command it gives control to the Flash Task . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html#command-task-flow",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html#command-task-flow"
  },"52": {
    "doc": "CAN Bootloader Firmware Update Execution Flow",
    "title": "Flash Task Flow",
    "content": ". | This task is responsible to program the internal flash memory with data packet received . | The task uses the NVM peripheral library to perform the Unlock/Erase/Write Operations . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html#flash-task-flow",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html#flash-task-flow"
  },"53": {
    "doc": "CAN Bootloader Firmware Update Execution Flow",
    "title": "CAN Bootloader Firmware Update Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_firmware_update_execution_flow.html"
  },"54": {
    "doc": "How The Library Works",
    "title": "How the CAN Bootloader library works",
    "content": "The CAN Bootloader firmware communicates with the embedded host device by using a predefined communication protocol. The CAN Bootloader works in two different modes . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_how_library_works.html#how-the-can-bootloader-library-works",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_how_library_works.html#how-the-can-bootloader-library-works"
  },"55": {
    "doc": "How The Library Works",
    "title": "Basic Mode",
    "content": ". | This mode is supported for all the devices . | Resides from . | The starting location of the flash memory region for CORTEX-M based MCUs | . | The Bootloader performs flash erase/program/verify operations with the binary sent from host while in the firmware upgrade mode . | The binary sent is only of the application to be programmed | Bootloader always performs flash operation from the address for (bootloader or application) binary sent from host | The application can use the entire flash memory region starting from the end of bootloader space | . | Jumps to the application once verification is completed | . Memory layout . | Basic memory layout for CORTEX-M based MCUs | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_how_library_works.html#basic-mode",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_how_library_works.html#basic-mode"
  },"56": {
    "doc": "How The Library Works",
    "title": "Fail Safe Update Mode",
    "content": ". | This mode is supported for the devices which have a Dual Bank flash memory . | Resides from the starting location of the flash memory region of both the banks on CORTEX-M based MCUs . | The Bootloader performs flash erase/program/verify operations with the binary sent from host while in the firmware upgrade mode . | Bootloader can perform flash operation in either of the banks based on the address sent by the host application . | The application can use only the flash memory region of one bank. | . | Performs a bank swap and reset to run the application programmed in inactive bank once verification is completed or a normal reset to run the application in current bank based on command sent from host | . Memory layout . | Fail Safe Update memory layout for CORTEX-M based MCUs | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_how_library_works.html#fail-safe-update-mode",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_how_library_works.html#fail-safe-update-mode"
  },"57": {
    "doc": "How The Library Works",
    "title": "Additional Information",
    "content": ". | For information on protocol used refer to CAN Bootloader Protocol | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_how_library_works.html#additional-information",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_how_library_works.html#additional-information"
  },"58": {
    "doc": "How The Library Works",
    "title": "How The Library Works",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_how_library_works.html",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_how_library_works.html"
  },"59": {
    "doc": "Library Interface",
    "title": "CAN Bootloader Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_library_interface.html#can-bootloader-library-interface",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_library_interface.html#can-bootloader-library-interface"
  },"60": {
    "doc": "Library Interface",
    "title": "Table of contents",
    "content": ". | System functions . | bootloader_Tasks | bootloader_Trigger | run_Application | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_library_interface.html#table-of-contents",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_library_interface.html#table-of-contents"
  },"61": {
    "doc": "Library Interface",
    "title": "System functions",
    "content": "bootloader_Tasks . void bootloader_Tasks(void) . Summary . Starts bootloader execution. Description . This function can be used to start bootloader execution. The function continuously waits for application firmware from the host device via CAN and perfroms Erase/Program/Verify operations on internal flash memory . Once the complete application is received, programmed and verified successfully, it resets the device to jump into programmed application. | Note: As this function runs a infinite loop it never returns | . Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . bootloader_Tasks(); . bootloader_Trigger . bool bootloader_Trigger(void); . Summary . Checks if Bootloader has to be executed at startup. Description . This function can be used to check for a External HW trigger or Internal firmware trigger to execute bootloader at startup. This function has to be implemented by the bootloader application to override the WEAK implementation in bootloader.c . The checks in trigger function should happen before any system resources are initialized apart for PORT, As the same system resource can be Re-initialized by the application if bootloader jumps to it and may cause issues. | External Trigger: . | Can be achieved by triggering a GPIO_PIN at startup. | . | Firmware Trigger: . | Application firmware which wants to execute bootloader at startup needs to fill first n bytes of ram location with a request pattern. The Number of bytes to be reserved for storing the pattern has to be configured in bootloader component configuration in MHC. | . | . uint32_t *sram = (uint32_t *)BTL_TRIGGER_RAM_START; sram[0] = 0x5048434D; sram[1] = 0x5048434D; sram[2] = 0x5048434D; sram[3] = 0x5048434D; . Precondition . PORT/PIO Initialize must have been called. Parameters . None . Returns . | True : If any of trigger is detected. | False : If no trigger is detected.. | . Example . #define BTL_TRIGGER_PATTERN 0x5048434D static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START; bool bootloader_Trigger(void) { // Check for Bootloader Trigger Pattern in first 16 Bytes of RAM to enter Bootloader. if (BTL_TRIGGER_PATTERN == ramStart[0] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[1] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[2] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[3]) { ramStart[0] = 0; return true; } // Check for Switch press to enter Bootloader if (SWITCH_Get() == 0) { return true; } return false; } void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . run_Application . void run_Application(void); . Summary . Runs the programmed application at startup. Description . This function can be used to run programmed application though bootloader at startup. If the first 4Bytes of Application Memory is not 0xFFFFFFFF then it jumps to the application start address to run the application programmed through bootloader and never returns. If the first 4Bytes of Application Memory is 0xFFFFFFFF then it returns from function and executes bootloader for accepting a new application firmware. Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_library_interface.html#system-functions",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_library_interface.html#system-functions"
  },"62": {
    "doc": "Library Interface",
    "title": "Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_library_interface.html",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_library_interface.html"
  },"63": {
    "doc": "CAN Bootloader Protocol",
    "title": "CAN Bootloader Protocol",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_protocol.html#can-bootloader-protocol",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_protocol.html#can-bootloader-protocol"
  },"64": {
    "doc": "CAN Bootloader Protocol",
    "title": "Request Packet",
    "content": "The can bootloader protocol as shown in below figure is common for all the supported commands. Command . | Indicates the command to be processed. Each command is of 1 Byte width . | Below are the supported commands . | . | Command Type | Command Code | Description | . | Unlock | 0xA0 | Used to calculate application start address and end address | . | Data | 0xA1 | Used to send the image data | . | Verify | 0xA2 | Used to verify the image data sent and programmed | . | Reset | 0xA3 | Used to trigger a reset to run the application | . | Bank Swap and reset | 0xA4 | Used to Swap the bank and trigger a reset to run the application | . Sequence Number . | Indicates the packet sequence number. | For data command the sequence number has to be incremented by 1 for every data packet. Bootloader checks the sequence number once data packet is recieved. If there is a mismatch it sends a sequence error response . | As the sequence number is of 1 Byte width, once it reaches to a value of 255 it restarts from zero . | . GUARD . | The Guard value must be a constant value of 0xE2 . | This value provides protection against spurious commands . | Bootloader always checks for the Guard value on packet reception and proceeds further accordingly . | . Data Size . | This field indicates the number of data bytes to be received . | This value varies for different commands . | . Data . | Contains the actual Data to be processed based on the command . | Length of the data to be received is indicated by Data Size field . | All data words must be sent in a little-endian (LSB first) format . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_protocol.html#request-packet",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_protocol.html#request-packet"
  },"65": {
    "doc": "CAN Bootloader Protocol",
    "title": "Response Codes",
    "content": "Bootloader will send a single character response code in response to each command. Sequential commands can only be sent after the response code is received for a previous command, or after 100 ms timeout without a response. | Response Type | Response Code | Description | . | OK | 0x50 | Command was received and processed successfully | . | Error | 0x51 | There were errors during the processing of the command | . | Invalid | 0x52 | Invalid command is received | . | CRC OK | 0x53 | CRC verification was successful | . | CRC Fail | 0x54 | CRC verification failed | . | SEQ ERROR | 0x55 | Sequence number mismatch for Data command | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_protocol.html#response-codes",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_protocol.html#response-codes"
  },"66": {
    "doc": "CAN Bootloader Protocol",
    "title": "Command Description",
    "content": "Unlock Command . The Unlock Command sequence is as shown in below figure with corresponding responses. | Unlock command must be issued before the first Data command . | It is used to calculate application start address and end address . | This information will be used to validate if the addresses sent are within the range of flash memory . | . | Number of bytes of data to be received is 8 Bytes (Start Address + Image Size) . | Start Address . | It is the application Start Address of the flash memory | It is device dependent and should be always greater than or equal to the bootloader end address | It must be aligned at an Erase Unit Size boundary, which is also device dependent | To upgrade the bootloader itself this value must be set to 0 (For CORTEX-M based MCUs) | . | Image size must be in increments of Erase Unit bytes which is also device dependent | . Data Command . The Data Command sequence is as shown in below figure with corresponding responses. | Data command is used to send the image data . | The maximum packet length received by CAN bootloader is 64Bytes. The Data size &lt;= 60Bytes as we have 4 bytes reserved for packet header . | . Verify Command . The Verify Command sequence is as shown in below figure with corresponding responses. | Verify command is used to verify the image data sent and programmed . | Image CRC is a standard IEEE CRC32 with a polynomial of 0xEDB88320 . | Internal CRC is calculated based on the values actually read from the Flash memory after programming, so it verifies the whole chain. | Image CRC is calculated over the previously unlocked region. | . Reset Command . The Reset Command sequence is as shown in below figure with corresponding responses. | Reset command is used to exit the bootloader and run the application . | It is necessary if the host has no control over the reset pin. It can also be useful even if host has control over the Reset . | . Bank Swap and Reset Command . The Bank Swap and Reset Command sequence is as shown in below figure with corresponding responses . | This command is enabled only when Fail safe update feature is selected for bootloader and the device has support for Dual Bank update . | Bank Swap and Reset command is used to Swap the inactive bank to active bank and trigger a reset to exit the bootloader and run the new application programmed in the inactive bank . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_protocol.html#command-description",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_protocol.html#command-description"
  },"67": {
    "doc": "CAN Bootloader Protocol",
    "title": "CAN Bootloader Protocol",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_protocol.html",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_protocol.html"
  },"68": {
    "doc": "Bootloader System Execution Flow",
    "title": "CAN Bootloader system level execution flow",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_system_execution_flow.html#can-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_system_execution_flow.html#can-bootloader-system-level-execution-flow"
  },"69": {
    "doc": "Bootloader System Execution Flow",
    "title": "Basic Bootloader system level execution flow",
    "content": ". | The Bootloader code starts executing on a device Reset . | If there are no conditions to enter the firmware upgrade mode, the Bootloader starts executing the user application . | Refer to Bootloader Trigger Methods for different conditions to enter firmware upgrade mode | . | The Bootloader performs Flash erase/program operations while in the firmware upgrade mode . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_system_execution_flow.html#basic-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_system_execution_flow.html#basic-bootloader-system-level-execution-flow"
  },"70": {
    "doc": "Bootloader System Execution Flow",
    "title": "Additional Information",
    "content": ". | Refer to Firmware Update Mode execution flow to understand how the firmware update takes place in bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_system_execution_flow.html#additional-information",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_system_execution_flow.html#additional-information"
  },"71": {
    "doc": "Bootloader System Execution Flow",
    "title": "Bootloader System Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_system_execution_flow.html",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_system_execution_flow.html"
  },"72": {
    "doc": "Tools Help",
    "title": "CAN Bootloader Tools Help",
    "content": ". | Refer to Binary to C Array script help to convert the binary file to a C style array containing Hex output. The CAN bootloader host device can store this in its NVM and then send it to CAN bootloader running on target device. | Refer to Bootloader and Application binary merge script Help for merging the bootloader and application binary. | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_tools_help.html#can-bootloader-tools-help",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_tools_help.html#can-bootloader-tools-help"
  },"73": {
    "doc": "Tools Help",
    "title": "Tools Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_bootloader_tools_help.html",
    "relUrl": "/templates/src/optimized/docs/can/can_bootloader_tools_help.html"
  },"74": {
    "doc": "Debugging Help",
    "title": "Debugging CAN Bootloader and Application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_debugging.html#debugging-can-bootloader-and-application-to-be-bootloaded",
    "relUrl": "/templates/src/optimized/docs/can/can_debugging.html#debugging-can-bootloader-and-application-to-be-bootloaded"
  },"75": {
    "doc": "Debugging Help",
    "title": "Debugging Bootloader",
    "content": "For CORTEX-M based MCUs . | Refer to Debugging Bootloaders For CORTEX-M based MCUs for information on how to debug CAN bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_debugging.html#debugging-bootloader",
    "relUrl": "/templates/src/optimized/docs/can/can_debugging.html#debugging-bootloader"
  },"76": {
    "doc": "Debugging Help",
    "title": "Debugging application to be bootloaded along with bootloader",
    "content": ". | Refer to Debugging Bootloader And Application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_debugging.html#debugging-application-to-be-bootloaded-along-with-bootloader",
    "relUrl": "/templates/src/optimized/docs/can/can_debugging.html#debugging-application-to-be-bootloaded-along-with-bootloader"
  },"77": {
    "doc": "Debugging Help",
    "title": "Debugging Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/can_debugging.html",
    "relUrl": "/templates/src/optimized/docs/can/can_debugging.html"
  },"78": {
    "doc": "Debugging Bootloader And Application",
    "title": "Debugging Bootloader and Application to be bootloaded",
    "content": ". | Open the bootloader project to be debugged in the MPLAB IDE . | Make sure that the application to be bootloaded and debugged is added as a loadable project to bootloader project . | Adding the application as loadable allows MPLAB X to create a unified hex file and program both bootloader and application in thier respective memory locations . | Bootloader in bootloader space | Application in application space | . | . | Open the application project in the IDE and disable post build script exection if any as shown below . | Having this binary conversion post build script enabled will result in build error during debugging as there will be no hex file generated | . | Set breakpoint as required in application project. Below is a an example snapshot . | If the bootloader also has to be debugged and if it is any of UART, I2C and CAN bootloader for CORTEX-M based MCUs refer to steps in Debugging Bootloaders For CORTEX-M based MCUs to set software breakpoints | . | Start debugger for the bootloader project using the IDE. This should program both bootloader and application . | Once the debugger is started the bootloader first runs and then jumps to application code. You should see the application breakpoint hit if application code is running . | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/debugging_bootloader_and_application.html#debugging-bootloader-and-application-to-be-bootloaded",
    "relUrl": "/templates/docs/debugging_bootloader_and_application.html#debugging-bootloader-and-application-to-be-bootloaded"
  },"79": {
    "doc": "Debugging Bootloader And Application",
    "title": "Additional Information (For MIPS based MCUs)",
    "content": ". | When combining the Bootloader and Application Hex files in MPLAB X IDE, an error may be generated if the device Configuration words are different. This will be shown as a data conflict error, and the address given will match an address in the device Configuration words. | This can be resolved by discarding the Device Configuration settings from application linker file as shown below . | . /DISCARD/ : { *(.config_*) } . | Refer to Application Linker Script Configurations for information on how to setup a linker script for the application to be bootloaded for MIPS based MCus | . ",
    "url": "http://localhost:4000/bootloader/templates/docs/debugging_bootloader_and_application.html#additional-information-for-mips-based-mcus",
    "relUrl": "/templates/docs/debugging_bootloader_and_application.html#additional-information-for-mips-based-mcus"
  },"80": {
    "doc": "Debugging Bootloader And Application",
    "title": "Debugging Bootloader And Application",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/docs/debugging_bootloader_and_application.html",
    "relUrl": "/templates/docs/debugging_bootloader_and_application.html"
  },"81": {
    "doc": "Application Configurations",
    "title": "Configurations for the application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_application_configurations.html#configurations-for-the-application-to-be-bootloaded",
    "relUrl": "/templates/src/fs/docs/fs_application_configurations.html#configurations-for-the-application-to-be-bootloaded"
  },"82": {
    "doc": "Application Configurations",
    "title": "For CORTEX-M based MCUs",
    "content": ". | Refer to Application project Configurations for information on how to configure an application to be bootloaded for CORTEX-M based MCus | . For MIPS based MCUs . | Refer to Application Linker Script Configurations for information on how to setup a linker script for the application to be bootloaded for MIPS based MCus . | Refer to Application project Configurations for information on how to configure an application to be bootloaded for MIPS based MCus . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_application_configurations.html#for-cortex-m-based-mcus",
    "relUrl": "/templates/src/fs/docs/fs_application_configurations.html#for-cortex-m-based-mcus"
  },"83": {
    "doc": "Application Configurations",
    "title": "Application Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_application_configurations.html",
    "relUrl": "/templates/src/fs/docs/fs_application_configurations.html"
  },"84": {
    "doc": "SD Card Bootloader Configurations",
    "title": "SD Card Bootloader Configurations",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#sd-card-bootloader-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#sd-card-bootloader-configurations"
  },"85": {
    "doc": "SD Card Bootloader Configurations",
    "title": "Bootloader Specific User Configurations",
    "content": ". | Bootloader Media Type: . | Change the Media Type to SDCARD | . | Bootloader NVM Memory Used: . | Specifies the memory peripheral used by bootloader to perform flash operations | The name of the peripheral will vary from device to device | . | Bootloader Size (Bytes): . | Specifies the maximum size of flash required by the bootloader | This size is calculated based on Bootloader type and Memory used | This size will vary from device to device and should always be aligned to device erase unit size | . | Enable Bootloader Trigger From Firmware: . | This Option can be used to Force Trigger bootloader from application firmware after a soft reset. It does so by reserving the specified number of bytes in SRAM from the start of the RAM. The reserved memory is updated by the application with a pre-defined pattern. The bootloader firmware in the bootloader_Trigger() routine, can check the reserved memory for the pre-defined pattern and enter bootloader mode if the pattern matches. | Number Of Bytes To Reserve From Start Of RAM: . | This option adds the provided offset to RAM Start address in bootloader linker script. | Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader to check at reset in bootloader_Trigger() function | . | . | Application Binary Image Path: . | Application binary image file name with path. If only file name is mentioned bootloader will try to open the file from the root directory . | Default: image.bin . | Can be used to specify custom paths based on requirement . | Example: dir1/dir2/app.bin | . | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#bootloader-specific-user-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#bootloader-specific-user-configurations"
  },"86": {
    "doc": "SD Card Bootloader Configurations",
    "title": "File System Configurations",
    "content": ". | Use File System Auto Mount Feature: . | Enabled by default when File System Bootloader is added | . | Media Type: . | Change the Media Type to SYS_FS_MEDIA_TYPE_SDCARD | . | Make FAT File System Read-only: . | Enabled by default when File System Bootloader is added as there are no write operations to be done . | Enabling this option also saves significant amount of flash memory . | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#file-system-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#file-system-configurations"
  },"87": {
    "doc": "SD Card Bootloader Configurations",
    "title": "Bootloader System Configurations",
    "content": ". | Application Start Address (Hex): . | Start address of the application which will programmed by bootloader | This value is filled by bootloader when its loaded which is equal to the bootloader size. It can be modified as per user need | This value will be used by bootloader to Jump to application at device reset | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#bootloader-system-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#bootloader-system-configurations"
  },"88": {
    "doc": "SD Card Bootloader Configurations",
    "title": "Bootloader Linker Pre Processor Macros for CORTEX-M based MCUs",
    "content": ". | Based on the configurations the above linker pre processor macros will be generated in MPLAB X xc32-ld settings . | ROM_LENGTH specifies the size of the bootloader | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#bootloader-linker-pre-processor-macros-for-cortex-m-based-mcus",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#bootloader-linker-pre-processor-macros-for-cortex-m-based-mcus"
  },"89": {
    "doc": "SD Card Bootloader Configurations",
    "title": "Additional Information",
    "content": ". | Refer to MIPS Bootloader Linker Script Configurations for information on bootloader linker script generated by MHC for MIPS based MCUs . | Refer to Bootloader Sizing And Considerations for information on bootloader size change considerations . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#additional-information",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html#additional-information"
  },"90": {
    "doc": "SD Card Bootloader Configurations",
    "title": "SD Card Bootloader Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_sdcard.html"
  },"91": {
    "doc": "Serial Memory Bootloader Configurations",
    "title": "Serial Memory Bootloader Configurations",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_serial.html#serial-memory-bootloader-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_serial.html#serial-memory-bootloader-configurations"
  },"92": {
    "doc": "Serial Memory Bootloader Configurations",
    "title": "Bootloader Specific User Configurations",
    "content": ". | Bootloader Media Type: . | Change the Media Type to Serial Memory | . | Bootloader NVM Memory Used: . | Specifies the memory peripheral used by bootloader to perform flash operations | The name of the peripheral will vary from device to device | . | Bootloader Size (Bytes): . | Specifies the maximum size of flash required by the bootloader | This size is calculated based on Bootloader type and Memory used | This size will vary from device to device and should always be aligned to device erase unit size | . | Enable Bootloader Trigger From Firmware: . | This Option can be used to Force Trigger bootloader from application firmware after a soft reset. It does so by reserving the specified number of bytes in SRAM from the start of the RAM. The reserved memory is updated by the application with a pre-defined pattern. The bootloader firmware in the bootloader_Trigger() routine, can check the reserved memory for the pre-defined pattern and enter bootloader mode if the pattern matches. | Number Of Bytes To Reserve From Start Of RAM: . | This option adds the provided offset to RAM Start address in bootloader linker script. | Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader to check at reset in bootloader_Trigger() function | . | . | Application Binary Image Path: . | Application binary image file name with path. If only file name is mentioned bootloader will try to open the file from the root directory . | Default: image.bin . | Can be used to specify custom paths based on requirement . | Example: dir1/dir2/app.bin | . | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_serial.html#bootloader-specific-user-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_serial.html#bootloader-specific-user-configurations"
  },"93": {
    "doc": "Serial Memory Bootloader Configurations",
    "title": "File System Configurations",
    "content": ". | Use File System Auto Mount Feature: . | Enabled by default when File System Bootloader is added | . | Media Type: . | Change the Media Type to SYS_FS_MEDIA_TYPE_SPIFLASH | . | Make FAT File System Read-only: . | Enabled by default when File System Bootloader is added as there are no write operations to be done . | Enabling this option also saves significant amount of flash memory . | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_serial.html#file-system-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_serial.html#file-system-configurations"
  },"94": {
    "doc": "Serial Memory Bootloader Configurations",
    "title": "Bootloader System Configurations",
    "content": ". | Application Start Address (Hex): . | Start address of the application which will programmed by bootloader | This value is filled by bootloader when its loaded which is equal to the bootloader size. It can be modified as per user need | This value will be used by bootloader to Jump to application at device reset | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_serial.html#bootloader-system-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_serial.html#bootloader-system-configurations"
  },"95": {
    "doc": "Serial Memory Bootloader Configurations",
    "title": "Bootloader Linker Pre Processor Macros for CORTEX-M based MCUs",
    "content": ". | Based on the configurations the above linker pre processor macros will be generated in MPLAB X xc32-ld settings . | ROM_LENGTH specifies the size of the bootloader | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_serial.html#bootloader-linker-pre-processor-macros-for-cortex-m-based-mcus",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_serial.html#bootloader-linker-pre-processor-macros-for-cortex-m-based-mcus"
  },"96": {
    "doc": "Serial Memory Bootloader Configurations",
    "title": "Additional Information",
    "content": ". | Refer to MIPS Bootloader Linker Script Configurations for information on bootloader linker script generated by MHC for MIPS based MCUs . | Refer to Bootloader Sizing And Considerations for information on bootloader size change considerations . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_serial.html#additional-information",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_serial.html#additional-information"
  },"97": {
    "doc": "Serial Memory Bootloader Configurations",
    "title": "Serial Memory Bootloader Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_serial.html",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_serial.html"
  },"98": {
    "doc": "USB Host MSD Bootloader Configurations",
    "title": "USB Host MSD Bootloader Configurations",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_usb.html#usb-host-msd-bootloader-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_usb.html#usb-host-msd-bootloader-configurations"
  },"99": {
    "doc": "USB Host MSD Bootloader Configurations",
    "title": "Bootloader Specific User Configurations",
    "content": ". | Bootloader Media Type: . | Change the Media Type to USB Mass Storage Device | . | Bootloader NVM Memory Used: . | Specifies the memory peripheral used by bootloader to perform flash operations | The name of the peripheral will vary from device to device | . | Bootloader Size (Bytes): . | Specifies the maximum size of flash required by the bootloader | This size is calculated based on Bootloader type and Memory used | This size will vary from device to device and should always be aligned to device erase unit size | . | Enable Bootloader Trigger From Firmware: . | This Option can be used to Force Trigger bootloader from application firmware after a soft reset. It does so by reserving the specified number of bytes in SRAM from the start of the RAM. The reserved memory is updated by the application with a pre-defined pattern. The bootloader firmware in the bootloader_Trigger() routine, can check the reserved memory for the pre-defined pattern and enter bootloader mode if the pattern matches. | Number Of Bytes To Reserve From Start Of RAM: . | This option adds the provided offset to RAM Start address in bootloader linker script. | Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader to check at reset in bootloader_Trigger() function | . | . | Application Binary Image Path: . | Application binary image file name with path. If only file name is mentioned bootloader will try to open the file from the root directory . | Default: image.bin . | Can be used to specify custom paths based on requirement . | Example: dir1/dir2/app.bin | . | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_usb.html#bootloader-specific-user-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_usb.html#bootloader-specific-user-configurations"
  },"100": {
    "doc": "USB Host MSD Bootloader Configurations",
    "title": "File System Configurations",
    "content": ". | Use File System Auto Mount Feature: . | Enabled by default when File System Bootloader is added | . | Media Type: . | Change the Media Type to SYS_FS_MEDIA_TYPE_MSD | . | Make FAT File System Read-only: . | Enabled by default when File System Bootloader is added as there are no write operations to be done . | Enabling this option also saves significant amount of flash memory . | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_usb.html#file-system-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_usb.html#file-system-configurations"
  },"101": {
    "doc": "USB Host MSD Bootloader Configurations",
    "title": "Bootloader System Configurations",
    "content": ". | Application Start Address (Hex): . | Start address of the application which will programmed by bootloader | This value is filled by bootloader when its loaded which is equal to the bootloader size. It can be modified as per user need | This value will be used by bootloader to Jump to application at device reset | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_usb.html#bootloader-system-configurations",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_usb.html#bootloader-system-configurations"
  },"102": {
    "doc": "USB Host MSD Bootloader Configurations",
    "title": "Bootloader Linker Pre Processor Macros for CORTEX-M based MCUs",
    "content": ". | Based on the configurations the above linker pre processor macros will be generated in MPLAB X xc32-ld settings . | ROM_LENGTH specifies the size of the bootloader | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_usb.html#bootloader-linker-pre-processor-macros-for-cortex-m-based-mcus",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_usb.html#bootloader-linker-pre-processor-macros-for-cortex-m-based-mcus"
  },"103": {
    "doc": "USB Host MSD Bootloader Configurations",
    "title": "Additional Information",
    "content": ". | Refer to MIPS Bootloader Linker Script Configurations for information on bootloader linker script generated by MHC for MIPS based MCUs . | Refer to Bootloader Sizing And Considerations for information on bootloader size change considerations . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_usb.html#additional-information",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_usb.html#additional-information"
  },"104": {
    "doc": "USB Host MSD Bootloader Configurations",
    "title": "USB Host MSD Bootloader Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_configurations_usb.html",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_configurations_usb.html"
  },"105": {
    "doc": "File System Bootloader Firmware Update Execution Flow",
    "title": "File System Bootloader Firmware Update mode execution flow",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_firmware_update_execution_flow.html#file-system-bootloader-firmware-update-mode-execution-flow",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_firmware_update_execution_flow.html#file-system-bootloader-firmware-update-mode-execution-flow"
  },"106": {
    "doc": "File System Bootloader Firmware Update Execution Flow",
    "title": "Bootloader Task Flow",
    "content": ". | Erases the Flash memory . | Programs the binary into Flash memory . | Jumps to the Application . | . USB Host MSD Bootloader Task Flow . SD Card and Serial Memory Bootloader Task Flow . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_firmware_update_execution_flow.html#bootloader-task-flow",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_firmware_update_execution_flow.html#bootloader-task-flow"
  },"107": {
    "doc": "File System Bootloader Firmware Update Execution Flow",
    "title": "File System Bootloader Firmware Update Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_firmware_update_execution_flow.html",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_firmware_update_execution_flow.html"
  },"108": {
    "doc": "How The Library Works",
    "title": "How the File System Bootloader library works",
    "content": "The File System Bootloader firmware uses the File System API’s to communicates with the underlying Media. The File System Bootloader works in two different modes . | Bootloader resides from . | The starting location of the flash memory region for CORTEX-M based MCUs . | The starting location of the Boot flash memory region or Program flash memory region for MIPS based MCUs devices . | . | The Bootloader performs flash erase/program operations with the application binary received from the media in the firmware upgrade mode . | Bootloader always performs flash operation from the application start address used during compile time . | The application can use the entire flash memory region starting from the end of bootloader space . | . | Jumps to the application once programming is completed | . Memory layout . | Basic memory layout for CORTEX-M based MCUs . | Basic memory layout for MIPS based MCUs . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_how_library_works.html#how-the-file-system-bootloader-library-works",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_how_library_works.html#how-the-file-system-bootloader-library-works"
  },"109": {
    "doc": "How The Library Works",
    "title": "How The Library Works",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_how_library_works.html",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_how_library_works.html"
  },"110": {
    "doc": "Library Interface",
    "title": "File System Bootloader Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_library_interface.html#file-system-bootloader-library-interface",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_library_interface.html#file-system-bootloader-library-interface"
  },"111": {
    "doc": "Library Interface",
    "title": "Table of contents",
    "content": ". | System functions . | bootloader_Tasks | bootloader_Trigger | run_Application | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_library_interface.html#table-of-contents",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_library_interface.html#table-of-contents"
  },"112": {
    "doc": "Library Interface",
    "title": "System functions",
    "content": "bootloader_Tasks . void bootloader_Tasks(void) . Summary . Starts bootloader execution. Description . This function can be used to start bootloader execution. The function receives the application binary from the media using the File System service to program it into internal flash memory. Once the complete application is received and programmed successfully, it resets the device to jump into programmed application. Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . bootloader_Tasks(); . bootloader_Trigger . bool bootloader_Trigger(void); . Summary . Checks if Bootloader has to be executed at startup. Description . This function can be used to check for a External HW trigger or Internal firmware trigger to execute bootloader at startup. This function has to be implemented by the bootloader application to override the WEAK implementation in bootloader.c . The checks in trigger function should happen before any system resources are initialized apart for PORT, As the same system resource can be Re-initialized by the application if bootloader jumps to it and may cause issues. | External Trigger: . | Can be achieved by triggering a GPIO_PIN at startup. | . | Firmware Trigger: . | Application firmware which wants to execute bootloader at startup needs to fill first n bytes of ram location with a request pattern. The Number of bytes to be reserved for storing the pattern has to be configured in bootloader component configuration in MHC. | . | . uint32_t *sram = (uint32_t *)BTL_TRIGGER_RAM_START; sram[0] = 0x5048434D; sram[1] = 0x5048434D; sram[2] = 0x5048434D; sram[3] = 0x5048434D; . Precondition . PORT/PIO Initialize must have been called. Parameters . None . Returns . | True : If any of trigger is detected. | False : If no trigger is detected.. | . Example . #define BTL_TRIGGER_PATTERN 0x5048434D static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START; bool bootloader_Trigger(void) { // Check for Bootloader Trigger Pattern in first 16 Bytes of RAM to enter Bootloader. if (BTL_TRIGGER_PATTERN == ramStart[0] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[1] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[2] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[3]) { ramStart[0] = 0; return true; } // Check for Switch press to enter Bootloader if (SWITCH_Get() == 0) { return true; } return false; } void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . run_Application . void run_Application(void); . Summary . Runs the programmed application at startup. Description . This function can be used to run programmed application though bootloader at startup. If the first 4Bytes of Application Memory is not 0xFFFFFFFF then it jumps to the application start address to run the application programmed through bootloader and never returns. If the first 4Bytes of Application Memory is 0xFFFFFFFF then it returns from function and executes bootloader for accepting a new application firmware. Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_library_interface.html#system-functions",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_library_interface.html#system-functions"
  },"113": {
    "doc": "Library Interface",
    "title": "Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_library_interface.html",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_library_interface.html"
  },"114": {
    "doc": "Bootloader System Execution Flow",
    "title": "File System Bootloader system level execution flow",
    "content": ". | The Bootloader code starts executing on a device Reset . | If there are no conditions to enter the firmware upgrade mode, the Bootloader starts executing the user application . | Refer to Bootloader Trigger Methods for different conditions to enter firmware upgrade mode | . | The Bootloader performs Flash erase/program operations while in the firmware upgrade mode . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_system_execution_flow.html#file-system-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_system_execution_flow.html#file-system-bootloader-system-level-execution-flow"
  },"115": {
    "doc": "Bootloader System Execution Flow",
    "title": "Additional Information",
    "content": ". | Refer to Firmware Update Mode execution flow to understand how the firmware update takes place in bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_system_execution_flow.html#additional-information",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_system_execution_flow.html#additional-information"
  },"116": {
    "doc": "Bootloader System Execution Flow",
    "title": "Bootloader System Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_bootloader_system_execution_flow.html",
    "relUrl": "/templates/src/fs/docs/fs_bootloader_system_execution_flow.html"
  },"117": {
    "doc": "Debugging Help",
    "title": "Debugging File System Bootloader and Application to be bootloaded",
    "content": ". | Refer to Debugging Bootloader And Application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_debugging.html#debugging-file-system-bootloader-and-application-to-be-bootloaded",
    "relUrl": "/templates/src/fs/docs/fs_debugging.html#debugging-file-system-bootloader-and-application-to-be-bootloaded"
  },"118": {
    "doc": "Debugging Help",
    "title": "Debugging Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/fs_debugging.html",
    "relUrl": "/templates/src/fs/docs/fs_debugging.html"
  },"119": {
    "doc": "Application Configurations",
    "title": "Configurations for the application to be bootloaded",
    "content": ". | Refer to Application project Configurations for information on how to configure an application to be bootloaded for CORTEX-M based MCus | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_application_configurations.html#configurations-for-the-application-to-be-bootloaded",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_application_configurations.html#configurations-for-the-application-to-be-bootloaded"
  },"120": {
    "doc": "Application Configurations",
    "title": "Application Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_application_configurations.html",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_application_configurations.html"
  },"121": {
    "doc": "Bootloader Configurations",
    "title": "I2C Bootloader Configurations",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_configurations.html#i2c-bootloader-configurations",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_configurations.html#i2c-bootloader-configurations"
  },"122": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Specific User Configurations",
    "content": ". | Bootloader Peripheral Used: . | Specifies the communication peripheral used by bootloader to receive the application | The name of the peripheral will vary from device to device | . | Bootloader NVM Memory Used: . | Specifies the memory peripheral used by bootloader to perform flash operations | The name of the peripheral will vary from device to device | . | Bootloader Size (Bytes): . | Specifies the maximum size of flash required by the bootloader | This size is calculated based on Bootloader type and Memory used | This size will vary from device to device and should always be aligned to device erase unit size | . | Enable Bootloader Trigger From Firmware: . | This Option can be used to Force Trigger bootloader from application firmware after a soft reset. It does so by reserving the specified number of bytes in SRAM from the start of the RAM. The reserved memory is updated by the application with a pre-defined pattern. The bootloader firmware in the bootloader_Trigger() routine, can check the reserved memory for the pre-defined pattern and enter bootloader mode if the pattern matches. | Number Of Bytes To Reserve From Start Of RAM: . | This option adds the provided offset to RAM Start address in bootloader linker script. | Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader to check at reset in bootloader_Trigger() function | . | . | Bootloader Commands Stretch I2C Clock: . | This Option is used to decide if bootloader stretches clock when it is busy or sends NAK. Enabling this option stretches the I2C clock when the bootloader is busy with the internal flash erase or write operation. The clock is stretched during the acknowledgement phase. This frees the I2C host from repeatedly polling the status of the sent command. If this option is disabled, the bootloader responds with a NAK while it is busy with the internal flash erase or write operation. This allows the I2C host to communicate with other slaves on the same bus, while the bootloader is busy. | . | Use Dual Bank For Safe Flash Update: . | Used to configure bootloader to use Dual banks of device to upload the application | This option is visible only for devices supporting Dual flash banks | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_configurations.html#bootloader-specific-user-configurations",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_configurations.html#bootloader-specific-user-configurations"
  },"123": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader System Configurations",
    "content": ". | Application Start Address (Hex): . | Start address of the application which will programmed by bootloader | This value is filled by bootloader when its loaded which is equal to the bootloader size. It can be modified as per user need | This value will be used by bootloader to Jump to application at device reset | . | . Note . | For optimizing the code Bootloader component disables generation of default interrupt and exception files as shown below . | Enabling these interrupts explicitly may still not work as bootloader uses custom startup file which has its own Interrupt table populating only the reset handler . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_configurations.html#bootloader-system-configurations",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_configurations.html#bootloader-system-configurations"
  },"124": {
    "doc": "Bootloader Configurations",
    "title": "Additional Information",
    "content": ". | Refer to CORTEX-M Bootloader Linker Script Configurations for information on bootloader linker script generated by MHC for CORTEX-M based MCUs . | Refer to Bootloader Sizing And Considerations for information on bootloader size change considerations . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_configurations.html#additional-information",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_configurations.html#additional-information"
  },"125": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_configurations.html",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_configurations.html"
  },"126": {
    "doc": "I2C Bootloader Firmware Update Execution Flow",
    "title": "I2C Bootloader Firmware Update mode execution flow",
    "content": "There are two state machines. One state machine processes the I2C events, parses the recevied I2C packets and triggers flash operations. The second state machine performs the flash operations (read/write/verify). ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_firmware_update_execution_flow.html#i2c-bootloader-firmware-update-mode-execution-flow",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_firmware_update_execution_flow.html#i2c-bootloader-firmware-update-mode-execution-flow"
  },"127": {
    "doc": "I2C Bootloader Firmware Update Execution Flow",
    "title": "Bootloader I2C Events Processor Task Flow",
    "content": ". | Bootloader I2C Events Processor Task polls and processes the I2C events. | This task is responsible for parsing and responding to the bootloader commands . | Once complete packet is received it sets the BUSY flag in the status byte and also sets appropriate flags for the Flash Programming Task to execute the command (Erase/Program/Verify) . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_firmware_update_execution_flow.html#bootloader-i2c-events-processor-task-flow",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_firmware_update_execution_flow.html#bootloader-i2c-events-processor-task-flow"
  },"128": {
    "doc": "I2C Bootloader Firmware Update Execution Flow",
    "title": "Flash Programming Task Flow",
    "content": ". | This task is responsible for executing the Erase/Program and Verify commands . | This task is non-blocking. It submits a Erase/Program request and then checks the status of flash operation whenever it gets a chance to run . | Once the flash operation is complete, it clears the BUSY flag and sets appropriate error flags (if any) in the status byte. | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_firmware_update_execution_flow.html#flash-programming-task-flow",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_firmware_update_execution_flow.html#flash-programming-task-flow"
  },"129": {
    "doc": "I2C Bootloader Firmware Update Execution Flow",
    "title": "I2C Bootloader Firmware Update Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_firmware_update_execution_flow.html",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_firmware_update_execution_flow.html"
  },"130": {
    "doc": "How The Library Works",
    "title": "How the I2C Bootloader library works",
    "content": "The CAN Bootloader firmware communicates with the embedded host device by using a predefined communication protocol. The I2C Bootloader works in two different modes . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_how_library_works.html#how-the-i2c-bootloader-library-works",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_how_library_works.html#how-the-i2c-bootloader-library-works"
  },"131": {
    "doc": "How The Library Works",
    "title": "Basic Mode",
    "content": ". | This mode is supported for all the devices . | Resides from . | The starting location of the flash memory region for CORTEX-M based MCUs | . | The Bootloader performs flash erase/program/verify operations with the binary sent from host while in the firmware upgrade mode . | The binary sent is only of the application to be programmed | Bootloader always performs flash operation from the address for (bootloader or application) binary sent from host | The application can use the entire flash memory region starting from the end of bootloader space | . | Jumps to the application once verification is completed | . Memory layout . | Basic memory layout for CORTEX-M based MCUs | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_how_library_works.html#basic-mode",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_how_library_works.html#basic-mode"
  },"132": {
    "doc": "How The Library Works",
    "title": "Fail Safe Update Mode",
    "content": ". | This mode is supported for the devices which have a Dual Bank flash memory . | Resides from the starting location of the flash memory region of both the banks on CORTEX-M based MCUs . | The Bootloader performs flash erase/program/verify operations with the binary sent from host while in the firmware upgrade mode . | Bootloader can perform flash operation in either of the banks based on the address sent by the host application . | The application can use only the flash memory region of one bank. | . | Performs a bank swap and reset to run the application programmed in opposite bank once verification is completed or a normal reset to run the application in current bank based on command sent from host | . Memory layout . | Fail Safe Update memory layout for CORTEX-M based MCUs | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_how_library_works.html#fail-safe-update-mode",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_how_library_works.html#fail-safe-update-mode"
  },"133": {
    "doc": "How The Library Works",
    "title": "Additional Information",
    "content": ". | For information on protocol used refer to I2C Bootloader Protocol | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_how_library_works.html#additional-information",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_how_library_works.html#additional-information"
  },"134": {
    "doc": "How The Library Works",
    "title": "How The Library Works",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_how_library_works.html",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_how_library_works.html"
  },"135": {
    "doc": "Library Interface",
    "title": "I2C Bootloader Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_library_interface.html#i2c-bootloader-library-interface",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_library_interface.html#i2c-bootloader-library-interface"
  },"136": {
    "doc": "Library Interface",
    "title": "Table of contents",
    "content": ". | System functions . | bootloader_Tasks | bootloader_Trigger | run_Application | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_library_interface.html#table-of-contents",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_library_interface.html#table-of-contents"
  },"137": {
    "doc": "Library Interface",
    "title": "System functions",
    "content": "bootloader_Tasks . void bootloader_Tasks(void) . Summary . Starts bootloader execution. Description . This function can be used to start bootloader execution. The function continuously waits for application firmware from the host device via I2C and perfroms Erase/Program/Verify operations on internal flash memory . Once the complete application is received, programmed and verified successfully, it resets the device to jump into programmed application. | Note: As this function runs a infinite loop it never returns | . Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . bootloader_Tasks(); . bootloader_Trigger . bool bootloader_Trigger(void); . Summary . Checks if Bootloader has to be executed at startup. Description . This function can be used to check for a External HW trigger or Internal firmware trigger to execute bootloader at startup. This function has to be implemented by the bootloader application to override the WEAK implementation in bootloader.c . The checks in trigger function should happen before any system resources are initialized apart for PORT, As the same system resource can be Re-initialized by the application if bootloader jumps to it and may cause issues. | External Trigger: . | Can be achieved by triggering a GPIO_PIN at startup. | . | Firmware Trigger: . | Application firmware which wants to execute bootloader at startup needs to fill first n bytes of ram location with a request pattern. The Number of bytes to be reserved for storing the pattern has to be configured in bootloader component configuration in MHC. | . | . uint32_t *sram = (uint32_t *)BTL_TRIGGER_RAM_START; sram[0] = 0x5048434D; sram[1] = 0x5048434D; sram[2] = 0x5048434D; sram[3] = 0x5048434D; . Precondition . PORT/PIO Initialize must have been called. Parameters . None . Returns . | True : If any of trigger is detected. | False : If no trigger is detected.. | . Example . #define BTL_TRIGGER_PATTERN 0x5048434D static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START; bool bootloader_Trigger(void) { // Check for Bootloader Trigger Pattern in first 16 Bytes of RAM to enter Bootloader. if (BTL_TRIGGER_PATTERN == ramStart[0] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[1] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[2] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[3]) { ramStart[0] = 0; return true; } // Check for Switch press to enter Bootloader if (SWITCH_Get() == 0) { return true; } return false; } void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . run_Application . void run_Application(void); . Summary . Runs the programmed application at startup. Description . This function can be used to run programmed application though bootloader at startup. If the first 4Bytes of Application Memory is not 0xFFFFFFFF then it jumps to the application start address to run the application programmed through bootloader and never returns. If the first 4Bytes of Application Memory is 0xFFFFFFFF then it returns from function and executes bootloader for accepting a new application firmware. Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_library_interface.html#system-functions",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_library_interface.html#system-functions"
  },"138": {
    "doc": "Library Interface",
    "title": "Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_library_interface.html",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_library_interface.html"
  },"139": {
    "doc": "I2C Bootloader Protocol",
    "title": "I2C Bootloader Protocol",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_protocol.html#i2c-bootloader-protocol",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_protocol.html#i2c-bootloader-protocol"
  },"140": {
    "doc": "I2C Bootloader Protocol",
    "title": "Command Description",
    "content": "Each command argument is of 4 bytes and must be sent in big-endian (MSB first) format. Unlock Command (0xA0) . | Unlock command is used to specify the application start address and size of the application. Unlock command must be issued before issuing any other command. | Payload: . | Arg 0 - Application start address. The start address is device dependent and must be aligned to an Erase Unit boundary which is also device dependent. | Arg 1 - Application size. It must be rounded off to the nearest erase unit size . | . | The memory address range specified in Unlock command will be used to validate the addresses sent for other commands. The memory address specified by all other commands must lie within the address range specified for the Unlock command. | Bootloader will calculate CRC over the entire range of memory specified by the Unlock command . | . Erase Command (0xA1) . | Erase command erases a flash page as specified by the Erase Page Address argument . | Payload: . | Arg 0 - Starting memory address of the flash page being erased. | . | The flash page being erased must lie within the address range specified by the Unlock command else the bootloader will NAK the command and the INVALID ADDRESS error bit will be set in the status byte. | If the command is accepted successfully, the bootloader will set the BUSY bit in the status byte. The host application must poll the status byte and ensure that the command is completed successfully (status byte indicates bootloader is not busy and no error bits are set) before issuing a new command. | Note: Depending on the value specified for Bootloader Commands Stretch I2C Clock, the bootloader may either stretch the I2C clock or respond with NAK while it is busy | . Program Command (0xA2) . | Program command is used to send the image data . | Payload: . | Arg 0: Number of bytes to program. It must be a multiple of the flash page size. Depending on the value specified, one or more flash pages within the erase unit can be programmed. For example, if the erase row size is 256 bytes and program page size is 64 bytes, the number of bytes to program can either be 64, 128, 192 or 256. | Arg 1: Program Memory Address. It must be aligned to the start address of the flash page being programmed. | . | The flash page being programmed must lie within the address range specified by the Unlock command; else the bootloader will NAK the command and the INVALID ADDRESS error bit will be set in the status byte. | If the command is accepted successfully, the bootloader will set the busy bit in the status byte. The host application must poll the status byte and ensure that the command is completed successfully (status byte indicates bootloader is not busy and no error bits are set) before issuing a new command. | The bootloader host application must ensure that the flash page being programmed is erased before issuing the Program Command . | Note: Depending on the value specified for Bootloader Commands Stretch I2C Clock, the bootloader may either stretch the I2C clock or respond with NAK while it is busy. | . Verify Command (0xA3) . | Verify command is used to verify the programmed application image. | Payload: . | Arg 0: Application Image CRC. CRC is a standard IEEE CRC32 with a polynomial of 0xEDB88320 | . | The bootloader host application must calculate the CRC of the application image over the entire memory range specified in the Unlock command and provide it to the bootloader. The CRC is a standard IEEE CRC32 with a polynomial of 0xEDB88320. | The bootloader upon receiving the Verify command, calculates the CRC over the range of addresses specified by the Unlock command by reading the flash memory contents and compares it with the received CRC value. | If the command is accepted successfully, the bootloader will set the busy bit in the status byte. The host application must poll the status byte and ensure that the CRC verification is successful (status byte indicates bootloader is not busy and no error bits are set) before issuing the Reset Command. | If the calculated CRC and received CRC values do not match, the CRC_ERROR bit is set in the Status byte. | Note: The bootloader will stretch the I2C clock while it is busy verifying the application image. | . Reset Command (0xA4) . | Reset command is used to exit the bootloader and run the application. The system takes a reset after receiving the Reset Command . | . Read Status Command (0xA5) . | Returns the bootloader status. The bootloader status can be read any time. | . Flash Bank Swap and Reset Command (0xA6) . | Resets the device and swaps the flash bank. | This command is enabled only when Fail safe update feature is selected for bootloader and the device has support for Dual Bank update . | Bank Swap and Reset command is used to Swap the inactive bank to active bank and trigger a reset to exit the bootloader and run the new application programmed in the inactive bank . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_protocol.html#command-description",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_protocol.html#command-description"
  },"141": {
    "doc": "I2C Bootloader Protocol",
    "title": "I2C Bootloader Protocol",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_protocol.html",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_protocol.html"
  },"142": {
    "doc": "Bootloader System Execution Flow",
    "title": "I2C Bootloader system level execution flow",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_system_execution_flow.html#i2c-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_system_execution_flow.html#i2c-bootloader-system-level-execution-flow"
  },"143": {
    "doc": "Bootloader System Execution Flow",
    "title": "Bootloader system level execution flow",
    "content": ". | The Bootloader code starts executing on a device Reset . | If there are no conditions to enter the firmware upgrade mode, the Bootloader starts executing the user application . | Refer to Bootloader Trigger Methods for different conditions to enter firmware upgrade mode | . | The Bootloader performs Flash erase/program operations while in the firmware upgrade mode . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_system_execution_flow.html#bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_system_execution_flow.html#bootloader-system-level-execution-flow"
  },"144": {
    "doc": "Bootloader System Execution Flow",
    "title": "Additional Information",
    "content": ". | Refer to Firmware Update Mode execution flow to understand how the firmware update takes place in bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_system_execution_flow.html#additional-information",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_system_execution_flow.html#additional-information"
  },"145": {
    "doc": "Bootloader System Execution Flow",
    "title": "Bootloader System Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_system_execution_flow.html",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_system_execution_flow.html"
  },"146": {
    "doc": "Tools Help",
    "title": "I2C Bootloader Tools Help",
    "content": ". | Refer to Binary to C Array script help to convert the binary file to a C style array containing Hex output. The I2C bootloader host device can store this in its NVM and then send it to I2C bootloader running on target device. | Refer to Bootloader and Application binary merge script Help for merging the bootloader and application binary. | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_tools_help.html#i2c-bootloader-tools-help",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_tools_help.html#i2c-bootloader-tools-help"
  },"147": {
    "doc": "Tools Help",
    "title": "Tools Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_bootloader_tools_help.html",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_bootloader_tools_help.html"
  },"148": {
    "doc": "Debugging Help",
    "title": "Debugging I2C Bootloader and Application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_debugging.html#debugging-i2c-bootloader-and-application-to-be-bootloaded",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_debugging.html#debugging-i2c-bootloader-and-application-to-be-bootloaded"
  },"149": {
    "doc": "Debugging Help",
    "title": "Debugging Bootloader",
    "content": ". | Refer to Debugging Bootloaders For CORTEX-M based MCUs for information on how to debug I2C bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_debugging.html#debugging-bootloader",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_debugging.html#debugging-bootloader"
  },"150": {
    "doc": "Debugging Help",
    "title": "Debugging application to be bootloaded along with bootloader",
    "content": ". | Refer to Debugging Bootloader And Application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_debugging.html#debugging-application-to-be-bootloaded-along-with-bootloader",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_debugging.html#debugging-application-to-be-bootloaded-along-with-bootloader"
  },"151": {
    "doc": "Debugging Help",
    "title": "Debugging Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/i2c_debugging.html",
    "relUrl": "/templates/src/optimized/docs/i2c/i2c_debugging.html"
  },"152": {
    "doc": "Application Linker Configurations",
    "title": "Linker configurations for the application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_application_linker_config.html#linker-configurations-for-the-application-to-be-bootloaded",
    "relUrl": "/templates/mips/docs/mips_application_linker_config.html#linker-configurations-for-the-application-to-be-bootloaded"
  },"153": {
    "doc": "Application Linker Configurations",
    "title": "Bootloader placement for various PIC32M product families",
    "content": "The bootloader is placed in Boot Flash Memory (BFM) or Program Flash Memory (PFM) based on the size of the bootloader and available Boot flash memory on the device. | If the bootloader fits into the available BFM, it is placed in BFM. The user application can use the complete area of the program Flash memory. | If the bootloader does not fit into the available BFM, it is placed in PFM. The user application can use the remaining area of the program Flash memory. | The following table shows the available Boot Flash memory and the placement of different bootloaders by product family. | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_application_linker_config.html#bootloader-placement-for-various-pic32m-product-families",
    "relUrl": "/templates/mips/docs/mips_application_linker_config.html#bootloader-placement-for-various-pic32m-product-families"
  },"154": {
    "doc": "Application Linker Configurations",
    "title": "Setting up the Application linker script",
    "content": "The linker script file of the application project has to be modified to place the vector table and reset handlers in program flash memory. | For Quick start, Refer to pre developed application linker scripts app_XX.ld placed in projects device specific configuration folder of bootloader_apps_xxx/ repository. For example: . | Reset Address for the application to be loaded through bootloader should match the Application start address mentioned in bootloader project. | The vector address of a given interrupt is calculated using Exception Base (EBASE) CPU register and the _ebase_address should be aligned to 4KB boundary . | Note: The below sections provides overview of changes required in the applications linker scripts. The address location and size may vary based on the specific device used . | . For Bootloaders placed in Boot Flash Memory (PIC32MZ and PIC32MK Devices) . | The application start address by default will be start of program flash memory . | Refer to specific device datasheet for program flash memory start address and length | . | The Initial 4KB from Application start address are used by Reset Handler and and cache_init section . | XC32 Compiler calculates offset from the EBASE address and initializes the value of interrupt vector offset (OFFx) register. The offset register is combined with EBASE register using a bitwise OR operator to obtain the interrupt vector address that the CPU will jump to when the corresponding interrupt occurs. | If the EBASE address is aligned to 4KB, then all the interrupt vectors must be located within the 4KB from base address. | Example: When _ebase_address is set to 0x9D001000 and interrupts vectors are not located withing the 4KB boundary from the ebase address (OFFx &gt; 0x1000), then the bitwise OR operator may not provide correct interrupt vector address. | . | To provide maximum flexibility in placement of interrupt vectors: . | Always place the _ebase_address at start of Program flash memory (Example : 0x9D000000) like the default linker script . | Change the offsets of exceptions and vector section to place them after the device startup code. With this the interrupt handlers can be located anywhere in the Program Flash memory. | . | Updated linker scripts as explained above is shown here as an example . | Note: Cache related sections are not applicable for PIC32MK Devices | . | . PROVIDE(_vector_spacing = 0x0001); PROVIDE(_ebase_address = 0x9D000000); /* Place the vector table and other exceptions after the device reset and * cache init code. */ PROVIDE(_ebase_vector_offsets = 0x1000); _RESET_ADDR = 0xBD000000; _SIMPLE_TLB_REFILL_EXCPT_ADDR = _ebase_address + _ebase_vector_offsets + 0; _CACHE_ERR_EXCPT_ADDR = _ebase_address + _ebase_vector_offsets + 0x100; _GEN_EXCPT_ADDR = _ebase_address + _ebase_vector_offsets + 0x180; kseg0_program_mem (rx) : ORIGIN = 0x9D001000, LENGTH = 0x200000 - 0x1000 kseg1_boot_mem : ORIGIN = 0xBD000000, LENGTH = 0x480 kseg1_boot_mem_4B0 : ORIGIN = 0xBD0004B0, LENGTH = 0x1000 - 0x4B0 /* Boot Sections */ .reset _RESET_ADDR : { KEEP(*(.reset)) KEEP(*(.reset.startup)) } &gt; kseg1_boot_mem .cache_init : { *(.cache_init) *(.cache_init.*) } &gt; kseg1_boot_mem_4B0 ... /* Interrupt vector table with vector offsets */ .vectors _ebase_address + _ebase_vector_offsets + 0x200 : { /* Symbol __vector_offset_n points to .vector_n if it exists, * otherwise points to the default handler. The * vector_offset_init.o module then provides a .data section * containing values used to initialize the vector-offset SFRs * in the crt0 startup code. */ . = ALIGN(4) ; __vector_offset_0 = (DEFINED(__vector_dispatch_0) ? (. - _ebase_address) : __vector_offset_default); KEEP(*(.vector_0)) ..... /* Default interrupt handler */ . = ALIGN(4) ; __vector_offset_default = . - _ebase_address; KEEP(*(.vector_default)) } &gt; kseg0_program_mem . For Bootloaders placed in Program Flash Memory (PIC32MK Devices) . | The bootloader code resides from start of Program flash memory, hence the application start address has to be after the end of bootloader. | Refer to specific device datasheet for program flash memory start address and length | . | The Initial 4KB from Application start address are used by Reset Handler section . | XC32 Compiler calculates offset from the EBASE address and initializes the value of interrupt vector offset (OFFx) register. The offset register is combined with EBASE register using a bitwise OR operator to obtain the interrupt vector address that the CPU will jump to when the corresponding interrupt occurs. | If the EBASE address is aligned to 4KB, then all the interrupt vectors must be located within the 4KB from base address. | Example: When _ebase_address is set to 0x9D001000 and interrupts vectors are not located withing the 4KB boundary from the ebase address (OFFx &gt; 0x1000), then the bitwise OR operator may not provide correct interrupt vector address. | . | To provide maximum flexibility in placement of interrupt vectors: . | Always place the _ebase_address at start of Program flash memory (Example : 0x9D000000) like the default linker script . | Note: As _ebase_address is only used to calculate the vector offset it can be placed at start of program flash memory even though the bootloader code is residing there . | Change the offsets of exceptions and vector section to place them after the device startup code of application. With this the interrupt handlers can be located anywhere in the Program Flash memory after bootloader space . | . | Updated linked scripts as explained above is shown here as an example. | Bootloader length &lt;bootloader_length&gt; in the below snippet needs to be replaced with size of the respective bootloader. | . | . PROVIDE(_vector_spacing = 0x0001); PROVIDE(_ebase_address = 0x9D000000); /* Place the vector table and other exceptions after the device reset and * cache init code. */ PROVIDE(_ebase_vector_offsets = &lt;bootloader_length&gt; + 0x1000); _RESET_ADDR = 0xBD000000 + &lt;bootloader_length&gt;; _SIMPLE_TLB_REFILL_EXCPT_ADDR = _ebase_address + _ebase_vector_offsets + 0; _GEN_EXCPT_ADDR = _ebase_address + _ebase_vector_offsets + 0x180; kseg0_program_mem (rx) : ORIGIN = 0x9D000000 + &lt;bootloader_length&gt; + 0x1000, LENGTH = 0x200000 - &lt;bootloader_length&gt; - 0x1000 kseg1_boot_mem : ORIGIN = 0xBD000000 + &lt;bootloader_length&gt;, LENGTH = 0x1000 /* Boot Sections */ .reset _RESET_ADDR : { KEEP(*(.reset)) KEEP(*(.reset.startup)) } &gt; kseg1_boot_mem ... /* Interrupt vector table with vector offsets */ .vectors _ebase_address + _ebase_vector_offsets + 0x200 : { /* Symbol __vector_offset_n points to .vector_n if it exists, * otherwise points to the default handler. The * vector_offset_init.o module then provides a .data section * containing values used to initialize the vector-offset SFRs * in the crt0 startup code. */ . = ALIGN(4) ; __vector_offset_0 = (DEFINED(__vector_dispatch_0) ? (. - _ebase_address) : __vector_offset_default); KEEP(*(.vector_0)) ..... /* Default interrupt handler */ . = ALIGN(4) ; __vector_offset_default = . - _ebase_address; KEEP(*(.vector_default)) } &gt; kseg0_program_mem . For Bootloaders placed in Boot Flash Memory (PIC32MX Devices) . | The application start address by default will be start of program flash memory . | Refer to specific device datasheet for program flash memory start address and length | . | The Initial 4KB are used by Reset Handler section . | In PIC32MX devices the _ebase_address holds the start address of vector table and it must be placed at 4KB boundary after the Reset Handler section . | Updated linked scripts as explained above is shown here as an example. | . PROVIDE(_vector_spacing = 0x0001); PROVIDE(_ebase_address = 0x9D001000); _RESET_ADDR = 0xBD000000 kseg0_program_mem (rx) : ORIGIN = 0x9D001000, LENGTH = 0x80000 - 0x1000 kseg1_boot_mem : ORIGIN = 0xBD000000, LENGTH = 0x1000 /* Boot Sections */ .reset _RESET_ADDR : { KEEP(*(.reset)) KEEP(*(.reset.startup)) } &gt; kseg1_boot_mem ...vector_0 _ebase_address + 0x200 + ((_vector_spacing &lt;&lt; 5) * 0) : { KEEP(*(.vector_0)) } &gt; kseg0_program_mem ASSERT (_vector_spacing == 0 || SIZEOF(.vector_0) &lt;= (_vector_spacing &lt;&lt; 5), \\\"function at exception vector 0 too large\\\") .vector_1 _ebase_address + 0x200 + ((_vector_spacing &lt;&lt; 5) * 1) : { KEEP(*(.vector_1)) } &gt; kseg0_program_mem ASSERT (_vector_spacing == 0 || SIZEOF(.vector_1) &lt;= (_vector_spacing &lt;&lt; 5), \\\"function at exception vector 1 too large\\\") ..... For Bootloaders placed in Program Flash Memory (PIC32MX Devices) . | The bootloader code resides from start of Program flash memory, hence the application start address has to be after the end of bootloader. | The Initial 4KB from Application start address are used by Reset Handler section . | Place the _ebase_address after the device startup code of application . | Updated linked scripts as explained above is shown here as an example. | Bootloader length &lt;bootloader_length&gt; in the below snippet needs to be replaced with size of the respective bootloader. | . | . PROVIDE(_vector_spacing = 0x0001); PROVIDE(_ebase_address = 0x9D000000 + &lt;bootloader_length&gt; + 0x1000); _RESET_ADDR = 0xBD000000 + &lt;bootloader_length&gt;; kseg0_program_mem (rx) : ORIGIN = 0x9D000000 + &lt;bootloader_length&gt; + 0x1000, LENGTH = 0x80000 - &lt;bootloader_length&gt; - 0x1000 kseg1_boot_mem : ORIGIN = 0xBD000000 + &lt;bootloader_length&gt;, LENGTH = 0x1000 /* Boot Sections */ .reset _RESET_ADDR : { KEEP(*(.reset)) KEEP(*(.reset.startup)) } &gt; kseg1_boot_mem ...vector_0 _ebase_address + 0x200 + ((_vector_spacing &lt;&lt; 5) * 0) : { KEEP(*(.vector_0)) } &gt; kseg0_program_mem ASSERT (_vector_spacing == 0 || SIZEOF(.vector_0) &lt;= (_vector_spacing &lt;&lt; 5), \\\"function at exception vector 0 too large\\\") .vector_1 _ebase_address + 0x200 + ((_vector_spacing &lt;&lt; 5) * 1) : { KEEP(*(.vector_1)) } &gt; kseg0_program_mem ASSERT (_vector_spacing == 0 || SIZEOF(.vector_1) &lt;= (_vector_spacing &lt;&lt; 5), \\\"function at exception vector 1 too large\\\") ..... Note . | The bootloader and the application must have the same device configuration bit settings. The Device configuration bit settings from the bootloader project will be updated by the programmer/debugger, Hence the application linker script should not have any device configuration bit settings. The application project will use the device configuration bit settings done by bootloader. | Device configurations and debug exception need to discarded from final hex file for the application project. | . /DISCARD/ : { *(._debug_exception) } /DISCARD/ : { *(.config_*) } . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_application_linker_config.html#setting-up-the-application-linker-script",
    "relUrl": "/templates/mips/docs/mips_application_linker_config.html#setting-up-the-application-linker-script"
  },"155": {
    "doc": "Application Linker Configurations",
    "title": "Additional settings (Optional)",
    "content": ". | Data Memory Origin and Data Memory Length values should be updated in linkerscript for reserving configured bytes from start of RAM to trigger bootloader from firmware | . /* Reserve &lt;trigger_len&gt; Bytes to Store Bootloader Trigger Pattern */ kseg0_data_mem (w!x) : ORIGIN = &lt;ram_start&gt; + &lt;trigger_len&gt;, LENGTH = &lt;ram_length&gt; - &lt;trigger_len&gt; . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_application_linker_config.html#additional-settings-optional",
    "relUrl": "/templates/mips/docs/mips_application_linker_config.html#additional-settings-optional"
  },"156": {
    "doc": "Application Linker Configurations",
    "title": "Application Linker Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_application_linker_config.html",
    "relUrl": "/templates/mips/docs/mips_application_linker_config.html"
  },"157": {
    "doc": "Application Project Configurations",
    "title": "Project configurations for the application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_application_project_config.html#project-configurations-for-the-application-to-be-bootloaded",
    "relUrl": "/templates/mips/docs/mips_application_project_config.html#project-configurations-for-the-application-to-be-bootloaded"
  },"158": {
    "doc": "Application Project Configurations",
    "title": "Application Settings in MHC System Configuration",
    "content": ". | Disable default linker file generation in system settings from MHC, As the application to be bootloaded will be using a custom linker file . | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_application_project_config.html#application-settings-in-mhc-system-configuration",
    "relUrl": "/templates/mips/docs/mips_application_project_config.html#application-settings-in-mhc-system-configuration"
  },"159": {
    "doc": "Application Project Configurations",
    "title": "MPLAB X Settings",
    "content": "For Bootloading the application using binary file . | Below are the Bootloaders which use application binary (.bin) file as input . | UART | I2C | CAN | Serial Memory | File System | . | Specifying post build option to automatically generate the binary file from hex file once the build is complete . \${MP_CC_DIR}/xc32-objcopy -I ihex -O binary \${DISTDIR}/\${PROJECTNAME}.\${IMAGE_TYPE}.hex \${DISTDIR}/\${PROJECTNAME}.\${IMAGE_TYPE}.bin . | . For Bootloading the application using Normalized Hex file . | Below are the Bootloaders which use Normalized application Hex (.hex) file as input . | USB Device HID | UDP | . | Check the Normalize hex file option as shown below, as the Unified bootloader host application takes hex file as an input. Normalizing the hex file will make sure the data in the hex file is arranged sequentially . | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_application_project_config.html#mplab-x-settings",
    "relUrl": "/templates/mips/docs/mips_application_project_config.html#mplab-x-settings"
  },"160": {
    "doc": "Application Project Configurations",
    "title": "Application Project Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_application_project_config.html",
    "relUrl": "/templates/mips/docs/mips_application_project_config.html"
  },"161": {
    "doc": "Bootloader Linker Configurations",
    "title": "Linker configurations for the Bootloader",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_linker_config.html#linker-configurations-for-the-bootloader",
    "relUrl": "/templates/mips/docs/mips_bootloader_linker_config.html#linker-configurations-for-the-bootloader"
  },"162": {
    "doc": "Bootloader Linker Configurations",
    "title": "Bootloader placement for various PIC32M product families",
    "content": "The bootloader is placed in Boot Flash Memory (BFM) or Program Flash Memory (PFM) based on the size of the bootloader and available Boot flash memory on the device. | If the bootloader fits into the available BFM, it is placed in BFM. The user application can use the complete area of the program Flash memory. | If the bootloader does not fit into the available BFM, it is placed in PFM. The user application can use the remaining area of the program Flash memory. | The following table shows the available Boot Flash memory and the placement of different bootloaders by product family. | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_linker_config.html#bootloader-placement-for-various-pic32m-product-families",
    "relUrl": "/templates/mips/docs/mips_bootloader_linker_config.html#bootloader-placement-for-various-pic32m-product-families"
  },"163": {
    "doc": "Bootloader Linker Configurations",
    "title": "Bootloader linker script settings",
    "content": ". | Bootloader library uses a custom linker script which is generated through MHC . | The values populated in the linker script are based on the Bootloader component MHC configurations . | The vector address of a given interrupt is calculated using Exception Base (EBASE) CPU register and the _ebase_address should be aligned to 4KB boundary . | Note: The below sections provides overview of changes done to bootloader linker scripts when compared to default linker script. The address location and size may vary based on the specific device used . | . For Bootloaders placed in Boot Flash Memory (PIC32MZ and PIC32MK Devices) . | The bootloader start address by default will be start of Boot flash memory (0xBFC00000). This is the default startup location for all PIC32M devices . | The Initial 4KB from Bootloader start address are used by Reset Handler and cache_init section followed by rest of bootloader code. | Length of the bootloader is calculated based on the bootloader being added to MHC . | XC32 Compiler calculates offset from the EBASE address and initializes the value of interrupt vector offset (OFFx) register. The offset register is combined with EBASE register using a bitwise OR operator to obtain the interrupt vector address that the CPU will jump to when the corresponding interrupt occurs. | If the EBASE address is aligned to 4KB, then all the interrupt vectors must be located within the 4KB from base address. | Example: When _ebase_address is set to 0x9FC01000 and interrupts vectors are not located withing the 4KB boundary from the ebase address (OFFx &gt; 0x1000), then the bitwise OR operator may not provide correct interrupt vector address. | . | To provide maximum flexibility in placement of interrupt vectors: . | The _ebase_address is placed at start of Boot flash memory (0x9FC00000) . | Offsets of exceptions and vector sections are updated to place them after the device startup code. With this the interrupt handlers can be located anywhere in the Boot Flash memory. | . | Generated linker scripts as explained above is shown here as an example . | Bootloader length &lt;bootloader_length&gt; in the below snippet is auto generated based on the bootloader component added in MHC . | Note: Cache related sections are not applicable for PIC32MK Devices . | . | . PROVIDE(_vector_spacing = 0x0001); PROVIDE(_ebase_address = 0x9FC00000); /* Place the vector table and other exceptions after the device reset and * cache init code. */ PROVIDE(_ebase_vector_offsets = 0x1000); _RESET_ADDR = 0xBFC00000; _BEV_EXCPT_ADDR = 0xBFC00380; _DBG_EXCPT_ADDR = 0xBFC00480; _SIMPLE_TLB_REFILL_EXCPT_ADDR = _ebase_address + _ebase_vector_offsets + 0; _CACHE_ERR_EXCPT_ADDR = _ebase_address + _ebase_vector_offsets + 0x100; _GEN_EXCPT_ADDR = _ebase_address + _ebase_vector_offsets + 0x180; kseg0_program_mem (rx) : ORIGIN = 0x9FC01000, LENGTH = &lt;bootloader_length&gt; kseg1_boot_mem : ORIGIN = 0xBFC00000, LENGTH = 0x480 kseg1_boot_mem_4B0 : ORIGIN = 0xBFC004B0, LENGTH = 0x1000 - 0x4B0 ... config_BFC0FF40 : ORIGIN = 0xBFC0FF40, LENGTH = 0x4 config_BFC0FF44 : ORIGIN = 0xBFC0FF44, LENGTH = 0x4 config_BFC0FF48 : ORIGIN = 0xBFC0FF48, LENGTH = 0x4 ..... SECTIONS { .config_BFC0FF40 : { KEEP(*(.config_BFC0FF40)) } &gt; config_BFC0FF40 .config_BFC0FF44 : { KEEP(*(.config_BFC0FF44)) } &gt; config_BFC0FF44 ..... } /* Boot Sections */ .reset _RESET_ADDR : { KEEP(*(.reset)) KEEP(*(.reset.startup)) } &gt; kseg1_boot_mem .cache_init : { *(.cache_init) *(.cache_init.*) } &gt; kseg1_boot_mem_4B0 ... /* Interrupt vector table with vector offsets */ .vectors _ebase_address + _ebase_vector_offsets + 0x200 : { /* Symbol __vector_offset_n points to .vector_n if it exists, * otherwise points to the default handler. The * vector_offset_init.o module then provides a .data section * containing values used to initialize the vector-offset SFRs * in the crt0 startup code. */ . = ALIGN(4) ; __vector_offset_0 = (DEFINED(__vector_dispatch_0) ? (. - _ebase_address) : __vector_offset_default); KEEP(*(.vector_0)) ..... /* Default interrupt handler */ . = ALIGN(4) ; __vector_offset_default = . - _ebase_address; KEEP(*(.vector_default)) } &gt; kseg0_program_mem . For Bootloaders placed in Program Flash Memory (PIC32MK Devices) . | The bootloader start address by default will be start of Boot flash memory (0xBFC00000). This is the default startup location for all PIC32M devices . | As the entire bootloader cannot be placed in BFM, Only the bootloader Reset Handler is placed in BFM. Rest of the bootloader code will be placed from start of Program Flash memory . | XC32 Compiler calculates offset from the EBASE address and initializes the value of interrupt vector offset (OFFx) register. The offset register is combined with EBASE register using a bitwise OR operator to obtain the interrupt vector address that the CPU will jump to when the corresponding interrupt occurs. | If the EBASE address is aligned to 4KB, then all the interrupt vectors must be located within the 4KB from base address. | Example: When _ebase_address is set to 0x9D001000 and interrupts vectors are not located withing the 4KB boundary from the ebase address (OFFx &gt; 0x1000), then the bitwise OR operator may not provide correct interrupt vector address. | . | To provide maximum flexibility in placement of interrupt vectors: . | The _ebase_address is placed at start of Program flash memory (Example : 0x9D000000) like the default linker script . | Offsets of exceptions and vector sections are updated to place them from start of PFM. With this the interrupt handlers can be located anywhere in the bootloader space of PFM . | . | Generated linker scripts as explained above is shown here as an example . | Bootloader length &lt;bootloader_length&gt; in the below snippet is auto generated based on the bootloader component added in MHC | . | . PROVIDE(_vector_spacing = 0x0001); PROVIDE(_ebase_address = 0x9D000000); /* Place the vector table and other exceptions after the device reset and * cache init code. */ PROVIDE(_ebase_vector_offsets = 0x1000); _RESET_ADDR = 0xBFC00000; _BEV_EXCPT_ADDR = 0xBFC00380; _DBG_EXCPT_ADDR = 0xBFC00480; _SIMPLE_TLB_REFILL_EXCPT_ADDR = _ebase_address + _ebase_vector_offsets + 0; _GEN_EXCPT_ADDR = _ebase_address + _ebase_vector_offsets + 0x180; kseg0_program_mem (rx) : ORIGIN = 0x9D000000, LENGTH = &lt;bootloader_length&gt; kseg1_boot_mem : ORIGIN = 0xBFC00000, LENGTH = 0x480 kseg1_boot_mem_4B0 : ORIGIN = 0xBFC004B0, LENGTH = 0x1000 - 0x4B0 ... config_BFC03F40 : ORIGIN = 0xBFC03F40, LENGTH = 0x4 config_BFC03F44 : ORIGIN = 0xBFC03F44, LENGTH = 0x4 config_BFC03F48 : ORIGIN = 0xBFC03F48, LENGTH = 0 SECTIONS { .config_BFC03F40 : { KEEP(*(.config_BFC03F40)) } &gt; config_BFC03F40 .config_BFC03F44 : { KEEP(*(.config_BFC03F44)) } &gt; config_BFC03F44 ..... } /* Boot Sections */ .reset _RESET_ADDR : { KEEP(*(.reset)) KEEP(*(.reset.startup)) } &gt; kseg1_boot_mem ... /* Interrupt vector table with vector offsets */ .vectors _ebase_address + _ebase_vector_offsets + 0x200 : { /* Symbol __vector_offset_n points to .vector_n if it exists, * otherwise points to the default handler. The * vector_offset_init.o module then provides a .data section * containing values used to initialize the vector-offset SFRs * in the crt0 startup code. */ . = ALIGN(4) ; __vector_offset_0 = (DEFINED(__vector_dispatch_0) ? (. - _ebase_address) : __vector_offset_default); KEEP(*(.vector_0)) ..... /* Default interrupt handler */ . = ALIGN(4) ; __vector_offset_default = . - _ebase_address; KEEP(*(.vector_default)) } &gt; kseg0_program_mem . For Bootloaders placed in Boot Flash Memory (PIC32MX Devices) . | The bootloader start address by default will be start of Boot flash memory (0xBFC00000). This is the default startup location for all PIC32M devices . | The Initial 1280 Bytes (0x500) from Bootloader start address are used by Reset Handler and then followed by rest of bootloader code. | Length of the bootloader is calculated based on the bootloader being added to MHC . | In PIC32MX devices the _ebase_address holds the start address of vector table and it must be placed at 4KB boundary after the Reset Handler section . | Generated linker scripts as explained above is shown here as an example. | Bootloader length &lt;bootloader_length&gt; in the below snippet is auto generated based on the bootloader component added in MHC | . | . PROVIDE(_vector_spacing = 0x0001); PROVIDE(_ebase_address = 0x9FC01000); _RESET_ADDR = 0xBFC00000; _BEV_EXCPT_ADDR = 0xBFC00380; _DBG_EXCPT_ADDR = 0xBFC00480; _DBG_CODE_ADDR = 0xBFC02000; _DBG_CODE_SIZE = 0xFF0; _GEN_EXCPT_ADDR = _ebase_address + 0x180; kseg0_program_mem (rx) : ORIGIN = 0x9FC00500, LENGTH = &lt;bootloader_length&gt; kseg1_boot_mem : ORIGIN = 0xBFC00000, LENGTH = 0x490 ... config3 : ORIGIN = 0xBFC02FF0, LENGTH = 0x4 config2 : ORIGIN = 0xBFC02FF4, LENGTH = 0x4 SECTIONS { .config_BFC02FF0 : { KEEP(*(.config_BFC02FF0)) } &gt; config3 .config_BFC02FF4 : { KEEP(*(.config_BFC02FF4)) } &gt; config2 } /* Boot Sections */ .reset _RESET_ADDR : { KEEP(*(.reset)) KEEP(*(.reset.startup)) } &gt; kseg1_boot_mem ...vector_0 _ebase_address + 0x200 + ((_vector_spacing &lt;&lt; 5) * 0) : { KEEP(*(.vector_0)) } &gt; kseg0_program_mem ASSERT (_vector_spacing == 0 || SIZEOF(.vector_0) &lt;= (_vector_spacing &lt;&lt; 5), \\\"function at exception vector 0 too large\\\") .vector_1 _ebase_address + 0x200 + ((_vector_spacing &lt;&lt; 5) * 1) : { KEEP(*(.vector_1)) } &gt; kseg0_program_mem ASSERT (_vector_spacing == 0 || SIZEOF(.vector_1) &lt;= (_vector_spacing &lt;&lt; 5), \\\"function at exception vector 1 too large\\\") ..... For Bootloaders placed in Program Flash Memory (PIC32MX Devices) . | The bootloader start address by default will be start of Boot flash memory (0xBFC00000). This is the default startup location for all PIC32M devices . | As the entire bootloader cannot be placed in BFM, Only the bootloader Reset Handler is placed in BFM. Rest of the bootloader code will be placed from start of Program Flash memory . | The _ebase_address is placed at start of Program flash memory (Example : 0x9D000000) . | Generated linker scripts as explained above is shown here as an example. | Bootloader length &lt;bootloader_length&gt; in the below snippet is auto generated based on the bootloader component added in MHC | . | . PROVIDE(_vector_spacing = 0x0001); PROVIDE(_ebase_address = 0x9D000000); _RESET_ADDR = 0xBFC00000; _BEV_EXCPT_ADDR = 0xBFC00380; _DBG_EXCPT_ADDR = 0xBFC00480; _DBG_CODE_ADDR = 0x9FC00490; _DBG_CODE_SIZE = 0x760; _GEN_EXCPT_ADDR = _ebase_address + 0x180; kseg0_program_mem (rx) : ORIGIN = 0x9D000000, LENGTH = &lt;bootloader_length&gt; kseg1_boot_mem : ORIGIN = 0xBFC00000, LENGTH = 0x490 ... config3 : ORIGIN = 0xBFC00BF0, LENGTH = 0x4 config2 : ORIGIN = 0xBFC00BF4, LENGTH = 0x4 SECTIONS { .config_BFC00BF0 : { KEEP(*(.config_BFC00BF0)) } &gt; config3 .config_BFC00BF4 : { KEEP(*(.config_BFC00BF4)) } &gt; config2 } /* Boot Sections */ .reset _RESET_ADDR : { KEEP(*(.reset)) KEEP(*(.reset.startup)) } &gt; kseg1_boot_mem ...vector_0 _ebase_address + 0x200 + ((_vector_spacing &lt;&lt; 5) * 0) : { KEEP(*(.vector_0)) } &gt; kseg0_program_mem ASSERT (_vector_spacing == 0 || SIZEOF(.vector_0) &lt;= (_vector_spacing &lt;&lt; 5), \\\"function at exception vector 0 too large\\\") .vector_1 _ebase_address + 0x200 + ((_vector_spacing &lt;&lt; 5) * 1) : { KEEP(*(.vector_1)) } &gt; kseg0_program_mem ASSERT (_vector_spacing == 0 || SIZEOF(.vector_1) &lt;= (_vector_spacing &lt;&lt; 5), \\\"function at exception vector 1 too large\\\") ..... Using Both Boot Flash Panels on PIC32MZ device . | For PIC32MZ devices, with two 80 KB Boot Flash panels, bootloader may or may not fit entirely in one Boot Flash panel. | In order to fit some of the Bootloaders, the linker script makes the two Boot Flash panels look like one contiguous Boot Flash memory. Unimplemented areas are blocked using a fill command to the linker . | . kseg0_program_mem (rx) : ORIGIN = 0x9FC01000, LENGTH = 0x2FF00 - 0x1000 /* Bootloader needs to be placed in both the Boot Flash Panels (lower and upper boot alias). Below region is used to fill 0xFF in reserved space between these two panles. */ protected_reg : ORIGIN = 0x9FC14000, LENGTH = 0x20000-0x14000 ..... SECTIONS { .fill1 : { FILL(0xFF); . = ORIGIN(protected_reg) + LENGTH(protected_reg) - 1; BYTE(0xFF) } &gt; protected_reg } . Note . | Device configuration bits should be updated by bootloader only . | The bootloader linker script is generated using generic templates for the device family. Generated linker script should be modified if there any changes or modifications to the specific device being used. | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_linker_config.html#bootloader-linker-script-settings",
    "relUrl": "/templates/mips/docs/mips_bootloader_linker_config.html#bootloader-linker-script-settings"
  },"164": {
    "doc": "Bootloader Linker Configurations",
    "title": "Bootloader Linker Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_linker_config.html",
    "relUrl": "/templates/mips/docs/mips_bootloader_linker_config.html"
  },"165": {
    "doc": "Bootloader Memory Layout For MIPS Based MCUs",
    "title": "Bootloader Memory Layout For MIPS Based MCUs",
    "content": ". | Basic Memory Layout . | Fail Safe Update Memory Layout . | Live Update Memory Layout . | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout.html#bootloader-memory-layout-for-mips-based-mcus",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout.html#bootloader-memory-layout-for-mips-based-mcus"
  },"166": {
    "doc": "Bootloader Memory Layout For MIPS Based MCUs",
    "title": "Bootloader Memory Layout For MIPS Based MCUs",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout.html",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout.html"
  },"167": {
    "doc": "Basic Memory layout",
    "title": "Basic Memory layout for MIPS based MCUs",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_basic.html#basic-memory-layout-for-mips-based-mcus",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_basic.html#basic-memory-layout-for-mips-based-mcus"
  },"168": {
    "doc": "Basic Memory layout",
    "title": "Bootloader placement for various PIC32M product families",
    "content": "The bootloader is placed in Boot Flash Memory (BFM) or Program Flash Memory (PFM) based on the size of the bootloader and available Boot flash memory on the device. | If the bootloader fits into the available BFM, it is placed in BFM. The user application can use the complete area of the program Flash memory. | If the bootloader does not fit into the available BFM, its reset handler is placed in BFM and rest of code is placed in PFM. The user application can use the remaining area of the program Flash memory. | The following table shows the available Boot Flash memory and the placement of different bootloaders by product family. | . Note: . The Boot Flash and Program Flash memory end addresses may vary from device to device. Refer to respective Data sheets for details of Flash memory layout. ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_basic.html#bootloader-placement-for-various-pic32m-product-families",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_basic.html#bootloader-placement-for-various-pic32m-product-families"
  },"169": {
    "doc": "Basic Memory layout",
    "title": "Basic Memory layout",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_basic.html#basic-memory-layout",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_basic.html#basic-memory-layout"
  },"170": {
    "doc": "Basic Memory layout",
    "title": "Additional Information",
    "content": ". | Refer to Configurations for MIPS based MCUs for more information on bootloader linker and application linker configurations | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_basic.html#additional-information",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_basic.html#additional-information"
  },"171": {
    "doc": "Basic Memory layout",
    "title": "Basic Memory layout",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_basic.html",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_basic.html"
  },"172": {
    "doc": "Fail Safe Update Memory layout",
    "title": "Fail Safe Update Memory layout for MIPS based MCUs",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_fail_safe_update.html#fail-safe-update-memory-layout-for-mips-based-mcus",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_fail_safe_update.html#fail-safe-update-memory-layout-for-mips-based-mcus"
  },"173": {
    "doc": "Fail Safe Update Memory layout",
    "title": "Bootloader placement for various PIC32M product families",
    "content": "The bootloader is placed in Boot Flash Memory (BFM) or Program Flash Memory (PFM) based on the size of the bootloader and available Boot flash memory on the device. | If the bootloader fits into the available BFM, it is placed in BFM. The user application can use the complete area of the program Flash memory. | If the bootloader does not fit into the available BFM, its reset handler is placed in BFM and rest of code is placed in PFM. The user application can use the remaining area of the program Flash memory. | The following table shows the available Boot Flash memory and the placement of different bootloaders by product family. | . Note: . The Boot Flash and Program Flash memory end addresses may vary from device to device. Refer to respective Data sheets for details of Flash memory layout. ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_fail_safe_update.html#bootloader-placement-for-various-pic32m-product-families",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_fail_safe_update.html#bootloader-placement-for-various-pic32m-product-families"
  },"174": {
    "doc": "Fail Safe Update Memory layout",
    "title": "Fail Safe Update layout",
    "content": ". | Supported for the devices which have a Dual Bank flash memory . | Bootloader code is placed at start of the Boot flash memory (0xBFC00000) as upon reset the device runs from start of boot flash memory. | Device always executes the application firmware from PFM bank mapped to lower memory region (0x1D00_0000 Physical address) . | Start address of Active Bank is mapped to lower region 0x9D000000 . | Start address of Inactive Bank is from mid of the PFM which can vary from device to device. Refer to respective Data sheets for details of Flash memory layout. | . | Row size number of bytes are reserved at end of each bank for storing serial number. This serial number will be used by the bootloader code placed in BFM to map the appropriate PFM bank to lower memory region and run the application from there . | Volatile register SWAP bit is used to map either of bank to lower memory region by bootloader . | When Bootloader is running it will program the new image in the inactive bank and performs below operation and initiates a reset . | Inactive Serial number = Active serial number + 1 | . | At reset bootloader first maps Bank 1 to lower region and reads the serial numbers from both banks . | If Bank 2 serial number is greater than Bank 1 serial number, it maps Bank 2 to lower region by setting the Swap bit and runs the new firmware. Now Bank 2 is Active bank . | The application start address should always fall into lower mapped region (0x9D000000 to Mid of Flash). Size of the application in the linker script should also not exceed the Mid of flash. | The address passed to bootloader during programming should fall either in active bank or inactive bank based on update being done. | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_fail_safe_update.html#fail-safe-update-layout",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_fail_safe_update.html#fail-safe-update-layout"
  },"175": {
    "doc": "Fail Safe Update Memory layout",
    "title": "Additional Information",
    "content": ". | Refer to Configurations for MIPS based MCUs for more information on bootloader linker and application linker configurations | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_fail_safe_update.html#additional-information",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_fail_safe_update.html#additional-information"
  },"176": {
    "doc": "Fail Safe Update Memory layout",
    "title": "Fail Safe Update Memory layout",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_fail_safe_update.html",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_fail_safe_update.html"
  },"177": {
    "doc": "Live Update Memory layout",
    "title": "Live Update Memory layout for MIPS based MCUs",
    "content": ". | Supported for the devices which have a Dual Bank flash memory . | Switcher code is placed at start of the Boot flash memory (0xBFC00000) as upon reset the device runs from start of boot flash memory. | Note: The switcher code provided does not have any programming capabilities.It just performs bank swap operations | . | Device always executes the application firmware from PFM bank mapped to lower memory region (0x1D00_0000 Physical address) . | Start address of Active Bank is mapped to lower region 0x9D000000 . | Start address of Inactive Bank is from mid of the PFM which can vary from device to device. Refer to respective Data sheets for details of Flash memory layout. | . | Row size number of bytes are reserved at end of each bank for storing serial number. This serial number will be used by the switcher code placed in BFM to map the appropriate PFM bank to lower memory region and run the application from there . | Volatile register SWAP bit is used to map either of bank to lower memory region by switcher . | The bootloader live update code responsible to program the inactive bank is part of the application it self. Which means the programming operation can happen while the application is running . | Live Update Application = (Bootloader Code in Live Update mode + Application code) | . | The application code is responsible to send a request to bootloader live update code to perform a bank swap and reset to run the new firmware programmed in Inactive bank . | Once this request is received the bootloader live update code performs below operation before initiating a reset to run new firmware . | Inactive Serial number = Active serial number + 1 | . | At reset switcher first maps Bank 1 to lower region and reads the serial numbers from both banks . | If Bank 2 serial number is greater than Bank 1 serial number, it maps Bank 2 to lower region by setting the Swap bit and runs the new firmware. Now Bank 2 is Active bank . | The live update start address should always fall into lower mapped region (0x9D000000 to Mid of Flash). Size of the application in the linker script should also not exceed the Mid of flash. | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_live_update.html#live-update-memory-layout-for-mips-based-mcus",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_live_update.html#live-update-memory-layout-for-mips-based-mcus"
  },"178": {
    "doc": "Live Update Memory layout",
    "title": "Additional Information",
    "content": ". | Refer to Configurations for MIPS based MCUs for more information on bootloader linker and application linker configurations | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_live_update.html#additional-information",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_live_update.html#additional-information"
  },"179": {
    "doc": "Live Update Memory layout",
    "title": "Live Update Memory layout",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_bootloader_memory_layout_live_update.html",
    "relUrl": "/templates/mips/docs/mips_bootloader_memory_layout_live_update.html"
  },"180": {
    "doc": "Configurations for MIPS based MCUs",
    "title": "Configurations for MIPS based MCUs",
    "content": ". | Bootloader Linker Script Configurations . | Application Linker Script Configurations . | Application project Configurations . | . ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_configurations.html#configurations-for-mips-based-mcus",
    "relUrl": "/templates/mips/docs/mips_configurations.html#configurations-for-mips-based-mcus"
  },"181": {
    "doc": "Configurations for MIPS based MCUs",
    "title": "Configurations for MIPS based MCUs",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/mips/docs/mips_configurations.html",
    "relUrl": "/templates/mips/docs/mips_configurations.html"
  },"182": {
    "doc": "License",
    "title": "License",
    "content": "IMPORTANT: READ CAREFULLY . MICROCHIP IS WILLING TO LICENSE THIS INTEGRATED SOFTWARE FRAMEWORK SOFTWARE AND ACCOMPANYING DOCUMENTATION OFFERED TO YOU ONLY ON THE CONDITION THAT YOU ACCEPT ALL OF THE FOLLOWING TERMS. TO ACCEPT THE TERMS OF THIS LICENSE, CLICK “I ACCEPT” AND PROCEED WITH THE DOWNLOAD OR INSTALL. IF YOU DO NOT ACCEPT THESE LICENSE TERMS, CLICK “I DO NOT ACCEPT,” AND DO NOT DOWNLOAD OR INSTALL THIS SOFTWARE. NON-EXCLUSIVE SOFTWARE LICENSE AGREEMENT FOR MICROCHIP MPLAB HARMONY INTEGRATED SOFTWARE FRAMEWORK . This Nonexclusive Software License Agreement (“Agreement”) is between you, your heirs, agents, successors and assigns (“Licensee”) and Microchip Technology Incorporated, a Delaware corporation, with a principal place of business at 2355 W. Chandler Blvd., Chandler, AZ 85224-6199, and its subsidiary, Microchip Technology (Barbados) II Incorporated (collectively, “Microchip”) for Microchip’s MPLAB Harmony Integrated Software Framework (“Software”) and accompanying documentation (“Documentation”). The Software and Documentation are licensed under this Agreement and not sold. U.S. copyright laws and international copyright treaties, and other intellectual property laws and treaties protect the Software and Documentation. Microchip reserves all rights not expressly granted to Licensee in this Agreement. | License and Sublicense Grant. (a) Definitions. As used this Agreement, the following terms shall have the meanings defined below: . (i) \\\"Licensee Products\\\" means Licensee products that use or incorporate Microchip Products. (ii) \\\"Microchip Product\\\" means Microchip 16-bit and 32-bit microcontrollers, digital signal controllers or other Microchip semiconductor products with PIC16 and PIC18 prefix and specifically excepting the CX870 and CY920, which are not covered under this Agreement, that use or implement the Software. (iii) \\\"Object Code\\\" means the Software computer programming code provided by Microchip that is in binary form (including related documentation, if any) and error corrections, improvements and updates to such code provided by Microchip in its sole discretion, if any. (iv) \\\"Source Code\\\" means the Software computer programming code provided by Microchip that may be printed out or displayed in human readable form (including related programmer comments and documentation, if any), and error corrections, improvements, updates, modifications and derivatives of such code developed by Microchip, Licensee or Third Party. (v) \\\"Third Party\\\" means Licensee's agents, representatives, consultants, clients, customers, or contract manufacturers. (vi) \\\"Third Party Products\\\" means Third Party products that use or incorporate Microchip Products. (b) Software License Grant. Subject to the terms of this Agreement, Microchip grants strictly to Licensee a personal, worldwide, non-exclusive, non-transferable limited license to use, modify (except as limited by Section 1(f) below), copy and distribute the Software only when the Software is embedded on a Microchip Product that is integrated into Licensee Product or Third Party Product pursuant to Section 2(d) below. Any portion of the Software (including derivatives or modifications thereof) may not be: . (i) embedded on a non-Microchip microcontroller or digital signal controller; (ii) distributed (in Source Code or Object Code), except as described in Section 2(d) below. (c) Documentation License Grant. Subject to all of the terms and conditions of this Agreement, Microchip grants strictly to Licensee a perpetual, worldwide, non-exclusive license to use the Documentation in support of Licensee’s use of the Software. (d) Sublicense Grants. Subject to terms of this Agreement, Licensee may grant a limited sublicense to a Third Party to use the Software as described below only if such Third Party expressly agrees to be bound by terms of confidentiality and limited use that are no broader in scope and duration than the confidentiality and limited use terms of this Agreement: . (i) Third Party may modify Source Code for Licensee, except as limited by Section 1(f) below. (ii) Third Party may program Software into Microchip Products for Licensee. (iii) Third Party may use Software to develop and/or manufacture Licensee Product. (iv) Third Party may use Software to develop and/or manufacture Third Party Products where either: (x) the sublicensed Software contains Source Code modified or otherwise optimized by Licensee for Third Party use; or (y) the sublicensed Software is programmed into Microchip Products by Licensee on behalf of such Third Party. (v) Third Party may use the Documentation in support of Third Party's authorized use of the Software in conformance with this Section 2(d). (e) Audit. Authorized representatives of Microchip shall have the right to reasonably inspect Licensee’s premises and to audit Licensee’s records and inventory of Licensee Products, whether located on Licensee’s premises or elsewhere at any time, announced or unannounced, and in its sole and absolute discretion, in order to ensure Licensee’s adherence to the terms of this Agreement. (f) License and Sublicense Limitation. This Section 1 does not grant Licensee or any Third Party the right to modify any dotstack™ Bluetooth® stack, profile, or iAP protocol included in the Software. | Third Party Requirements. Licensee acknowledges that it is Licensee’s responsibility to comply with any third party license terms or requirements applicable to the use of such third party software, specifications, systems, or tools, including but not limited to SEGGER Microcontroller GmbH &amp; Co. KG’s rights in the emWin software and certain libraries included herein. Microchip is not responsible and will not be held responsible in any manner for Licensee’s failure to comply with such applicable terms or requirements. | Open Source Components. Notwithstanding the license grants contained herein, Licensee acknowledges that certain components of the Software may be covered by so-called “open source” software licenses (“Open Source Components”). Open Source Components means any software licenses approved as open source licenses by the Open Source Initiative or any substantially similar licenses, including any license that, as a condition of distribution, requires Microchip to provide Licensee with certain notices and/or information related to such Open Source Components, or requires that the distributor make the software available in source code format. Microchip will use commercially reasonable efforts to identify such Open Source Components in a text file or “About Box” or in a file or files referenced thereby (and will include any associated license agreement, notices, and other related information therein), or the Open Source Components will contain or be accompanied by its own license agreement. To the extent required by the licenses covering Open Source Components, the terms of such licenses will apply in lieu of the terms of this Agreement, and Microchip hereby represents and warrants that the licenses granted to such Open Source Components will be no less broad than the license granted in Section 1(b). To the extent the terms of the licenses applicable to Open Source Components prohibit any of the restrictions in this Agreement with respect to such Open Source Components, such restrictions will not apply to such Open Source Components. | Licensee’s Obligations. (a) Licensee will ensure Third Party compliance with the terms of this Agreement. (b) Licensee will not: (i) engage in unauthorized use, modification, disclosure or distribution of Software or Documentation, or its derivatives; (ii) use all or any portion of the Software, Documentation, or its derivatives except in conjunction with Microchip Products; or (iii) reverse engineer (by disassembly, decompilation or otherwise) Software or any portion thereof; or (iv) copy or reproduce all or any portion of Software, except as specifically allowed by this Agreement or expressly permitted by applicable law notwithstanding the foregoing limitations. (c) Licensee must include Microchip’s copyright, trademark and other proprietary notices in all copies of the Software, Documentation, and its derivatives. Licensee may not remove or alter any Microchip copyright or other proprietary rights notice posted in any portion of the Software or Documentation. (d) Licensee will defend, indemnify and hold Microchip and its subsidiaries harmless from and against any and all claims, costs, damages, expenses (including reasonable attorney’s fees), liabilities, and losses, including without limitation product liability claims, directly or indirectly arising from or related to: (i) the use, modification, disclosure or distribution of the Software, Documentation or any intellectual property rights related thereto; (ii) the use, sale, and distribution of Licensee Products or Third Party Products, and (iii) breach of this Agreement. THE FOREGOING STATES THE SOLE AND EXCLUSIVE LIABILITY OF THE PARTIES FOR INTELLECTUAL PROPERTY RIGHTS INFRINGEMENT. | Confidentiality. (a) Licensee agrees that the Software (including but not limited to the Source Code, Object Code and library files) and its derivatives, Documentation and underlying inventions, algorithms, know-how and ideas relating to the Software and the Documentation are proprietary information belonging to Microchip and its licensors (“Proprietary Information”). Except as expressly and unambiguously allowed herein, Licensee will hold in confidence and not use or disclose any Proprietary Information and shall similarly bind its employees and Third Party(ies) in writing. Proprietary Information shall not include information that: (i) is in or enters the public domain without breach of this Agreement and through no fault of the receiving party; (ii) the receiving party was legally in possession of prior to receiving it; (iii) the receiving party can demonstrate was developed by it independently and without use of or reference to the disclosing party’s Proprietary Information; or (iv) the receiving party receives from a third party without restriction on disclosure. If Licensee is required to disclose Proprietary Information by law, court order, or government agency, such disclosure shall not be deemed a breach of this Agreement provided that Licensee gives Microchip prompt notice of such requirement in order to allow Microchip to object or limit such disclosure, Licensee cooperates with Microchip to protect Proprietary Information, and Licensee complies with any protective order in place and discloses only the information required by process of law. (b) Licensee agrees that the provisions of this Agreement regarding unauthorized use and nondisclosure of the Software, Documentation and related Proprietary Rights are necessary to protect the legitimate business interests of Microchip and its licensors and that monetary damages alone cannot adequately compensate Microchip or its licensors if such provisions are violated. Licensee, therefore, agrees that if Microchip alleges that Licensee or Third Party has breached or violated such provision then Microchip will have the right to petition for injunctive relief, without the requirement for the posting of a bond, in addition to all other remedies at law or in equity. | Ownership of Proprietary Rights. (a) Microchip and its licensors retain all right, title and interest in and to the Software and Documentation (“Proprietary Rights”) including, but not limited to: (i) patent, copyright, trade secret and other intellectual property rights in the Software, Documentation, and underlying technology; (ii) the Software as implemented in any device or system, all hardware and software implementations of the Software technology (expressly excluding Licensee and Third Party code developed and used in conformance with this Agreement solely to interface with the Software and Licensee Products and/or Third Party Products); and (iii) all modifications and derivative works thereof (by whomever produced). Further, modifications and derivative works shall be considered works made for hire with ownership vesting in Microchip on creation. To the extent such modifications and derivatives do not qualify as a “work for hire,” Licensee hereby irrevocably transfers, assigns and conveys the exclusive copyright thereof to Microchip, free and clear of any and all liens, claims or other encumbrances, to the fullest extent permitted by law. Licensee and Third Party use of such modifications and derivatives is limited to the license rights described in Section 1 above. (b) Licensee shall have no right to sell, assign or otherwise transfer all or any portion of the Software, Documentation or any related intellectual property rights except as expressly set forth in this Agreement. | Termination of Agreement. Without prejudice to any other rights, this Agreement terminates immediately, without notice by Microchip, upon a failure by License or Third Party to comply with any provision of this Agreement. Further, Microchip may also terminate this Agreement upon reasonable belief that Licensee or Third Party have failed to comply with this Agreement. Upon termination, Licensee and Third Party will immediately stop using the Software, Documentation, and derivatives thereof, and immediately destroy all such copies, remove Software from any of Licensee’s tangible media and from systems on which the Software exists, and stop using, disclosing, copying, or reproducing Software (even as may be permitted by this Agreement). Termination of this Agreement will not affect the right of any end user or consumer to use Licensee Products or Third Party Products provided that such products were purchased prior to the termination of this Agreement. | Dangerous Applications. The Software is not fault-tolerant and is not designed, manufactured, or intended for use in hazardous environments requiring failsafe performance (“Dangerous Applications”). Dangerous Applications include the operation of nuclear facilities, aircraft navigation, aircraft communication systems, air traffic control, direct life support machines, weapons systems, or any environment or system in which the failure of the Software could lead directly or indirectly to death, personal injury, or severe physical or environmental damage. Microchip specifically disclaims (a) any express or implied warranty of fitness for use of the Software in Dangerous Applications; and (b) any and all liability for loss, damages and claims resulting from the use of the Software in Dangerous Applications. | Warranties and Disclaimers. THE SOFTWARE AND DOCUMENTATION ARE PROVIDED “AS IS” WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. MICROCHIP AND ITS LICENSORS ASSUME NO RESPONSIBILITY FOR THE ACCURACY, RELIABILITY OR APPLICATION OF THE SOFTWARE OR DOCUMENTATION. MICROCHIP AND ITS LICENSORS DO NOT WARRANT THAT THE SOFTWARE WILL MEET REQUIREMENTS OF LICENSEE OR THIRD PARTY, BE UNINTERRUPTED OR ERROR-FREE. MICROCHIP AND ITS LICENSORS HAVE NO OBLIGATION TO CORRECT ANY DEFECTS IN THE SOFTWARE. LICENSEE AND THIRD PARTY ASSUME THE ENTIRE RISK ARISING OUT OF USE OR PERFORMANCE OF THE SOFTWARE AND DOCUMENTATION PROVIDED UNDER THIS AGREEMENT. | Limited Liability. IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL OR EQUITABLE THEORY FOR ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED TO INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS. The aggregate and cumulative liability of Microchip and its licensors for damages hereunder will in no event exceed $1000 or the amount Licensee paid Microchip for the Software and Documentation, whichever is greater. Licensee acknowledges that the foregoing limitations are reasonable and an essential part of this Agreement. | General. (a) Governing Law, Venue and Waiver of Trial by Jury. THIS AGREEMENT SHALL BE GOVERNED BY AND CONSTRUED UNDER THE LAWS OF THE STATE OF ARIZONA AND THE UNITED STATES WITHOUT REGARD TO CONFLICTS OF LAWS PROVISIONS. Licensee agrees that any disputes arising out of or related to this Agreement, Software or Documentation shall be brought in the courts of State of Arizona. The parties agree to waive their rights to a jury trial in actions relating to this Agreement. (b) Attorneys’ Fees. If either Microchip or Licensee employs attorneys to enforce any rights arising out of or relating to this Agreement, the prevailing party shall be entitled to recover its reasonable attorneys’ fees, costs and other expenses. (c) Entire Agreement. This Agreement shall constitute the entire agreement between the parties with respect to the subject matter hereof. It shall not be modified except by a written agreement signed by an authorized representative of Microchip. (d) Severability. If any provision of this Agreement shall be held by a court of competent jurisdiction to be illegal, invalid or unenforceable, that provision shall be limited or eliminated to the minimum extent necessary so that this Agreement shall otherwise remain in full force and effect and enforceable. (e) Waiver. No waiver of any breach of any provision of this Agreement shall constitute a waiver of any prior, concurrent or subsequent breach of the same or any other provisions hereof, and no waiver shall be effective unless made in writing and signed by an authorized representative of the waiving party. (f) Export Regulation. Licensee agrees to comply with all export laws and restrictions and regulations of the Department of Commerce or other United States or foreign agency or authority. (g) Survival. The indemnities, obligations of confidentiality, and limitations on liability described herein, and any right of action for breach of this Agreement prior to termination shall survive any termination of this Agreement. (h) Assignment. Neither this Agreement nor any rights, licenses or obligations hereunder, may be assigned by Licensee without the prior written approval of Microchip except pursuant to a merger, sale of all assets of Licensee or other corporate reorganization, provided that assignee agrees in writing to be bound by the Agreement. (i) Restricted Rights. Use, duplication or disclosure by the United States Government is subject to restrictions set forth in subparagraphs (a) through (d) of the Commercial Computer-Restricted Rights clause of FAR 52.227-19 when applicable, or in subparagraph (c)(1)(ii) of the Rights in Technical Data and Computer Software clause at DFARS 252.227-7013, and in similar clauses in the NASA FAR Supplement. Contractor/manufacturer is Microchip Technology Inc., 2355 W. Chandler Blvd., Chandler, AZ 85225-6199. | . If Licensee has any questions about this Agreement, please write to Microchip Technology Inc., 2355 W. Chandler Blvd., Chandler, AZ 85224-6199 USA, ATTN: Marketing. Microchip MPLAB Harmony Integrated Software Framework. Copyright © 2015 Microchip Technology Inc. All rights reserved. License Rev. 11/2015 . Copyright © 2015 Qualcomm Atheros, Inc. All Rights Reserved. Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies. THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE. ",
    "url": "http://localhost:4000/bootloader/mplab_harmony_license.html",
    "relUrl": "/mplab_harmony_license.html"
  },"183": {
    "doc": "CAN Bootloader",
    "title": "CAN Bootloader",
    "content": "The CAN bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger. ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/readme.html#can-bootloader",
    "relUrl": "/templates/src/optimized/docs/can/readme.html#can-bootloader"
  },"184": {
    "doc": "CAN Bootloader",
    "title": "Features",
    "content": ". | Supported on CORTEX-M based MCUs | Uses Harmony 3 CAN PLIB to communicate resulting in smaller bootloader size | Supports Fail Safe update | Takes Binary File as input | Receives Binary from an C Embedded Host Device | . Running From SRAM (For SAM Devices) . | Has capability to self update as it is running from SRAM . | At reset the bootloader Reset handler copies the entire bootloader firmware into SRAM from Start location and start executing from SRAM | Once the application is called from bootloader, applications startup code takes control over SRAM and starts executing | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/readme.html#features",
    "relUrl": "/templates/src/optimized/docs/can/readme.html#features"
  },"185": {
    "doc": "CAN Bootloader",
    "title": "CAN Bootloader Block Diagram",
    "content": ". | Input Task: . | This task is responsible for receiving data from Embedded Host through the CAN interface . | The task keeps polling for data to be received when bootloader is in idle mode . | Once the packet reception is completed it gives control to Command Task . | . | Command Task: . | The task first validates the incoming packet from host with expected header information . | The task processes the commands received from Input Task and provides response back to host accordingly . | If the command received is a Data command it gives control to the Flash Task . | . | Flash Task: . | This task is responsible to program the internal flash memory with data packet received . | The task uses the NVM peripheral library to perform the Unlock/Erase/Write Operations . | . | . | Topic | Description | . | How The Library Works | This section describes how the CAN Bootloader Library Works | . | Bootloader System Execution Flow | This section describes the bootloader system level execution flow | . | Bootloader Configurations | This section provides information on how to configure CAN Bootloader library | . | Application Configurations | This section provides information on how to configure an application to be bootloaded | . | Library Interface | This section describes the Application Programming Interface (API) functions of the CAN Bootloader library | . | Tools Help | This section provides information on Host script used for CAN bootloader | . | Debugging Help | This section provides information on debugging CAN bootloader and application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/readme.html#can-bootloader-block-diagram",
    "relUrl": "/templates/src/optimized/docs/can/readme.html#can-bootloader-block-diagram"
  },"186": {
    "doc": "CAN Bootloader",
    "title": "CAN Bootloader",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/can/readme.html",
    "relUrl": "/templates/src/optimized/docs/can/readme.html"
  },"187": {
    "doc": "I2C Bootloader",
    "title": "I2C Bootloader",
    "content": "The I2C bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger. ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/readme.html#i2c-bootloader",
    "relUrl": "/templates/src/optimized/docs/i2c/readme.html#i2c-bootloader"
  },"188": {
    "doc": "I2C Bootloader",
    "title": "Features",
    "content": ". | Supported Only on CortexM0+ and CortexM4 based Devices | Uses Harmony 3 I2C PLIB to communicate resulting in smaller bootloader size | Supports Fail Safe update | Takes Binary File as input | Receives Binary from an I2C Embedded Host Device | . Running From SRAM (For SAM Devices) . | Has capability to self update as it is running from SRAM . | At reset the bootloader Reset handler copies the entire bootloader firmware into SRAM from Start location and start executing from SRAM | Once the application is called from bootloader, applications startup code takes control over SRAM and starts executing | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/readme.html#features",
    "relUrl": "/templates/src/optimized/docs/i2c/readme.html#features"
  },"189": {
    "doc": "I2C Bootloader",
    "title": "I2C Bootloader Block Diagram",
    "content": ". | I2C Event Processor Task: . | This task is responsible for receiving data from Embedded Host through the I2C communication interface . | The task polls and processes the I2C events. | Based on the event received it gives control to I2C Master Write Request or I2C Master Read Request functions . | This task is responsible for responding to the bootloader commands received . | . | I2C Master Write Request: . | This function is responsible to handle any write requests coming from I2C master . | It processes the commands received and notifies the status to I2C Event Process Task . | If the command received is a Erase/Prgram/Verify command it gives control to the Flash task . | . | I2C Master Read Request: . | This function is responsible to handle any read requests coming from I2C master . | It sends the current status to I2C master if the command received is Read Status . | . | Flash Task: . | This task is responsible to Erase/Prgram/Verify the internal flash memory with data packet received . | The task uses the NVM peripheral library to perform the Unlock/Erase/Write Operations . | . | . | Topic | Description | . | How The Library Works | This section describes how the I2C Bootloader Library Works | . | Bootloader System Execution Flow | This section describes the bootloader system level execution flow | . | Bootloader Configurations | This section provides information on how to configure I2C Bootloader library | . | Application Configurations | This section provides information on how to configure an application to be bootloaded | . | Library Interface | This section describes the Application Programming Interface (API) functions of the I2C Bootloader library | . | Tools Help | This section provides information on Host script used for I2C bootloader | . | Debugging Help | This section provides information on debugging I2C bootloader and application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/readme.html#i2c-bootloader-block-diagram",
    "relUrl": "/templates/src/optimized/docs/i2c/readme.html#i2c-bootloader-block-diagram"
  },"190": {
    "doc": "I2C Bootloader",
    "title": "I2C Bootloader",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/i2c/readme.html",
    "relUrl": "/templates/src/optimized/docs/i2c/readme.html"
  },"191": {
    "doc": "Serial Memory Bootloader",
    "title": "Serial Memory Bootloader",
    "content": "The Serial Memory bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger. ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/readme.html#serial-memory-bootloader",
    "relUrl": "/templates/src/optimized/docs/serial_memory/readme.html#serial-memory-bootloader"
  },"192": {
    "doc": "Serial Memory Bootloader",
    "title": "Features",
    "content": ". | Supported on CORTEX-M and MIPS based MCUs . | Uses Harmony 3 Serial Memory drivers to communicate with the associated serial memory. Below are the serial memory drivers used . | I2C EEPROM: AT24 Driver | SPI EEPROM: AT25 Driver | SPI Flash: SST26 Driver | QSPI Flash: SST26 Driver | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/readme.html#features",
    "relUrl": "/templates/src/optimized/docs/serial_memory/readme.html#features"
  },"193": {
    "doc": "Serial Memory Bootloader",
    "title": "Serial Memory Bootloader Block Diagram",
    "content": ". | Bootloader Task . | Uses Serial Memory driver to reads the application binary stored in serial memory. | Erases the Internal Flash memory . | Programs the read binary into Flash memory . | Verifies the programed application . | Jumps to the Application . | Runs in Cooperative mode with other tasks in the system . | . | . | Topic | Description | . | How The Library Works | This section describes how the Serial Memory Bootloader Library Works | . | Bootloader Execution Flow | This section describes the bootloader execution flow | . | Bootloader Configurations | This section provides information on how to configure Serial Memory Bootloader library | . | Application Configurations | This section provides information on how to configure an application to be bootloaded | . | Library Interface | This section describes the Application Programming Interface (API) functions of the Serial Memory Bootloader library | . | Debugging Help | This section provides information on debugging Serial Memory bootloader and application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/readme.html#serial-memory-bootloader-block-diagram",
    "relUrl": "/templates/src/optimized/docs/serial_memory/readme.html#serial-memory-bootloader-block-diagram"
  },"194": {
    "doc": "Serial Memory Bootloader",
    "title": "Serial Memory Bootloader",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/readme.html",
    "relUrl": "/templates/src/optimized/docs/serial_memory/readme.html"
  },"195": {
    "doc": "File System Bootloader",
    "title": "File System Bootloader",
    "content": "The File System bootloader library can be used to upgrade firmware on a target device without the need for an external programmer or debugger. ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/readme.html#file-system-bootloader",
    "relUrl": "/templates/src/fs/docs/readme.html#file-system-bootloader"
  },"196": {
    "doc": "File System Bootloader",
    "title": "Features",
    "content": ". | Supported on CORTEX-M and MIPS based MCUs | Uses Harmony 3 File System Service to communicate with underlying media | Takes Binary File as input | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/readme.html#features",
    "relUrl": "/templates/src/fs/docs/readme.html#features"
  },"197": {
    "doc": "File System Bootloader",
    "title": "File System Bootloader Block Diagram",
    "content": ". | Bootloader Task . | Uses File System Service to read the Binary file from the media . | Erases the Flash memory . | Programs the binary into Flash memory . | Jumps to the Application . | Runs in Cooperative mode with other tasks in the system . | . | Supported Medias: . | USB Host MSD | SDCARD | Serial Memory . | I2C EEPROM | SPI EEPROM | SPI Flash | QSPI Flash | . | . | . | Topic | Description | . | How The Library Works | This section describes how the File System Bootloader Library Works | . | Bootloader System Execution Flow | This section describes the bootloader system level execution flow | . | USB Host MSD Bootloader Configurations | This section provides information on how to configure File System Bootloader library with USB Host MSD Media | . | SD Card Bootloader Configurations | This section provides information on how to configure File System Bootloader library with SD Card Media | . | Serial Memory Bootloader Configurations | This section provides information on how to configure File System Bootloader library with Serial Memory Media | . | Application Configurations | This section provides information on how to configure an application to be bootloaded | . | Library Interface | This section describes the Application Programming Interface (API) functions of the File System Bootloader library | . | Debugging Help | This section provides information on debugging File System bootloader and application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/readme.html#file-system-bootloader-block-diagram",
    "relUrl": "/templates/src/fs/docs/readme.html#file-system-bootloader-block-diagram"
  },"198": {
    "doc": "File System Bootloader",
    "title": "File System Bootloader",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/fs/docs/readme.html",
    "relUrl": "/templates/src/fs/docs/readme.html"
  },"199": {
    "doc": "Bootloader Applications Help",
    "title": "Bootloader Application Repositories",
    "content": "| Repo name | Description | . | bootloader_apps_uart | UART Bootloader Applications | . | bootloader_apps_i2c | I2C Bootloader Applications | . | bootloader_apps_can | CAN Bootloader Applications | . | bootloader_apps_usb | USB Bootloader Applications | . | bootloader_apps_ethernet | Ethernet Bootloader Applications | . | bootloader_apps_sdcard | SDCARD Bootloader Applications | . | bootloader_apps_serial_memory | Serial Memory Bootloader Applications | . ",
    "url": "http://localhost:4000/bootloader/apps/readme.html#bootloader-application-repositories",
    "relUrl": "/apps/readme.html#bootloader-application-repositories"
  },"200": {
    "doc": "Bootloader Applications Help",
    "title": "Bootloader Applications Help",
    "content": ". Microchip MPLAB Harmony provides several application examples for supported bootloaders. See the following repositories under Microchip-MPLAB-Harmony Github project for specific bootloader application examples: . ",
    "url": "http://localhost:4000/bootloader/apps/readme.html",
    "relUrl": "/apps/readme.html"
  },"201": {
    "doc": "Tools Help",
    "title": "Tools Help",
    "content": "This document describes the usage of bootloader host tools . ",
    "url": "http://localhost:4000/bootloader/tools/readme.html#tools-help",
    "relUrl": "/tools/readme.html#tools-help"
  },"202": {
    "doc": "Tools Help",
    "title": "Downloading the host tools",
    "content": "To clone or download these host tools from Github,go to the main page of this repository and then click Clone button to clone this repo or download as zip file. This content can also be download using content manager by following these instructions . Following host tools are provided to be used with different bootloaders . | Host Script | Description | . | btl_host.py | Used to communicate with the Bootloader running on the device via UART interface | . | btl_app_merge_bin.py | Used to merge the bootloader binary and application binary | . | btl_bin_to_c_array.py | Used to convert the binary output to a C style array containing Hex output | . | UnifiedHost for UDP | Used to communicate with the UDP Bootloader running on the device | . | UnifiedHost for USB Device HID | Used to communicate with the USB Device HID Bootloader running on the device | . ",
    "url": "http://localhost:4000/bootloader/tools/readme.html#downloading-the-host-tools",
    "relUrl": "/tools/readme.html#downloading-the-host-tools"
  },"203": {
    "doc": "Tools Help",
    "title": "Tools Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/tools/readme.html",
    "relUrl": "/tools/readme.html"
  },"204": {
    "doc": "USB Device HID Bootloader",
    "title": "USB Device HID Bootloader",
    "content": "The USB Device HID bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger. ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/readme.html#usb-device-hid-bootloader",
    "relUrl": "/templates/src/unified/docs/usb/readme.html#usb-device-hid-bootloader"
  },"205": {
    "doc": "USB Device HID Bootloader",
    "title": "Features",
    "content": ". | Supported on CORTEX-M and MIPS based MCUs | Uses Harmony 3 USB Device HID driver to communicate | Supports Live update | Takes Normalized Hex File as input | Uses Unified Host application to receive the hex file from Host PC | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/readme.html#features",
    "relUrl": "/templates/src/unified/docs/usb/readme.html#features"
  },"206": {
    "doc": "USB Device HID Bootloader",
    "title": "USB Device HID Bootloader Block Diagram",
    "content": ". The Bootloader framework is divided into 2 sub-systems . | Bootloader Task: . | Erases the Flash memory . | Programs the hex file records into Flash memory . | Computes a CRC check of the Application in Program Memory . | Jumps to the Application . | Calls the DataStream Task at end of its every state machine execution . | This Task routine takes an interface-agnostic approach to the actual communication medium . | Runs in Cooperative mode with other tasks in the system . | . | Datastream Task: . | This Task implements the USB Device HID communication interface to the receive the hex file from the Unified Host Application running on Host PC . | This Task is called from Bootloader Task routine . | . | . | Topic | Description | . | How The Library Works | This section describes how the USB Device HID Bootloader Library Works | . | Bootloader System Execution Flow | This section describes the bootloader system level execution flow | . | Bootloader Configurations | This section provides information on how to configure USB Device HID Bootloader library | . | Application Configurations | This section provides information on how to configure an application to be bootloaded | . | Library Interface | This section describes the Application Programming Interface (API) functions of the USB Device HID Bootloader library | . | Tools Help | This section provides information on Host script used for USB Device HID bootloader | . | Debugging Help | This section provides information on debugging USB Device HID bootloader and application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/readme.html#usb-device-hid-bootloader-block-diagram",
    "relUrl": "/templates/src/unified/docs/usb/readme.html#usb-device-hid-bootloader-block-diagram"
  },"207": {
    "doc": "USB Device HID Bootloader",
    "title": "USB Device HID Bootloader",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/readme.html",
    "relUrl": "/templates/src/unified/docs/usb/readme.html"
  },"208": {
    "doc": "UDP Bootloader",
    "title": "UDP Bootloader",
    "content": "The UDP bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger. ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/readme.html#udp-bootloader",
    "relUrl": "/templates/src/unified/docs/udp/readme.html#udp-bootloader"
  },"209": {
    "doc": "UDP Bootloader",
    "title": "Features",
    "content": ". | Supported on CORTEX-M and MIPS based MCUs | Uses Harmony 3 TCIP Stack to communicate | Supports Live update | Takes Normalized Hex File as input | Uses Unified Host application to receive the hex file from Host PC | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/readme.html#features",
    "relUrl": "/templates/src/unified/docs/udp/readme.html#features"
  },"210": {
    "doc": "UDP Bootloader",
    "title": "UDP Bootloader Block Diagram",
    "content": ". The Bootloader framework is divided into 2 sub-systems . | Bootloader Task: . | Erases the Flash memory . | Programs the hex file records into Flash memory . | Computes a CRC check of the Application in Program Memory . | Jumps to the Application . | Calls the DataStream Task at end of its every state machine execution . | This Task routine takes an interface-agnostic approach to the actual communication medium . | Runs in Cooperative mode with other tasks in the system . | . | Datastream Task: . | This Task implements the UDP communication interface to the receive the hex file from the Unified Host Application running on Host PC . | This Task is called from Bootloader Task routine . | . | . | Topic | Description | . | How The Library Works | This section describes how the UDP Bootloader Library Works | . | Bootloader System Execution Flow | This section describes the bootloader system level execution flow | . | Bootloader Configurations | This section provides information on how to configure UDP Bootloader library | . | Application Configurations | This section provides information on how to configure an application to be bootloaded | . | Library Interface | This section describes the Application Programming Interface (API) functions of the UDP Bootloader library | . | Tools Help | This section provides information on Host script used for UDP bootloader | . | Debugging Help | This section provides information on debugging UDP bootloader and application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/readme.html#udp-bootloader-block-diagram",
    "relUrl": "/templates/src/unified/docs/udp/readme.html#udp-bootloader-block-diagram"
  },"211": {
    "doc": "UDP Bootloader",
    "title": "UDP Bootloader",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/readme.html",
    "relUrl": "/templates/src/unified/docs/udp/readme.html"
  },"212": {
    "doc": "UART Bootloader",
    "title": "UART Bootloader",
    "content": "The UART bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger. ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/readme.html#uart-bootloader",
    "relUrl": "/templates/src/optimized/docs/uart/readme.html#uart-bootloader"
  },"213": {
    "doc": "UART Bootloader",
    "title": "Features",
    "content": ". | Supported on CORTEX-M and MIPS based MCUs | Uses Harmony 3 UART PLIB to communicate resulting in smaller bootloader size | Supports Fail Safe update | Takes Binary File as input | Uses command line host script to receive binary from Host PC | . Running From SRAM (For SAM Devices) . | Supports simultaneous Flash memory write and reception of the next block of data, Achieved by loading bootloader into flash and running from SRAM . | Has capability to self update as it is running from SRAM . | At reset the bootloader Reset handler copies the entire bootloader firmware into SRAM from Start location and start executing from SRAM | Once the application is called from bootloader, applications startup code takes control over SRAM and starts executing | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/readme.html#features",
    "relUrl": "/templates/src/optimized/docs/uart/readme.html#features"
  },"214": {
    "doc": "UART Bootloader",
    "title": "UART Bootloader Block Diagram",
    "content": ". | Input Task: . | This task is responsible for receiving data from Embedded Host through the UART communication interface . | The task keeps polling for data to be received when bootloader is in idle mode . | The task also validates the incoming packet from host with expected header information . | Once the packet reception is completed it gives control to Command Task . | . | Command Task: . | This task processes the commands received from Input Task and provides response back to host accordingly . | If the command received is a Data command it gives control to the Flash Task . | . | Flash Task: . | This task is responsible to program the internal flash memory with data packet received . | The task uses the NVM peripheral library to perform the Unlock/Erase/Write Operations . | The task also invokes Input Task in parallel to receive next packet while waiting for the flash operation to complete for CORTEX-M based MCUs . | . | . | Topic | Description | . | How The Library Works | This section describes how the UART Bootloader Library Works | . | Bootloader System Execution Flow | This section describes the bootloader system level execution flow | . | Bootloader Configurations | This section provides information on how to configure UART Bootloader library | . | Application Configurations | This section provides information on how to configure an application to be bootloaded | . | Library Interface | This section describes the Application Programming Interface (API) functions of the UART Bootloader library | . | Tools Help | This section provides information on Host script used for UART bootloader | . | Debugging Help | This section provides information on debugging UART bootloader and application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/readme.html#uart-bootloader-block-diagram",
    "relUrl": "/templates/src/optimized/docs/uart/readme.html#uart-bootloader-block-diagram"
  },"215": {
    "doc": "UART Bootloader",
    "title": "UART Bootloader",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/readme.html",
    "relUrl": "/templates/src/optimized/docs/uart/readme.html"
  },"216": {
    "doc": "Tools Help",
    "title": "UDP Bootloader Unified Host Script Help",
    "content": " ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_udp.html#udp-bootloader-unified-host-script-help",
    "relUrl": "/tools/docs/readme_UnifiedHost_udp.html#udp-bootloader-unified-host-script-help"
  },"217": {
    "doc": "Tools Help",
    "title": "Downloading the host script",
    "content": "To clone or download these host tools from Github,go to the main page of this repository and then click Clone button to clone this repo or download as zip file. This content can also be download using content manager by following these instructions . Path of the tool within the repository is tools/UnifiedHost-*/UnifiedHost-*.jar . Version and Support information . | Refer to tools/UnifiedHost-*/readme.txt for information on versions and known issues if any . | UART Protocol is not supported in Harmony 3 using this tool . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_udp.html#downloading-the-host-script",
    "relUrl": "/tools/docs/readme_UnifiedHost_udp.html#downloading-the-host-script"
  },"218": {
    "doc": "Tools Help",
    "title": "Description",
    "content": ". | This host script should be used to communicate with the UDP Bootloader running on the device . | It implements the Unified bootloader protocol required to communicate from host PC . | It sends the Normalized Hex File of the application to be bootloaded . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_udp.html#description",
    "relUrl": "/tools/docs/readme_UnifiedHost_udp.html#description"
  },"219": {
    "doc": "Tools Help",
    "title": "Configuring and Using the Unified Host tool",
    "content": ". | Configure the Host PC for setting up IP Address to communicate with the device . | Go to Control Panel/Network and Internet/Network Connections | Open Ethernet properties | . | Double Click on Internet Protocol Version 4 (TCP/IPv4) | . | Configure the IP Address as shown below . | IP address : 192.168.1.12 | Subnet Mask : 255.255.255.0 | . | . | Double click on tools/UnifiedHost-*/UnifiedHost-*.jar file to launch the Host application . | Select the Device architecture and Protocol as shown below . | Select UDP Protocol . | Click on configure button to configure UDP port Number and IP Address | . | Load the test application hex file to be programmed using below option . | Open the Console window of the host application to view application bootloading sequence . | Click on Program Device button to program the loaded test application hex file on to the device . | Following snapshot shows output of successfully programming the test application . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_udp.html#configuring-and-using-the-unified-host-tool",
    "relUrl": "/tools/docs/readme_UnifiedHost_udp.html#configuring-and-using-the-unified-host-tool"
  },"220": {
    "doc": "Tools Help",
    "title": "Using Unified Host Tool in debugging mode",
    "content": ". | On Windows: . | Launch Windows Command prompt in tools/UnifiedHost-*/ directory . | Run below command to launch Unified Host Application in debugging mode . | . java -Djava.util.logging.config.file=\\\"logging.properties\\\" -jar UnifiedHost-*.jar . | On Linux . | For running Unified Host tool in debug mode on linux make use of MPLAB X’s Java JRE . | Launch Linux Command prompt in tools/UnifiedHost-*/ directory . | Run below command to launch Unified Host Application in debugging mode . | . /opt/microchip/mplabx/&lt;MPLAB X Version&gt;/sys/java/zulu8.40.0.25-ca-fx-jre8.0.222-linux_x64/bin/java -Djava.util.logging.config.file=\\\"logging.properties\\\" -jar UnifiedHost-*.jar . | Once the tool is launched refer to steps mentioned above in Configuring and Using the Unified Host tool to program application hex . | You can see the logs during programming sequence on the command prompt . | Once done you can open the tools/UnifiedHost-*/app.log file and check for the programming sequence logs . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_udp.html#using-unified-host-tool-in-debugging-mode",
    "relUrl": "/tools/docs/readme_UnifiedHost_udp.html#using-unified-host-tool-in-debugging-mode"
  },"221": {
    "doc": "Tools Help",
    "title": "Tools Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_udp.html",
    "relUrl": "/tools/docs/readme_UnifiedHost_udp.html"
  },"222": {
    "doc": "Tools Help",
    "title": "USB Device HID Bootloader Unified Host Script Help",
    "content": " ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_usb_device_hid.html#usb-device-hid-bootloader-unified-host-script-help",
    "relUrl": "/tools/docs/readme_UnifiedHost_usb_device_hid.html#usb-device-hid-bootloader-unified-host-script-help"
  },"223": {
    "doc": "Tools Help",
    "title": "Downloading the host script",
    "content": "To clone or download these host tools from Github,go to the main page of this repository and then click Clone button to clone this repo or download as zip file. This content can also be download using content manager by following these instructions . Path of the tool within the repository is tools/UnifiedHost-*/UnifiedHost-*.jar . Version and Support information . | Refer to tools/UnifiedHost-*/readme.txt for information on versions and known issues if any . | UART Protocol is not supported in Harmony 3 using this tool . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_usb_device_hid.html#downloading-the-host-script",
    "relUrl": "/tools/docs/readme_UnifiedHost_usb_device_hid.html#downloading-the-host-script"
  },"224": {
    "doc": "Tools Help",
    "title": "Description",
    "content": ". | This host script should be used to communicate with the USB Device HID Bootloader running on the device . | It implements the Unified bootloader protocol required to communicate from host PC . | It sends the Normalized Hex File of the application to be bootloaded . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_usb_device_hid.html#description",
    "relUrl": "/tools/docs/readme_UnifiedHost_usb_device_hid.html#description"
  },"225": {
    "doc": "Tools Help",
    "title": "Configuring and Using the Unified Host tool",
    "content": ". | Double click on tools/UnifiedHost-*/UnifiedHost-*.jar file to launch the Host application . | Select the Device architecture and Protocol as shown below . | Select USB Protocol . | Click on configure button and select the USB Device product ID. Example *3C | . | Load the test application hex file to be programmed using below option . | Open the Console window of the host application to view application bootloading sequence . | Click on Program Device button to program the loaded test application hex file on to the device . | Following snapshot shows output of successfully programming the test application . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_usb_device_hid.html#configuring-and-using-the-unified-host-tool",
    "relUrl": "/tools/docs/readme_UnifiedHost_usb_device_hid.html#configuring-and-using-the-unified-host-tool"
  },"226": {
    "doc": "Tools Help",
    "title": "Using Unified Host Tool in debugging mode",
    "content": ". | On Windows: . | Launch Windows Command prompt in tools/UnifiedHost-*/ directory . | Run below command to launch Unified Host Application in debugging mode . | . java -Djava.util.logging.config.file=\\\"logging.properties\\\" -jar UnifiedHost-*.jar . | On Linux . | For running Unified Host tool in debug mode on linux make use of MPLAB X’s Java JRE . | Launch Linux Command prompt in tools/UnifiedHost-*/ directory . | Run below command to launch Unified Host Application in debugging mode . | . /opt/microchip/mplabx/&lt;MPLAB X Version&gt;/sys/java/zulu8.40.0.25-ca-fx-jre8.0.222-linux_x64/bin/java -Djava.util.logging.config.file=\\\"logging.properties\\\" -jar UnifiedHost-*.jar . | Once the tool is launched refer to steps mentioned above in Configuring and Using the Unified Host tool to program application hex . | You can see the logs during programming sequence on the command prompt . | Once done you can open the tools/UnifiedHost-*/app.log file and check for the programming sequence logs . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_usb_device_hid.html#using-unified-host-tool-in-debugging-mode",
    "relUrl": "/tools/docs/readme_UnifiedHost_usb_device_hid.html#using-unified-host-tool-in-debugging-mode"
  },"227": {
    "doc": "Tools Help",
    "title": "Tools Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_UnifiedHost_usb_device_hid.html",
    "relUrl": "/tools/docs/readme_UnifiedHost_usb_device_hid.html"
  },"228": {
    "doc": "Bootloader and Application binary merge script Help",
    "title": "Bootloader and Application binary merge script Help",
    "content": " ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_app_merge_bin.html#bootloader-and-application-binary-merge-script-help",
    "relUrl": "/tools/docs/readme_btl_app_merge_bin.html#bootloader-and-application-binary-merge-script-help"
  },"229": {
    "doc": "Bootloader and Application binary merge script Help",
    "title": "Downloading the host script",
    "content": "To clone or download these host tools from Github,go to the main page of this repository and then click Clone button to clone this repo or download as zip file. This content can also be download using content manager by following these instructions . Path of the tool within the repository is tools/btl_app_merge_bin.py . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_app_merge_bin.html#downloading-the-host-script",
    "relUrl": "/tools/docs/readme_btl_app_merge_bin.html#downloading-the-host-script"
  },"230": {
    "doc": "Bootloader and Application binary merge script Help",
    "title": "Setting up the Host PC",
    "content": ". | The Script is compatible with Python 3.x and higher | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_app_merge_bin.html#setting-up-the-host-pc",
    "relUrl": "/tools/docs/readme_btl_app_merge_bin.html#setting-up-the-host-pc"
  },"231": {
    "doc": "Bootloader and Application binary merge script Help",
    "title": "Description",
    "content": ". | This script should be used to merge the bootloader binary and application binary . | It creates a merged binary output where bootloader is placed from start and the application will be placed at the offset passed as parameter . | If the application offset is not equal to end of bootloader offset it fills the gap with 0xFF until the application offset . | The merged binary can be used by btl_host.py as input for Updating bootloader and application together . | The merged binary will be created in the directory from where the script was called . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_app_merge_bin.html#description",
    "relUrl": "/tools/docs/readme_btl_app_merge_bin.html#description"
  },"232": {
    "doc": "Bootloader and Application binary merge script Help",
    "title": "Usage Examples",
    "content": "Below is the syntax to show help menu for the script . python &lt;harmony3_path&gt;/bootloader/tools/btl_app_merge_bin.py --help . Below is the syntax and an example on how to merge a bootloader binary and application binary . python &lt;harmony3_path&gt;/bootloader/tools/btl_app_merge_bin.py -o &lt;Offset&gt; -b &lt;Bootloader_binary_path&gt; -a &lt;Application_binary_path&gt; . python &lt;harmony3_path&gt;/bootloader/tools/btl_app_merge_bin.py -o 0x2000 -b &lt;harmony3_path&gt;/bootloader_apps_uart/apps/uart_fail_safe_bootloader/bootloader/firmware/sam_e54_xpro.X/dist/sam_e54_xpro/production/sam_e54_xpro.X.production.bin -a &lt;harmony3_path&gt;/bootloader_apps_uart/apps/uart_fail_safe_bootloader/test_app/firmware/sam_e54_xpro.X/dist/sam_e54_xpro/production/sam_e54_xpro.X.production.bin . python &lt;harmony3_path&gt;/bootloader/tools/btl_host.py -v -s -i COM18 -d same5x -a 0x80000 -f &lt;Path_to_merged_binary&gt;/btl_app_merged.bin . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_app_merge_bin.html#usage-examples",
    "relUrl": "/tools/docs/readme_btl_app_merge_bin.html#usage-examples"
  },"233": {
    "doc": "Bootloader and Application binary merge script Help",
    "title": "Bootloader and Application binary merge script Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_app_merge_bin.html",
    "relUrl": "/tools/docs/readme_btl_app_merge_bin.html"
  },"234": {
    "doc": "Binary to C Array script help",
    "title": "Binary to C Array script help",
    "content": " ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_bin_to_c_array.html#binary-to-c-array-script-help",
    "relUrl": "/tools/docs/readme_btl_bin_to_c_array.html#binary-to-c-array-script-help"
  },"235": {
    "doc": "Binary to C Array script help",
    "title": "Downloading the host script",
    "content": "To clone or download these host tools from Github,go to the main page of this repository and then click Clone button to clone this repo or download as zip file. This content can also be download using content manager by following these instructions . Path of the tool within the repository is tools/btl_bin_to_c_array.py . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_bin_to_c_array.html#downloading-the-host-script",
    "relUrl": "/tools/docs/readme_btl_bin_to_c_array.html#downloading-the-host-script"
  },"236": {
    "doc": "Binary to C Array script help",
    "title": "Setting up the Host PC",
    "content": ". | The Script is compatible with Python 3.x and higher | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_bin_to_c_array.html#setting-up-the-host-pc",
    "relUrl": "/tools/docs/readme_btl_bin_to_c_array.html#setting-up-the-host-pc"
  },"237": {
    "doc": "Binary to C Array script help",
    "title": "Description",
    "content": ". | This script should be used to convert the binary file to a C style array containing Hex output that can be directly included in target application code . | It is mainly used when programming the application using the host_app_nvm application in I2C/CAN Bootloader . | If size of the input binary file is not aligned to device erase boundary it appends 0xFF to the binary to make it aligned and then generates the Hex output . | User must specify the binary file to convert (-b), hex output file (-o) and the device (-d) . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_bin_to_c_array.html#description",
    "relUrl": "/tools/docs/readme_btl_bin_to_c_array.html#description"
  },"238": {
    "doc": "Binary to C Array script help",
    "title": "Usage Examples",
    "content": "Below is the syntax to show help menu for the script . python &lt;harmony3_path&gt;/bootloader/tools/btl_bin_to_c_array.py --help . Below is the syntax and an example on how to convert the binary file to a C style array containing Hex output . python &lt;harmony3_path&gt;/bootloader/tools/btl_bin_to_c_array.py -b &lt;binary_file&gt; -o &lt;hex_file&gt; -d &lt;device&gt; . python &lt;harmony3_path&gt;/bootloader/tools/btl_bin_to_c_array.py -b &lt;harmony3_path&gt;/bootloader_apps_i2c/apps/i2c_bootloader/test_app/firmware/sam_d20_xpro.X/dist/sam_d20_xpro/production/sam_d20_xpro.X.production.bin -o &lt;harmony3_path&gt;/bootloader_apps_i2c/apps/i2c_bootloader/host_app_nvm/firmware/src/test_app_images/image_pattern_hex_sam_d20_xpro.h -d samd2x . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_bin_to_c_array.html#usage-examples",
    "relUrl": "/tools/docs/readme_btl_bin_to_c_array.html#usage-examples"
  },"239": {
    "doc": "Binary to C Array script help",
    "title": "Binary to C Array script help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_bin_to_c_array.html",
    "relUrl": "/tools/docs/readme_btl_bin_to_c_array.html"
  },"240": {
    "doc": "Tools Help",
    "title": "UART Bootloader Host Script Help",
    "content": " ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_host.html#uart-bootloader-host-script-help",
    "relUrl": "/tools/docs/readme_btl_host.html#uart-bootloader-host-script-help"
  },"241": {
    "doc": "Tools Help",
    "title": "Downloading the host script",
    "content": "To clone or download these host tools from Github,go to the main page of this repository and then click Clone button to clone this repo or download as zip file. This content can also be download using content manager by following these instructions . Path of the tool within the repository is tools/btl_host.py . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_host.html#downloading-the-host-script",
    "relUrl": "/tools/docs/readme_btl_host.html#downloading-the-host-script"
  },"242": {
    "doc": "Tools Help",
    "title": "Setting up the Host PC",
    "content": ". | The Script is compatible with Python 3.x and higher . | It requires pyserial package to communicate with device over UART. Use below command to install the pyserial package . pip3 install pyserial . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_host.html#setting-up-the-host-pc",
    "relUrl": "/tools/docs/readme_btl_host.html#setting-up-the-host-pc"
  },"243": {
    "doc": "Tools Help",
    "title": "Description",
    "content": ". | This host script should be used to communicate with the Bootloader running on the device via UART interface . | It is a command line interface and implements the bootloader protocol required to communicate from host PC . | If size of the input binary file is not aligned to device erase boundary it appends 0xFF to the binary to make it aligned and then sends the binary to the device . | It should be used with -s (–swap) option when using bootloader in fail safe update mode to trigger a swap bank and reset . | It should be used with -b (–boot) option with address as 0x0 when updating the bootloader itself on CORTEX-M based MCUs . | . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_host.html#description",
    "relUrl": "/tools/docs/readme_btl_host.html#description"
  },"244": {
    "doc": "Tools Help",
    "title": "Usage Examples",
    "content": "Below is the syntax to show help menu for the script . python &lt;harmony3_path&gt;/bootloader/tools/btl_host.py --help . Bootloader basic mode syntax and example . Below syntax and example can be used to program a binary and send a Reset command . python &lt;harmony3_path&gt;/bootloader/tools/btl_host.py -v -i &lt;COM PORT&gt; -d &lt;Device Name&gt; -a &lt;address&gt; -f &lt;Application_binary_path&gt; . python &lt;harmony3_path&gt;/bootloader/tools/btl_host.py -v -i COM18 -d same5x -a 0x2000 -f &lt;harmony3_path&gt;/bootloader_apps_uart/apps/uart_bootloader/test_app/firmware/sam_e54_xpro.X/dist/sam_e54_xpro/production/sam_e54_xpro.X.production.bin . Bootloader Fail Safe Update mode syntax and example . Below syntax and example can be used to program a binary in Inactive Bank and send a Swap Bank and Reset command . python &lt;harmony3_path&gt;/bootloader/tools/btl_host.py -v -s -i &lt;COM PORT&gt; -d &lt;Device Name&gt; -a &lt;Inactive Bank address&gt; -f &lt;Path to application binary&gt; . Example to send Bootloader binary in inactive bank . python &lt;harmony3_path&gt;/bootloader/tools/btl_host.py -v -s -i COM18 -d same5x -a 0x80000 -f &lt;harmony3_path&gt;/bootloader_apps_uart/apps/uart_fail_safe_bootloader/bootloader/firmware/sam_e54_xpro.X/dist/sam_e54_xpro/production/sam_e54_xpro.X.production.bin . Example to send Application binary in inactive bank . python &lt;harmony3_path&gt;/bootloader/tools/btl_host.py -v -s -i COM18 -d same5x -a 0x82000 -f &lt;harmony3_path&gt;/bootloader_apps_uart/apps/uart_fail_safe_bootloader/test_app/firmware/sam_e54_xpro.X/dist/sam_e54_xpro/production/sam_e54_xpro.X.production.bin . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_host.html#usage-examples",
    "relUrl": "/tools/docs/readme_btl_host.html#usage-examples"
  },"245": {
    "doc": "Tools Help",
    "title": "Addition Information",
    "content": ". | Refer to Bootloader and Application binary merge script Help for merging the bootloader and application binary. | . Below is the example to send te merged binary in inactive bank using btl_host.py . python &lt;harmony3_path&gt;/bootloader/tools/btl_host.py -v -s -i COM18 -d same5x -a 0x80000 -f &lt;Path_to_merged_binary&gt;/btl_app_merged.bin . ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_host.html#addition-information",
    "relUrl": "/tools/docs/readme_btl_host.html#addition-information"
  },"246": {
    "doc": "Tools Help",
    "title": "Tools Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/tools/docs/readme_btl_host.html",
    "relUrl": "/tools/docs/readme_btl_host.html"
  },"247": {
    "doc": "Release notes",
    "title": "Microchip MPLAB® Harmony 3 Release Notes",
    "content": " ",
    "url": "http://localhost:4000/bootloader/release_notes.html#microchip-mplab-harmony-3-release-notes",
    "relUrl": "/release_notes.html#microchip-mplab-harmony-3-release-notes"
  },"248": {
    "doc": "Release notes",
    "title": "Bootloader Release v3.5.0",
    "content": "New Features . | This release includes support for . | Serial Memory Bootloader for SAM, PIC32M and PIC32C family of 32-bit microcontrollers. | I2C EEPROM | SPI EEPROM | SPI Flash | QSPI Flash | . | USB Live Update for SAM and PIC32M family of 32-bit microcontrollers. | Ethernet UDP Live Update for SAM and PIC32M family of 32-bit microcontrollers. | CAN Bootloader for SAM family of 32-bit microcontrollers. | PIC32CM MC family of 32-bit microcontrollers . | UART Bootloader | I2C Bootloader | SD Card Bootloader | . | PIC32MZ W1 family of 32-bit microcontrollers . | UART Bootloader Bootloader | USB Device HID Bootloader | USB Host MSD Bootloader | Ethernet UDP Bootloader | SD Card Bootloader | . | . | Added new File System Bootloader component supporting below medias . | SD Card | USB Host MSD | Serial Memory | . | Updated default optimization level for all bootloaders to -O2 . | Added markdown based documentation for Bootloader Library . | Below are new bootloader application repos added . | bootloader_apps_can | bootloader_apps_serial_memory | . | . Bootloaders Supported on different product families . | The following table provides supported bootloders for different product families . | . Known Issues . The current known issues are as follows: . | Any existing USB Host MSD bootloader and SD Card bootloader projects have to be reconfigured to use the new File System Bootloader component in MHC . | Initialized global variables will not be initialized at startup for UART, I2C and CAN bootloaders. | Unified Host application when configured to use USB protocol has to be closed before programming any PIC32M based application using MPLAB X IDE . | . Development Tools . | MPLAB® X IDE v5.50 | MPLAB® XC32 C/C++ Compiler v3.00 | MPLAB® X IDE plug-ins: . | MPLAB® Harmony 3 Launcher v3.6.4 and above. | . | . ",
    "url": "http://localhost:4000/bootloader/release_notes.html#bootloader-release-v350",
    "relUrl": "/release_notes.html#bootloader-release-v350"
  },"249": {
    "doc": "Release notes",
    "title": "Bootloader Release v3.4.1",
    "content": ". | Updated Bootloader component to disable default linker file generation added in csp v3.8.0 as it requires custom linker file | . Known Issues . | No changes from v3.4.0 | . Development Tools . | No changes from v3.4.0 | . ",
    "url": "http://localhost:4000/bootloader/release_notes.html#bootloader-release-v341",
    "relUrl": "/release_notes.html#bootloader-release-v341"
  },"250": {
    "doc": "Release notes",
    "title": "Bootloader Release v3.4.0",
    "content": "New Features . | This release includes support for . | USB Device HID Bootloader for SAM and PIC32M family of 32-bit microcontrollers. | USB Host MSD Bootloader for SAM and PIC32M family of 32-bit microcontrollers. | Ethernet UDP Bootloader for SAM and PIC32M family of 32-bit microcontrollers. | SD Card Bootloader for SAM and PIC32M family of 32-bit microcontrollers. | . | Bootloader demo application are placed in below repositories . | bootloader_apps_uart | bootloader_apps_i2c | bootloader_apps_usb | bootloader_apps_ethernet | bootloader_apps_sdcard | . | . Bootloaders Supported on different product families . | The following table provides supported bootloders for different product families . | Product Family | UART | I2C | USB Device HID | USB Host MSD | UDP | SDCARD | UART Fail Safe | I2C Fail Safe | . | SAM D09/D10/D11 | Yes | Yes | No | No | NA | No | NA | NA | . | SAM D20 | Yes | Yes | NA | NA | NA | Yes | NA | NA | . | SAM D21/DA1 | Yes | Yes | Yes | Yes | NA | Yes | NA | NA | . | SAM HA1 | Yes | Yes | NA | NA | NA | No | NA | NA | . | SAM C20/C21 | Yes | Yes | NA | NA | NA | Yes | NA | NA | . | SAM L21 | Yes | Yes | Yes | Yes | NA | Yes | NA | NA | . | SAM L22 | Yes | Yes | Yes | Yes | NA | Yes | NA | NA | . | SAM L10/L11 | Yes | Yes | NA | NA | NA | Yes | NA | NA | . | SAM D5x/E5x | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | . | SAM G5x | Yes | No | Yes | Yes | NA | Yes | NA | NA | . | SAM E70/S70/V70/V71 | Yes | No | Yes | Yes | Yes | Yes | NA | NA | . | PIC32MX5XX/6XX/7XX | Yes | No | Yes | Yes | Yes | Yes | NA | NA | . | PIC32MX330/350/370/430/450/470 | Yes | No | Yes | Yes | NA | Yes | NA | NA | . | PIC32MX1XX/2XX/5XX | Yes | No | Yes | Yes | NA | Yes | NA | NA | . | PIC32MX1XX/2XX | Yes | No | Yes | Yes | NA | Yes | NA | NA | . | PIC32MX1XX/2XX XLP | Yes | No | Yes | Yes | NA | Yes | NA | NA | . | PIC32MK GPD/GPE/MCF | Yes | NA | Yes | Yes | NA | Yes | Yes | NA | . | PIC32MK GPG/MCJ | Yes | No | NA | NA | NA | Yes | NA | NA | . | PIC32MK GPK/MCM | Yes | No | Yes | Yes | NA | Yes | Yes | No | . | PIC32MZ EF | Yes | No | Yes | Yes | Yes | Yes | Yes | No | . | PIC32MZ DA | Yes | No | Yes | Yes | Yes | Yes | Yes | No | . | . Known Issues . The current known issues are as follows: . | Initialized global variables will not be initialized at startup for UART and I2C bootloaders. | Unified Host application when configured to use USB protocol has to be closed before programming any PIC32M based application using MPLAB X IDE . | . Development Tools . | MPLAB® X IDE v5.40 | MPLAB® XC32 C/C++ Compiler v2.41 | MPLAB® X IDE plug-ins: . | MPLAB® Harmony Configurator (MHC) v3.5.0 and above. | . | . ",
    "url": "http://localhost:4000/bootloader/release_notes.html#bootloader-release-v340",
    "relUrl": "/release_notes.html#bootloader-release-v340"
  },"251": {
    "doc": "Release notes",
    "title": "Bootloader Release v3.3.0",
    "content": "New Features . | This Release adds I2C Bootloader WLCSP applications for SAMD20 family of 32-bit microcontrollers . | The following WLCSP devices are shipped with preprogrammed bootloader | . | Device Part Number | . | SAMD20 (ATSAMD20E15BU) | . | SAMD20 (ATSAMD20E16BU) | . | . Known Issues . | N/A | . Development Tools . | MPLAB® X IDE v5.40 | MPLAB® XC32 C/C++ Compiler v2.41 | MPLAB® X IDE plug-ins: . | MPLAB® Harmony Configurator (MHC) v3.5.0 and above | . | . ",
    "url": "http://localhost:4000/bootloader/release_notes.html#bootloader-release-v330",
    "relUrl": "/release_notes.html#bootloader-release-v330"
  },"252": {
    "doc": "Release notes",
    "title": "Bootloader Release v3.2.0",
    "content": "New Features . | New part support - This release introduces support of . UART Bootloader for SAM HA1 family of 32-bit microcontrollers. UART Fail Safe Bootloader for PIC32MZ EF, PIC32MZ DA, PIC32MK, PIC32MK GPK/GPL/MCM family of 32-bit microcontrollers. I2C Bootloader for SAM C20/C21, SAM D09/D10/D11 SAM D20/D21, SAM DA1, SAME5x, SAMD5x, SAML10, SAML21, SAML22 family of 32-bit microcontrollers. | Development kit and demo application support - The following table provides demo application available for different development kits. | Development kits | UART Bootloader | I2C Bootloader | UART Fail Safe Bootloader | I2C Fail Safe Bootloader | . | PIC32MK GP Development Kit | Yes | No | Yes | No | . | PIC32MK MCJ Curiosity Pro | Yes | No | No | No | . | PIC32MK MCM Curiosity Pro | Yes | No | Yes | No | . | PIC32MX1/2/5 Starter Kit | Yes | No | NA | NA | . | Curiosity PIC32MX470 Development Board | Yes | No | NA | NA | . | PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto) | Yes | No | Yes | No | . | PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit | Yes | No | Yes | No | . | SAM C21N Xplained Pro Evaluation Kit | Yes | Yes | NA | NA | . | SAM D11 Xplained Pro Evaluation Kit | Yes | Yes | NA | NA | . | SAM D20 Xplained Pro Evaluation Kit | Yes | Yes | NA | NA | . | SAM D21 Xplained Pro Evaluation Kit | Yes | Yes | NA | NA | . | SAM DA1 Xplained Pro Evaluation Kit | Yes | Yes | NA | NA | . | SAM E54 Xplained Pro Evaluation Kit | Yes | Yes | Yes | Yes | . | SAM E70 Xplained Ultra Evaluation Kit | Yes | No | NA | NA | . | SAM G55 Xplained Pro Evaluation Kit | Yes | No | NA | NA | . | SAM L10 Xplained Pro Evaluation Kit | Yes | Yes | NA | NA | . | SAM L21 Xplained Pro Evaluation Kit | Yes | Yes | NA | NA | . | SAM L22 Xplained Pro Evaluation Kit | Yes | Yes | NA | NA | . | . Known Issues . The current known issues are as follows: . | Use MPLAB X IDE V5.25 with SAM DA1 Xplained Pro. | SAM HA1 will be supported in the next version of MPLAB X IDE release. | The I2C bootloader for SAM E54 may not work with clock stretching for bootloader commands disabled. | . Development Tools . | MPLAB® X IDE v5.30 | MPLAB® XC32 C/C++ Compiler v2.30 | MPLAB® X IDE plug-ins: . | MPLAB® Harmony Configurator (MHC) v3.3.5 and above. | . | . ",
    "url": "http://localhost:4000/bootloader/release_notes.html#bootloader-release-v320",
    "relUrl": "/release_notes.html#bootloader-release-v320"
  },"253": {
    "doc": "Release notes",
    "title": "Bootloader Release v3.1.2",
    "content": "New Features . | New part support - This release introduces initial support of UART bootloader for SAM DA1, SAM D09/D10/D11, PIC32MX 1XX/2XX, PIC32MX 1XX/2XX XLP, PIC32MX 1XX/2XX/5XX, PIC32MX 3XX/4XX, PIC32MX5XX/6XX/7XX, PIC32MZ EF, PIC32MZ DA, PIC32MK, PIC32MK GPH/GPG/MCJ, PIC32MK GPK/GPL/MCM, family of 32-bit microcontrollers. | Development kit and demo application support - The following table provides number of demo application available for different development kits newly added in this release. | Development kits | Bootloader applications | . | PIC32MK GPL Curiosity Pro | 2 | . | PIC32MK MCJ Curiosity Pro | 2 | . | PIC32MX1/2/5 Starter Kit | 2 | . | Curiosity PIC32MX470 Development Board | 2 | . | PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto) | 2 | . | PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit | 2 | . | SAM C21N Xplained Pro Evaluation Kit | 2 | . | SAM D11 Xplained Pro Evaluation Kit | 2 | . | SAM D20 Xplained Pro Evaluation Kit | 2 | . | SAM D21 Xplained Pro Evaluation Kit | 2 | . | SAM DA1 Xplained Pro Evaluation Kit | 2 | . | SAM E54 Xplained Pro Evaluation Kit | 4 | . | SAM E70 Xplained Ultra Evaluation Kit | 2 | . | SAM G55 Xplained Pro Evaluation Kit | 2 | . | SAM L10 Xplained Pro Evaluation Kit | 2 | . | SAM L21 Xplained Pro Evaluation Kit | 2 | . | SAM L22 Xplained Pro Evaluation Kit | 2 | . | Updated the Bootloader host scripts in bootloader/tools to be compatible with Python 3.x . | Moved the Bootloader host scripts compatible with Python 2.7.x to bootloader/tools_archive folder. These scripts may be removed in future. | . Known Issues . The current known issues are as follows: . | Configuration fuse macros are not generated for SAM D09/D10/D11 devices. | PIC32MK GPK/GPL/MCM will be supported in the next version of MPLAB X IDE release. | SAME70 Bootloader application may not work on lower system frequency with high UART Baud-Rate. | Interactive help using the Show User Manual Entry in the Right-click menu for configuration options provided by this module is not yet available from within the MPLAB Harmony Configurator (MHC). Please see the Configuring the Library section in the help documentation in the doc folder for this Harmony 3 module instead. Help is available in CHM format. | . Development Tools . | MPLAB® X IDE v5.25 | MPLAB® XC32 C/C++ Compiler v2.30 | MPLAB® X IDE plug-ins: | MPLAB® Harmony Configurator (MHC) v3.3.0.1 and above. | . ",
    "url": "http://localhost:4000/bootloader/release_notes.html#bootloader-release-v312",
    "relUrl": "/release_notes.html#bootloader-release-v312"
  },"254": {
    "doc": "Release notes",
    "title": "Bootloader Release v3.1.1",
    "content": ". | Added MPLAB® Harmony License File | . ",
    "url": "http://localhost:4000/bootloader/release_notes.html#bootloader-release-v311",
    "relUrl": "/release_notes.html#bootloader-release-v311"
  },"255": {
    "doc": "Release notes",
    "title": "Bootloader Release v3.1.0",
    "content": "New Features . | New part support - This release introduces initial support of UART bootloader for SAML10 and SAMG55 family of 32-bit microcontrollers. | Development kit and demo application support - The following table provides number of demo application available for different development kits newly added in this release. | Development kits | Bootloader applications | . | SAM C21N Xplained Pro Evaluation Kit | 2 | . | SAM D20 Xplained Pro Evaluation Kit | 2 | . | SAM D21 Xplained Pro Evaluation Kit | 2 | . | SAM E54 Xplained Pro Evaluation Kit | 4 | . | SAM E70 Xplained Ultra Evaluation Kit | 2 | . | SAM G55 Xplained Pro Evaluation Kit | 2 | . | SAM L10 Xplained Pro Evaluation Kit | 2 | . | SAM L21 Xplained Pro Evaluation Kit | 2 | . | SAM L22 Xplained Pro Evaluation Kit | 2 | . | . Known Issues . The current known issues are as follows: . | SAME70 Bootloader application may not work on lower system frequency with high UART Baud-Rate. | . Development Tools . | MPLAB® X IDE v5.20 | MPLAB® XC32 C/C++ Compiler v2.20 | MPLAB® X IDE plug-ins: . | MPLAB® Harmony Configurator (MHC) v3.3.0.1 and above. | . | . ",
    "url": "http://localhost:4000/bootloader/release_notes.html#bootloader-release-v310",
    "relUrl": "/release_notes.html#bootloader-release-v310"
  },"256": {
    "doc": "Release notes",
    "title": "Bootloader Release v3.0.0",
    "content": "New Features . | New part support - This release introduces initial support for SAM C20/C21, SAM D20/D21, SAM S70, SAM E70, SAM V70/V71, SAME5x, SAMD5x, SAML21, SAML22 family of 32-bit microcontrollers. | Added support for UART bootloader. | Development kit and demo application support - The following table provides number of demo application available for different development kits newly added in this release. | Development kits | Bootloader applications | . | SAM C21N Xplained Pro Evaluation Kit | 2 | . | SAM D20 Xplained Pro Evaluation Kit | 2 | . | SAM D21 Xplained Pro Evaluation Kit | 2 | . | SAM E54 Xplained Pro Evaluation Kit | 4 | . | SAM E70 Xplained Ultra Evaluation Kit | 2 | . | SAM L21 Xplained Pro Evaluation Kit | 2 | . | SAM L22 Xplained Pro Evaluation Kit | 2 | . | . Known Issues . The current known issues are as follows: . | SAME70 Bootloader application may not work on lower system frequency with high UART Baud-Rate. | . Development Tools . | MPLAB® X IDE v5.20 | MPLAB® XC32 C/C++ Compiler v2.20 | MPLAB® X IDE plug-ins: . | MPLAB® Harmony Configurator (MHC) v3.3.0.1 and above. | . | . ",
    "url": "http://localhost:4000/bootloader/release_notes.html#bootloader-release-v300",
    "relUrl": "/release_notes.html#bootloader-release-v300"
  },"257": {
    "doc": "Release notes",
    "title": "Release notes",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/release_notes.html",
    "relUrl": "/release_notes.html"
  },"258": {
    "doc": "Application Configurations",
    "title": "Configurations for the application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_application_configurations.html#configurations-for-the-application-to-be-bootloaded",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_application_configurations.html#configurations-for-the-application-to-be-bootloaded"
  },"259": {
    "doc": "Application Configurations",
    "title": "For CORTEX-M based MCUs",
    "content": ". | Refer to Application project Configurations for information on how to configure an application to be bootloaded for CORTEX-M based MCus | . For MIPS based MCUs . | Refer to Application Linker Script Configurations for information on how to setup a linker script for the application to be bootloaded for MIPS based MCus . | Refer to Application project Configurations for information on how to configure an application to be bootloaded for MIPS based MCus . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_application_configurations.html#for-cortex-m-based-mcus",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_application_configurations.html#for-cortex-m-based-mcus"
  },"260": {
    "doc": "Application Configurations",
    "title": "Application Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_application_configurations.html",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_application_configurations.html"
  },"261": {
    "doc": "Bootloader Configurations",
    "title": "Serial Memory Bootloader Configurations",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html#serial-memory-bootloader-configurations",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html#serial-memory-bootloader-configurations"
  },"262": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Specific User Configurations",
    "content": ". | Bootloader Serial Memory Used: . | Specifies the Serial memory driver used by bootloader to receive the application | The name of the serial memory will vary based on the driver connected to bootloader | . | Bootloader NVM Memory Used: . | Specifies the memory peripheral used by bootloader to perform flash operations | The name of the peripheral will vary from device to device | . | Bootloader Size (Bytes): . | Specifies the maximum size of flash required by the bootloader | This size is calculated based on Bootloader type and Memory used | This size will vary from device to device and should always be aligned to device erase unit size | . | Enable Bootloader Trigger From Firmware: . | This Option can be used to Force Trigger bootloader from application firmware after a soft reset. It does so by reserving the specified number of bytes in SRAM from the start of the RAM. The reserved memory is updated by the application with a pre-defined pattern. The bootloader firmware in the bootloader_Trigger() routine, can check the reserved memory for the pre-defined pattern and enter bootloader mode if the pattern matches. | Number Of Bytes To Reserve From Start Of RAM: . | This option adds the provided offset to RAM Start address in bootloader linker script. | Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader to check at reset in bootloader_Trigger() function | . | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html#bootloader-specific-user-configurations",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html#bootloader-specific-user-configurations"
  },"263": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader System Configurations",
    "content": ". | Application Start Address (Hex): . | Start address of the application which will programmed by bootloader | This value is filled by bootloader when its loaded which is equal to the bootloader size. It can be modified as per user need | This value will be used by bootloader to Jump to application at device reset | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html#bootloader-system-configurations",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html#bootloader-system-configurations"
  },"264": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader MPLAB X Settings",
    "content": ". | As the Serial memory may not have any valid binary required by bootloader for the first time, Adding the application to be bootloaded as loadable allows MPLAB X to create a unified hex file and program both these applications in their respective memory locations . | By doing this, At first bootup bootloader directly jumps to application as the serial memory does not have any valid binary | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html#bootloader-mplab-x-settings",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html#bootloader-mplab-x-settings"
  },"265": {
    "doc": "Bootloader Configurations",
    "title": "Additional Information",
    "content": ". | Refer to MIPS Bootloader Linker Script Configurations for information on bootloader linker script generated by MHC for MIPS based MCus . | Refer to Bootloader Sizing And Considerations for information on bootloader size change considerations . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html#additional-information",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html#additional-information"
  },"266": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_configurations.html"
  },"267": {
    "doc": "Bootloader Execution Flow",
    "title": "Serial Memory Bootloader execution flow",
    "content": ". | On device reset after systme initialize, The Bootloader task starts executing from the SYS_Tasks() . | Once the Serial Memory driver is ready, it retrieves the Meta Data from serial memory . | If any error in reading the Meta-Data it directly jumps Run application | . | It checks if the Meta Data read is valid using the Prologue and Epilogue. | If valid . | It stores the application start address and application size from meta data which will be used during programming operation . | Checks if the Update Required flag is set. If set it jumps to Programming step Or continues to Trigger Check . | . | If Invalid . | It continues to Trigger Check | . | . | . Trigger Check . | If there are no conditions to enter the firmware upgrade mode, the Bootloader jumps to Run application . | Refer to Bootloader Trigger Methods for different conditions to enter firmware upgrade mode | . | . Programming . | Starts reading the application binary from serial memory and perform erase/program operations on internal flash . | Once programming is completed, it generates CRC32 on programmed space of internal flash and verifies it against the CRC32 value stored in Meta data . | Once verification is complete it clears the update required flag in meta data and triggers reset to Run application . | . Run Application . | The application start address used to jump to application space can be . | Application start address generated during compile time Or . | Application start address retrieved from valid Meta Data . | . | Calls SYS_DeInitialize() function to release resources used . | Jumps to application space to run the updated application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_execution_flow.html#serial-memory-bootloader-execution-flow",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_execution_flow.html#serial-memory-bootloader-execution-flow"
  },"268": {
    "doc": "Bootloader Execution Flow",
    "title": "Bootloader Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_execution_flow.html",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_execution_flow.html"
  },"269": {
    "doc": "How The Library Works",
    "title": "How the Serial Memory Bootloader library works",
    "content": "The Serial Memory Bootloader firmware communicates with the serial memory to receive application firmware . | Resides from . | The starting location of the flash memory region for CORTEX-M based MCUs . | The starting location of the Boot flash memory region or Program Flash memory region for MIPS based MCUs devices . | . | The Bootloader performs flash erase/program/verify operations with the binary read from serial memory while in the firmware upgrade mode . | The binary received is only of the application to be programmed | Bootloader always performs flash operation from the address for application binary being received | The application can use the entire flash memory region starting from the end of bootloader space | . | Calls SYS_DeInitialize() before jumping to the application space . | Note: At first bootup either the serial memory should already have the application to be bootloaded or the application to be bootloaded has to be programmed along with bootloader using the external programmer or debugger. | . Memory layout . | Basic memory layout for CORTEX-M based MCUs . | Basic memory layout for MIPS based MCUs . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_how_library_works.html#how-the-serial-memory-bootloader-library-works",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_how_library_works.html#how-the-serial-memory-bootloader-library-works"
  },"270": {
    "doc": "How The Library Works",
    "title": "Bootloader and Serial Memory Meta Data",
    "content": "/* Structure to store the Meta Data of the application binary for bootloader * Note: The order of the members should not be changed */ typedef struct { /* Used to Validate the Meta Data itself*/ uint32_t prologue; /* Flag to indicate if a firmware update is required * 0xFFFFFFFF --&gt; Update Required. Set by Serial Memory programmer after programming * the image in Serial memory * 0x00000000 --&gt; Update Completed. Changed by bootloader after programming * the image from Serial memory to internal flash */ uint32_t isAppUpdateRequired; /* Application Start address */ uint32_t appStartAddress; /* Size of the application binary */ uint32_t appSize; /* CRC32 value for the application binary */ uint32_t appCRC32; /* Used to Validate the Meta Data itself*/ uint32_t epilogue; } APP_META_DATA; . | The above meta data for application has to be stored in last page of serial memory required by bootloader . | Bootloader reads this meta data to get details of the application binary being received and then performs the programming operation accordingly . | Once programming is completed, it generates CRC32 on programmed space of internal flash and verifies it against the appCRC32 stored in Meta data . | Once verification is completed it clears the isAppUpdateRequired flag and then performs reset to jump to application . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_how_library_works.html#bootloader-and-serial-memory-meta-data",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_how_library_works.html#bootloader-and-serial-memory-meta-data"
  },"271": {
    "doc": "How The Library Works",
    "title": "How The Library Works",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_how_library_works.html",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_how_library_works.html"
  },"272": {
    "doc": "Library Interface",
    "title": "Serial Memory Bootloader Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_library_interface.html#serial-memory-bootloader-library-interface",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_library_interface.html#serial-memory-bootloader-library-interface"
  },"273": {
    "doc": "Library Interface",
    "title": "Table of contents",
    "content": ". | System functions . | bootloader_Tasks | bootloader_Trigger | run_Application | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_library_interface.html#table-of-contents",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_library_interface.html#table-of-contents"
  },"274": {
    "doc": "Library Interface",
    "title": "System functions",
    "content": "bootloader_Tasks . void bootloader_Tasks(void) . Summary . Starts bootloader execution. Description . This function can be used to start bootloader execution. The function reads the application firmware from the HOST-PC via Serial Memory and perfroms Erase/Program/Verify operations on internal flash memory . Once the complete application is received, programmed and verified successfully, it resets the device to jump into programmed application. Precondition . None . Parameters . None . Returns . None . Example . bootloader_Tasks(); . bootloader_Trigger . bool bootloader_Trigger(void); . Summary . Checks if Bootloader has to be executed at startup. Description . This function can be used to check for a External HW trigger or Internal firmware trigger to execute bootloader at startup. This function has to be implemented by the bootloader application to override the WEAK implementation in bootloader.c . | External Trigger: . | Can be achieved by triggering a GPIO_PIN at startup. | . | Firmware Trigger: . | Application firmware which wants to execute bootloader at startup needs to fill first n bytes of ram location with a request pattern. The Number of bytes to be reserved for storing the pattern has to be configured in bootloader component configuration in MHC. | . | . uint32_t *sram = (uint32_t *)BTL_TRIGGER_RAM_START; sram[0] = 0x5048434D; sram[1] = 0x5048434D; sram[2] = 0x5048434D; sram[3] = 0x5048434D; . Precondition . PORT/PIO Initialize must have been called. Parameters . None . Returns . | True : If any of trigger is detected. | False : If no trigger is detected.. | . Example . #define BTL_TRIGGER_PATTERN 0x5048434D static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START; bool bootloader_Trigger(void) { // Check for Bootloader Trigger Pattern in first 16 Bytes of RAM to enter Bootloader. if (BTL_TRIGGER_PATTERN == ramStart[0] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[1] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[2] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[3]) { ramStart[0] = 0; return true; } // Check for Switch press to enter Bootloader if (SWITCH_Get() == 0) { return true; } return false; } void bootloader_Tasks() { case BOOTLOADER_STATE_CHECK_TRIGGER: { if (bootloader_Trigger() == true) { btlData.state = BOOTLOADER_STATE_READ_APP_BINARY; } else { btlData.state = BOOTLOADER_STATE_RUN_APPLICATION; } break; } case BOOTLOADER_STATE_RUN_APPLICATION: { BOOTLOADER_ReleaseResources(); run_Application(); break; } } . run_Application . void run_Application(void); . Summary . Runs the programmed application at startup. Description . This function can be used to run programmed application though bootloader at startup. If the first 4Bytes of Application Memory is not 0xFFFFFFFF then it jumps to the application start address to run the application programmed through bootloader and never returns. If the first 4Bytes of Application Memory is 0xFFFFFFFF then it returns from function and executes bootloader for accepting a new application firmware. Precondition . bootloader_Trigger() must be called to check for bootloader triggers. Parameters . None . Returns . None . Example . void bootloader_Tasks() { case BOOTLOADER_STATE_CHECK_TRIGGER: { if (bootloader_Trigger() == true) { btlData.state = BOOTLOADER_STATE_READ_APP_BINARY; } else { btlData.state = BOOTLOADER_STATE_RUN_APPLICATION; } break; } case BOOTLOADER_STATE_RUN_APPLICATION: { BOOTLOADER_ReleaseResources(); run_Application(); break; } } . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_library_interface.html#system-functions",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_library_interface.html#system-functions"
  },"275": {
    "doc": "Library Interface",
    "title": "Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_bootloader_library_interface.html",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_bootloader_library_interface.html"
  },"276": {
    "doc": "Debugging Help",
    "title": "Debugging Serial Memory Bootloader and Application to be bootloaded",
    "content": ". | Refer to Debugging Bootloader And Application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_debugging.html#debugging-serial-memory-bootloader-and-application-to-be-bootloaded",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_debugging.html#debugging-serial-memory-bootloader-and-application-to-be-bootloaded"
  },"277": {
    "doc": "Debugging Help",
    "title": "Debugging Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/serial_memory/serial_debugging.html",
    "relUrl": "/templates/src/optimized/docs/serial_memory/serial_debugging.html"
  },"278": {
    "doc": "Application Configurations",
    "title": "Configurations for the application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_application_configurations.html#configurations-for-the-application-to-be-bootloaded",
    "relUrl": "/templates/src/optimized/docs/uart/uart_application_configurations.html#configurations-for-the-application-to-be-bootloaded"
  },"279": {
    "doc": "Application Configurations",
    "title": "For CORTEX-M based MCUs",
    "content": ". | Refer to Application project Configurations for information on how to configure an application to be bootloaded for CORTEX-M based MCus | . For MIPS based MCUs . | Refer to Application Linker Script Configurations for information on how to setup a linker script for the application to be bootloaded for MIPS based MCus . | Refer to Application project Configurations for information on how to configure an application to be bootloaded for MIPS based MCus . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_application_configurations.html#for-cortex-m-based-mcus",
    "relUrl": "/templates/src/optimized/docs/uart/uart_application_configurations.html#for-cortex-m-based-mcus"
  },"280": {
    "doc": "Application Configurations",
    "title": "Application Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_application_configurations.html",
    "relUrl": "/templates/src/optimized/docs/uart/uart_application_configurations.html"
  },"281": {
    "doc": "Bootloader Configurations",
    "title": "UART Bootloader Configurations",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_configurations.html#uart-bootloader-configurations",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_configurations.html#uart-bootloader-configurations"
  },"282": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Specific User Configurations",
    "content": "For CORTEX-M based MCUs . For MIPS based MCUs . | Bootloader Peripheral Used: . | Specifies the communication peripheral used by bootloader to receive the application | The name of the peripheral will vary from device to device | . | Bootloader NVM Memory Used: . | Specifies the memory peripheral used by bootloader to perform flash operations | The name of the peripheral will vary from device to device | . | Bootloader Size (Bytes): . | Specifies the maximum size of flash required by the bootloader | This size is calculated based on Bootloader type and Memory used | This size will vary from device to device and should always be aligned to device erase unit size | . | Enable Bootloader Trigger From Firmware: . | This Option can be used to Force Trigger bootloader from application firmware after a soft reset. It does so by reserving the specified number of bytes in SRAM from the start of the RAM. The reserved memory is updated by the application with a pre-defined pattern. The bootloader firmware in the bootloader_Trigger() routine, can check the reserved memory for the pre-defined pattern and enter bootloader mode if the pattern matches. | Number Of Bytes To Reserve From Start Of RAM: . | This option adds the provided offset to RAM Start address in bootloader linker script. | Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader to check at reset in bootloader_Trigger() function | . | . | Use Dual Bank For Safe Flash Update: . | Used to configure bootloader to use Dual banks of device to upload the application | This option is visible only for devices supporting Dual flash banks | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_configurations.html#bootloader-specific-user-configurations",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_configurations.html#bootloader-specific-user-configurations"
  },"283": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader System Configurations",
    "content": ". | Application Start Address (Hex): . | Start address of the application which will programmed by bootloader | This value is filled by bootloader when its loaded which is equal to the bootloader size. It can be modified as per user need | This value will be used by bootloader to Jump to application at device reset | . | . Note . | For optimizing the code Bootloader component disables generation of default interrupt and exception files as shown below . | Enabling these interrupts explicitly may still not work as bootloader uses custom startup file which has its own Interrupt table populating only the reset handler . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_configurations.html#bootloader-system-configurations",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_configurations.html#bootloader-system-configurations"
  },"284": {
    "doc": "Bootloader Configurations",
    "title": "Additional Information",
    "content": ". | Refer to MIPS Bootloader Linker Script Configurations for information on bootloader linker script generated by MHC for MIPS based MCus . | Refer to CORTEX-M Bootloader Linker Script Configurations for information on bootloader linker script generated by MHC for CORTEX-M based MCUs . | Refer to Bootloader Sizing And Considerations for information on bootloader size change considerations . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_configurations.html#additional-information",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_configurations.html#additional-information"
  },"285": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_configurations.html",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_configurations.html"
  },"286": {
    "doc": "UART Bootloader Firmware Update Execution Flow",
    "title": "UART Bootloader Firmware Update mode execution flow",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html#uart-bootloader-firmware-update-mode-execution-flow",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html#uart-bootloader-firmware-update-mode-execution-flow"
  },"287": {
    "doc": "UART Bootloader Firmware Update Execution Flow",
    "title": "Bootloader Task Flow",
    "content": ". | Bootloader task is the main task which calls the 3 sub-tasks in a forever loop. | It always calls the Input task to poll for command packets from host . | Once complete packet is received it calls Command task to process the received command . | If the command received was a data command it calls programming task to flash the application . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html#bootloader-task-flow",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html#bootloader-task-flow"
  },"288": {
    "doc": "UART Bootloader Firmware Update Execution Flow",
    "title": "Input Task Flow",
    "content": ". | This task is used to receive the data bytes from host PC . | If there are valid GUARD bytes received at start of packet it proceeds further to receive the whole packet or else reports error and waits for next command . | All bytes of the command frame must be sent within 100 ms of each other. After 100 ms of idle time, incomplete command is discarded and bootloader goes back to waiting for a new Command. | This behavior allows host to re-synchronize in the case of synchronization loss. | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html#input-task-flow",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html#input-task-flow"
  },"289": {
    "doc": "UART Bootloader Firmware Update Execution Flow",
    "title": "Command Task Flow",
    "content": ". | This task processes the packet received for supported commands . | If the received command is a DATA command, it sets ready_to_flash flag so that the bootloader task can call Flash task . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html#command-task-flow",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html#command-task-flow"
  },"290": {
    "doc": "UART Bootloader Firmware Update Execution Flow",
    "title": "Flash Task Flow",
    "content": ". | This task performs flash operations on the received data | . For CORTEX-M based MCUs . | As the bootloader is running from RAM, While waiting for flash operations to complete it calls Input task to receive the next command in parallel . | . For MIPS based MCUs . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html#flash-task-flow",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html#flash-task-flow"
  },"291": {
    "doc": "UART Bootloader Firmware Update Execution Flow",
    "title": "UART Bootloader Firmware Update Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_firmware_update_execution_flow.html"
  },"292": {
    "doc": "How The Library Works",
    "title": "How the UART Bootloader library works",
    "content": "The UART Bootloader firmware communicates with the personal computer host application by using a predefined communication protocol. The UART Bootloader works in two different modes . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_how_library_works.html#how-the-uart-bootloader-library-works",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_how_library_works.html#how-the-uart-bootloader-library-works"
  },"293": {
    "doc": "How The Library Works",
    "title": "Basic Mode",
    "content": ". | This mode is supported for all the devices . | Resides from . | The starting location of the flash memory region for CORTEX-M based MCUs . | The starting location of the Boot flash memory region for MIPS based MCUs devices . | . | The Bootloader performs flash erase/program/verify operations with the binary sent from host while in the firmware upgrade mode . | The binary sent is only of the application to be programmed | Bootloader always performs flash operation from the address for (bootloader or application) binary sent from host | The application can use the entire flash memory region starting from the end of bootloader space | . | Jumps to the application once verification is completed | . Memory layout . | Basic memory layout for CORTEX-M based MCUs . | Basic memory layout for MIPS based MCUs . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_how_library_works.html#basic-mode",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_how_library_works.html#basic-mode"
  },"294": {
    "doc": "How The Library Works",
    "title": "Fail Safe Update Mode",
    "content": ". | This mode is supported for the devices which have a Dual Bank flash memory . | Resides from the starting location of the flash memory region of both the banks on CORTEX-M based MCUs . | The Bootloader performs flash erase/program/verify operations with the binary sent from host while in the firmware upgrade mode . | Bootloader can perform flash operation in either of the banks based on the address sent by the host application . | The application can use only the flash memory region of one bank. | . | Performs a bank swap and reset to run the application programmed in inactive bank once verification is completed or a normal reset to run the application in current bank based on command sent from host | . Memory layout . | Fail Safe Update memory layout for CORTEX-M based MCUs . | Fail Safe Update memory layout for MIPS based MCUs . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_how_library_works.html#fail-safe-update-mode",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_how_library_works.html#fail-safe-update-mode"
  },"295": {
    "doc": "How The Library Works",
    "title": "Additional Information",
    "content": ". | For information on protocol used refer to UART Bootloader Protocol | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_how_library_works.html#additional-information",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_how_library_works.html#additional-information"
  },"296": {
    "doc": "How The Library Works",
    "title": "How The Library Works",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_how_library_works.html",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_how_library_works.html"
  },"297": {
    "doc": "Library Interface",
    "title": "UART Bootloader Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_library_interface.html#uart-bootloader-library-interface",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_library_interface.html#uart-bootloader-library-interface"
  },"298": {
    "doc": "Library Interface",
    "title": "Table of contents",
    "content": ". | System functions . | bootloader_Tasks | bootloader_Trigger | run_Application | bootloader_ProgramFlashBankSelect | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_library_interface.html#table-of-contents",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_library_interface.html#table-of-contents"
  },"299": {
    "doc": "Library Interface",
    "title": "System functions",
    "content": "bootloader_Tasks . void bootloader_Tasks(void) . Summary . Starts bootloader execution. Description . This function can be used to start bootloader execution. The function continuously waits for application firmware from the HOST-PC via UART and perfroms Erase/Program/Verify operations on internal flash memory . Once the complete application is received, programmed and verified successfully, it resets the device to jump into programmed application. | Note: As this function runs a infinite loop it never returns | . Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . bootloader_Tasks(); . bootloader_Trigger . bool bootloader_Trigger(void); . Summary . Checks if Bootloader has to be executed at startup. Description . This function can be used to check for a External HW trigger or Internal firmware trigger to execute bootloader at startup. This function has to be implemented by the bootloader application to override the WEAK implementation in bootloader.c . The checks in trigger function should happen before any system resources are initialized apart for PORT, As the same system resource can be Re-initialized by the application if bootloader jumps to it and may cause issues. | External Trigger: . | Can be achieved by triggering a GPIO_PIN at startup. | . | Firmware Trigger: . | Application firmware which wants to execute bootloader at startup needs to fill first n bytes of ram location with a request pattern. The Number of bytes to be reserved for storing the pattern has to be configured in bootloader component configuration in MHC. | . | . uint32_t *sram = (uint32_t *)BTL_TRIGGER_RAM_START; sram[0] = 0x5048434D; sram[1] = 0x5048434D; sram[2] = 0x5048434D; sram[3] = 0x5048434D; . Precondition . PORT/PIO Initialize must have been called. Parameters . None . Returns . | True : If any of trigger is detected. | False : If no trigger is detected.. | . Example . #define BTL_TRIGGER_PATTERN 0x5048434D static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START; bool bootloader_Trigger(void) { // Check for Bootloader Trigger Pattern in first 16 Bytes of RAM to enter Bootloader. if (BTL_TRIGGER_PATTERN == ramStart[0] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[1] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[2] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[3]) { ramStart[0] = 0; return true; } // Check for Switch press to enter Bootloader if (SWITCH_Get() == 0) { return true; } return false; } void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . run_Application . void run_Application(void); . Summary . Runs the programmed application at startup. Description . This function can be used to run programmed application though bootloader at startup. If the first 4Bytes of Application Memory is not 0xFFFFFFFF then it jumps to the application start address to run the application programmed through bootloader and never returns. If the first 4Bytes of Application Memory is 0xFFFFFFFF then it returns from function and executes bootloader for accepting a new application firmware. Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . bootloader_ProgramFlashBankSelect . void bootloader_ProgramFlashBankSelect( void ); . Summary . Selects Appropriate Program Flash Bank after reset. Description . This function can be used to select the appropriate Program flash bank based on the serial number stored at fixed location in each of the bank after reset. Bootloader should know the address at compile time where the serial number is stored in each bank. It reads the serial number from both banks, Compares the values and maps the bank with highest serial number to lower region. | Note: This Function will be generated only for MIPS based MCUs with dual flash bank support and when the dual bank support option is selected in MHC bootloader component settings . | Refer to Bootloader Configurations section for more details | . | . Precondition . | PORT/PIO Initialize must have been called. | This Function should be called before calling bootloader_Trigger() function . | . Parameters . None . Returns . None . Example . bootloader_ProgramFlashBankSelect( void ); if (bootloader_Trigger() == false) { run_Application(); } . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_library_interface.html#system-functions",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_library_interface.html#system-functions"
  },"300": {
    "doc": "Library Interface",
    "title": "Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_library_interface.html",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_library_interface.html"
  },"301": {
    "doc": "UART Bootloader Protocol",
    "title": "UART Bootloader Protocol",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_protocol.html#uart-bootloader-protocol",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_protocol.html#uart-bootloader-protocol"
  },"302": {
    "doc": "UART Bootloader Protocol",
    "title": "Request Packet",
    "content": "The uart bootloader protocol as shown in below figure is common for all the supported commands. GUARD . | The Guard value must be a constant value of 0x5048434D . | This value provides protection against spurious commands . | Bootloader always checks for the Guard value at start of packet reception and proceeds further accordingly . | . Data Size . | This field indicates the number of data bytes to be received . | This value varies for different commands . | . Command . | Indicates the command to be processed. Each command is of 1 Byte width . | Below are the supported commands . | . | Command Type | Command Code | Description | . | Unlock | 0xA0 | Used to calculate application start address and end address | . | Data | 0xA1 | Used to send the image data | . | Verify | 0xA2 | Used to verify the image data sent and programmed | . | Reset | 0xA3 | Used to trigger a reset to run the application | . | Bank Swap and reset | 0xA4 | Used to Swap the bank and trigger a reset to run the application | . Data . | Contains the actual Data to be processed based on the command . | Length of the data to be received is indicated by Data Size field . | Bootloader receives data in size of words . | All data words must be sent in a little-endian (LSB first) format . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_protocol.html#request-packet",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_protocol.html#request-packet"
  },"303": {
    "doc": "UART Bootloader Protocol",
    "title": "Response Codes",
    "content": "Bootloader will send a single character response code in response to each command. Sequential commands can only be sent after the response code is received for a previous command, or after 100 ms timeout without a response. | Response Type | Response Code | Description | . | OK | 0x50 | Command was received and processed successfully | . | Error | 0x51 | There were errors during the processing of the command | . | Invalid | 0x52 | Invalid command is received | . | CRC OK | 0x53 | CRC verification was successful | . | CRC Fail | 0x54 | CRC verification failed | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_protocol.html#response-codes",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_protocol.html#response-codes"
  },"304": {
    "doc": "UART Bootloader Protocol",
    "title": "Command Description",
    "content": "Unlock Command . The Unlock Command sequence is as shown in below figure with corresponding responses. | Unlock command must be issued before the first Data command . | It is used to calculate application start address and end address . | This information will be used to validate if the addresses sent are within the range of flash memory . | It will also be used to validate the address coming with data packet to be programmed are within the region for which the unlock command is invoked . | . | Number of bytes of data to be received is 8 Bytes (Start Address + Image Size) . | Start Address . | It is the application Start Address of the flash memory | It is device dependent and should be always greater than or equal to the bootloader end address | It must be aligned at an Erase Unit Size boundary, which is also device dependent | To upgrade the bootloader itself this value must be set to 0 (For CORTEX-M based MCUs) | . | Image size must be in increments of Erase Unit bytes which is also device dependent | . Data Command . The Data Command sequence is as shown in below figure with corresponding responses. | Data command is used to send the image data . | Data size is equal to sum of block start address (4 Bytes) and Erase Unit Size which is device dependent . | Block start address must be located inside the region previously unlocked via the Unlock command . | Attempts to request the write outside of the unlocked region will result in error and supplied data will be discarded . | . Verify Command . The Verify Command sequence is as shown in below figure with corresponding responses. | Verify command is used to verify the image data sent and programmed . | Image CRC is a standard IEEE CRC32 with a polynomial of 0xEDB88320 . | Internal CRC is calculated based on the values actually read from the Flash memory after programming, so it verifies the whole chain. | Image CRC is calculated over the previously unlocked region. | . Reset Command . The Reset Command sequence is as shown in below figure with corresponding responses. | Reset command is used to exit the bootloader and run the application . | It is necessary if the host has no control over the reset pin. It can also be useful even if host has control over the Reset . | . Bank Swap and Reset Command . The Bank Swap and Reset Command sequence is as shown in below figure with corresponding responses . | This command is enabled only when Fail safe update feature is selected for bootloader and the device has support for Dual Bank update . | Bank Swap and Reset command is used to Swap the inactive bank to active bank and trigger a reset to exit the bootloader and run the new application programmed in the inactive bank . | . Note . As this bootloader supports simultaneous Flash memory write and reception of the next block of data, The next block of data may be transmitted as soon as the status code is returned for the first one. Because of this behavior, the status code for the last block will be sent before this block is written into the Flash memory. To ensure that this block is written, host must send another command and wait for the response. So either Verify or Reset command must be sent after the last block of data. ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_protocol.html#command-description",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_protocol.html#command-description"
  },"305": {
    "doc": "UART Bootloader Protocol",
    "title": "UART Bootloader Protocol",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_protocol.html",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_protocol.html"
  },"306": {
    "doc": "Bootloader System Execution Flow",
    "title": "UART Bootloader system level execution flow",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_system_execution_flow.html#uart-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_system_execution_flow.html#uart-bootloader-system-level-execution-flow"
  },"307": {
    "doc": "Bootloader System Execution Flow",
    "title": "Basic Bootloader system level execution flow",
    "content": ". | The Bootloader code starts executing on a device Reset . | If there are no conditions to enter the firmware upgrade mode, the Bootloader starts executing the user application . | Refer to Bootloader Trigger Methods for different conditions to enter firmware upgrade mode | . | The Bootloader performs Flash erase/program operations while in the firmware upgrade mode . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_system_execution_flow.html#basic-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_system_execution_flow.html#basic-bootloader-system-level-execution-flow"
  },"308": {
    "doc": "Bootloader System Execution Flow",
    "title": "Fail Safe Update Bootloader system level execution flow (MIPS Based MCUs)",
    "content": ". | Bootloader always maps Bank 1 to lower region at boot up irrespective of cause for reset (Hard/Soft). | This is required because if Swap bit was set and a soft reset was triggered the value is retained but if Swap bit was set and Hard reset was triggered the value is cleared | . | Once Swap bit is cleared and Bank 1 is mapped to lower region it performs below operation . | If Bank 1 serial number is greater than Bank 2 serial number it just continues for trigger check or runs application from Bank 1, As Bank 1 is already mapped to lower region in above step (Bank 1 is Active Bank) . | If Bank 2 serial number is greater than Bank 1 serial number it maps Bank 2 to lower region by setting the Swap bit and proceeds to trigger check or runs application from Bank 2 (Bank 2 is Active Bank) . | . | Whenever Bootlader programs new application in the Inactive bank and swap bank command is received it reads the serial number from Active bank, increments by 1 and then writes to Inactive Bank serial . | Inactive Bank Serial number = Active Bank serial number + 1 . | Start address of inactive bank is equal start of mid of flash . | . | If the Host application requests to update the Active Bank and the address falls into the active bank serial sector it sends an error response and aborts the programming operation . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_system_execution_flow.html#fail-safe-update-bootloader-system-level-execution-flow-mips-based-mcus",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_system_execution_flow.html#fail-safe-update-bootloader-system-level-execution-flow-mips-based-mcus"
  },"309": {
    "doc": "Bootloader System Execution Flow",
    "title": "Additional Information",
    "content": ". | Refer to Firmware Update Mode execution flow to understand how the firmware update takes place in bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_system_execution_flow.html#additional-information",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_system_execution_flow.html#additional-information"
  },"310": {
    "doc": "Bootloader System Execution Flow",
    "title": "Bootloader System Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_bootloader_system_execution_flow.html",
    "relUrl": "/templates/src/optimized/docs/uart/uart_bootloader_system_execution_flow.html"
  },"311": {
    "doc": "Debugging Help",
    "title": "Debugging UART Bootloader and Application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_debugging.html#debugging-uart-bootloader-and-application-to-be-bootloaded",
    "relUrl": "/templates/src/optimized/docs/uart/uart_debugging.html#debugging-uart-bootloader-and-application-to-be-bootloaded"
  },"312": {
    "doc": "Debugging Help",
    "title": "Debugging Bootloader",
    "content": "For CORTEX-M based MCUs . | Refer to Debugging Bootloaders For CORTEX-M based MCUs for information on how to debug UART bootloader | . For MIPS based MCUs . | Can be debugged as any other MPLAB project. No additional setup is required. | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_debugging.html#debugging-bootloader",
    "relUrl": "/templates/src/optimized/docs/uart/uart_debugging.html#debugging-bootloader"
  },"313": {
    "doc": "Debugging Help",
    "title": "Debugging application to be bootloaded along with bootloader",
    "content": ". | Refer to Debugging Bootloader And Application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_debugging.html#debugging-application-to-be-bootloaded-along-with-bootloader",
    "relUrl": "/templates/src/optimized/docs/uart/uart_debugging.html#debugging-application-to-be-bootloaded-along-with-bootloader"
  },"314": {
    "doc": "Debugging Help",
    "title": "Debugging Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/optimized/docs/uart/uart_debugging.html",
    "relUrl": "/templates/src/optimized/docs/uart/uart_debugging.html"
  },"315": {
    "doc": "Application Configurations",
    "title": "Configurations for the application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_application_configurations.html#configurations-for-the-application-to-be-bootloaded",
    "relUrl": "/templates/src/unified/docs/udp/udp_application_configurations.html#configurations-for-the-application-to-be-bootloaded"
  },"316": {
    "doc": "Application Configurations",
    "title": "For CORTEX-M based MCUs",
    "content": ". | Refer to Application project Configurations for information on how to configure an application to be bootloaded for CORTEX-M based MCus | . For MIPS based MCUs . | Refer to Application Linker Script Configurations for information on how to setup a linker script for the application to be bootloaded for MIPS based MCus . | Refer to Application project Configurations for information on how to configure an application to be bootloaded for MIPS based MCus . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_application_configurations.html#for-cortex-m-based-mcus",
    "relUrl": "/templates/src/unified/docs/udp/udp_application_configurations.html#for-cortex-m-based-mcus"
  },"317": {
    "doc": "Application Configurations",
    "title": "Application Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_application_configurations.html",
    "relUrl": "/templates/src/unified/docs/udp/udp_application_configurations.html"
  },"318": {
    "doc": "Bootloader Configurations",
    "title": "UDP Bootloader Configurations",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_configurations.html#udp-bootloader-configurations",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_configurations.html#udp-bootloader-configurations"
  },"319": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Specific User Configurations",
    "content": "For Basic Bootloader . For Live Update Bootloader . | Bootloader NVM Memory Used: . | Specifies the memory peripheral used by bootloader to perform flash operations | The name of the peripheral will vary from device to device | . | Bootloader Size (Bytes): . | Specifies the maximum size of flash required by the bootloader | This size is calculated based on Bootloader type and Memory used | This size will vary from device to device and should always be aligned to device erase unit size | . | Enable Bootloader Trigger From Firmware: (Basic Mode Only) . | This Option can be used to Force Trigger bootloader from application firmware after a soft reset. It does so by reserving the specified number of bytes in SRAM from the start of the RAM. The reserved memory is updated by the application with a pre-defined pattern. The bootloader firmware in the bootloader_Trigger() routine, can check the reserved memory for the pre-defined pattern and enter bootloader mode if the pattern matches. | Number Of Bytes To Reserve From Start Of RAM: . | This option adds the provided offset to RAM Start address in bootloader linker script. | Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader to check at reset in bootloader_Trigger() function | . | . | Bootloader UDP Port Number: . | Port number to be used to communicate via Unified Host Application | . | Use Dual Bank For Live Update: . | Used to configure bootloader library to use Inactive bank of the device to upload the new application | This option is visible only for devices supporting Dual flash banks . | Live Update Flash Bank Size (Bytes): . | Specifies the size of bank in which both the bootloader and application code reside. Thisvalue by default will be half of the available Flash memory | . | Trigger Reset After Update: . | This option can be used to trigger a Swap bank and reset immediatly after programming the application in inactive bank. | If not enabled, then the application code should call the bootloader_SwapAndReset() function to trigger Swap bank and reset | . | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_configurations.html#bootloader-specific-user-configurations",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_configurations.html#bootloader-specific-user-configurations"
  },"320": {
    "doc": "Bootloader Configurations",
    "title": "UDP Configurations",
    "content": ". | IPv4 Static Address: 102.168.1.11 . | To be used to configure Unified Host Application | . | IPv4 SubNet Mask: 255.255.255.0 | IPv4 Default Gateway Address: 102.168.1.11 | IPv4 Primary DNS: 102.168.1.11 | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_configurations.html#udp-configurations",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_configurations.html#udp-configurations"
  },"321": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader System Configurations (Basic Mode Only)",
    "content": ". | Application Start Address (Hex): . | Start address of the application which will programmed by bootloader | This value is filled by bootloader when its loaded which is equal to the bootloader size. It can be modified as per user need | This value will be used by bootloader to Jump to application at device reset | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_configurations.html#bootloader-system-configurations-basic-mode-only",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_configurations.html#bootloader-system-configurations-basic-mode-only"
  },"322": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Linker Pre Processor Macros for CORTEX-M based MCUs",
    "content": ". | Based on the configurations the above linker pre processor macros will be generated in MPLAB X xc32-ld settings . | ROM_LENGTH specifies the size of the bootloader | . | . Basic Mode . Live Update Mode . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_configurations.html#bootloader-linker-pre-processor-macros-for-cortex-m-based-mcus",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_configurations.html#bootloader-linker-pre-processor-macros-for-cortex-m-based-mcus"
  },"323": {
    "doc": "Bootloader Configurations",
    "title": "Additional Information",
    "content": ". | Refer to MIPS Bootloader Linker Script Configurations for information on bootloader linker script generated by MHC for MIPS based MCUs . | Refer to Bootloader Sizing And Considerations for information on bootloader size change considerations . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_configurations.html#additional-information",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_configurations.html#additional-information"
  },"324": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_configurations.html",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_configurations.html"
  },"325": {
    "doc": "UDP Bootloader Firmware Update Execution Flow",
    "title": "UDP Bootloader Firmware Update mode execution flow",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_firmware_update_execution_flow.html#udp-bootloader-firmware-update-mode-execution-flow",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_firmware_update_execution_flow.html#udp-bootloader-firmware-update-mode-execution-flow"
  },"326": {
    "doc": "UDP Bootloader Firmware Update Execution Flow",
    "title": "Bootloader Task Flow",
    "content": ". | Erases the Flash memory . | Programs the hex file records into Flash memory . | Jumps to the Application . | Calls the DataStream Task at end of its every state machine execution to receive any packet from the Host PC . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_firmware_update_execution_flow.html#bootloader-task-flow",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_firmware_update_execution_flow.html#bootloader-task-flow"
  },"327": {
    "doc": "UDP Bootloader Firmware Update Execution Flow",
    "title": "DataStream Task Flow",
    "content": ". | This task is used to receive data bytes from host PC and to send response to host PC . | It notifies the Bootloader task on completion of Data Reception or data transmit through callback . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_firmware_update_execution_flow.html#datastream-task-flow",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_firmware_update_execution_flow.html#datastream-task-flow"
  },"328": {
    "doc": "UDP Bootloader Firmware Update Execution Flow",
    "title": "UDP Bootloader Firmware Update Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_firmware_update_execution_flow.html",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_firmware_update_execution_flow.html"
  },"329": {
    "doc": "How The Library Works",
    "title": "How the UDP Bootloader library works",
    "content": "The UDP Bootloader firmware communicates with the Unified Host application running on Host PC by using a predefined communication protocol. The UDP Bootloader works in two different modes . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_how_library_works.html#how-the-udp-bootloader-library-works",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_how_library_works.html#how-the-udp-bootloader-library-works"
  },"330": {
    "doc": "How The Library Works",
    "title": "Basic Mode",
    "content": ". | This mode is supported for all the devices . | Resides from . | The starting location of the flash memory region for CORTEX-M based MCUs . | The starting location of the Boot flash memory region or Program flash memory region for MIPS based MCUs devices . | . | The Bootloader performs flash erase/program/verify operations with the application hex sent from host PC using the Unified Bootloader Host Application while in the firmware upgrade mode . | Bootloader always performs flash operation from the address received via hex record . | The application can use the entire flash memory region starting from the end of bootloader space . | . | Jumps to the application once programming is completed | . Memory layout . | Basic memory layout for CORTEX-M based MCUs . | Basic memory layout for MIPS based MCUs . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_how_library_works.html#basic-mode",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_how_library_works.html#basic-mode"
  },"331": {
    "doc": "How The Library Works",
    "title": "Live Update Mode",
    "content": ". | This mode is supported for the devices which have a Dual Bank flash memory . | Resides from . | The starting location of the flash memory region of both the banks on CORTEX-M based MCUs along with application code . | The starting location of the Program flash memory region of both the banks for MIPS based MCUs devices along with application code . | . | The Bootloader task performs flash erase/program/verify operations with the application hex sent from host PC using the Unified Bootloader Host Application in the Inactive bank . | Performs a bank swap and reset to run the application programmed in inactive bank on application task request . | For more information refer to below memory layouts | . Memory layout . | Live Update memory layout for CORTEX-M based MCUs . | Live Update memory layout for MIPS based MCUs . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_how_library_works.html#live-update-mode",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_how_library_works.html#live-update-mode"
  },"332": {
    "doc": "How The Library Works",
    "title": "Additional Information",
    "content": ". | For information on protocol used refer to UDP Bootloader Protocol | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_how_library_works.html#additional-information",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_how_library_works.html#additional-information"
  },"333": {
    "doc": "How The Library Works",
    "title": "How The Library Works",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_how_library_works.html",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_how_library_works.html"
  },"334": {
    "doc": "Library Interface",
    "title": "UDP Bootloader Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_library_interface.html#udp-bootloader-library-interface",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_library_interface.html#udp-bootloader-library-interface"
  },"335": {
    "doc": "Library Interface",
    "title": "Table of contents",
    "content": ". | System functions . | bootloader_Tasks | bootloader_Trigger | run_Application | bootloader_SwapAndReset | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_library_interface.html#table-of-contents",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_library_interface.html#table-of-contents"
  },"336": {
    "doc": "Library Interface",
    "title": "System functions",
    "content": "bootloader_Tasks . void bootloader_Tasks(void) . Summary . Starts bootloader execution. Description . This function can be used to start bootloader execution. The function waits for application firmware from the HOST-PC via UDP communication protocol to program into internal flash memory. Once the complete application is received, programmed and verified successfully, it resets the device to jump into programmed application. Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . bootloader_Tasks(); . bootloader_Trigger . bool bootloader_Trigger(void); . Summary . Checks if Bootloader has to be executed at startup. Description . This function can be used to check for a External HW trigger or Internal firmware trigger to execute bootloader at startup. This function has to be implemented by the bootloader application to override the WEAK implementation in bootloader.c . The checks in trigger function should happen before any system resources are initialized apart for PORT, As the same system resource can be Re-initialized by the application if bootloader jumps to it and may cause issues. | External Trigger: . | Can be achieved by triggering a GPIO_PIN at startup. | . | Firmware Trigger: . | Application firmware which wants to execute bootloader at startup needs to fill first n bytes of ram location with a request pattern. The Number of bytes to be reserved for storing the pattern has to be configured in bootloader component configuration in MHC. | . | . uint32_t *sram = (uint32_t *)BTL_TRIGGER_RAM_START; sram[0] = 0x5048434D; sram[1] = 0x5048434D; sram[2] = 0x5048434D; sram[3] = 0x5048434D; . | Note: This API will not be generated when Live Update Support is enabled | . Precondition . PORT/PIO Initialize must have been called. Parameters . None . Returns . | True : If any of trigger is detected. | False : If no trigger is detected.. | . Example . #define BTL_TRIGGER_PATTERN 0x5048434D static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START; bool bootloader_Trigger(void) { // Check for Bootloader Trigger Pattern in first 16 Bytes of RAM to enter Bootloader. if (BTL_TRIGGER_PATTERN == ramStart[0] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[1] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[2] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[3]) { ramStart[0] = 0; return true; } // Check for Switch press to enter Bootloader if (SWITCH_Get() == 0) { return true; } return false; } void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . run_Application . void run_Application(void); . Summary . Runs the programmed application at startup. Description . This function can be used to run programmed application though bootloader at startup. If the first 4Bytes of Application Memory is not 0xFFFFFFFF then it jumps to the application start address to run the application programmed through bootloader and never returns. If the first 4Bytes of Application Memory is 0xFFFFFFFF then it returns from function and executes bootloader for accepting a new application firmware. | Note: This API will not be generated when Live Update Support is enabled | . Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . bootloader_SwapAndReset . void bootloader_SwapAndReset( void ); . Summary . Updates the Serial number in Inactive Bank and triggers Reset. Description . This function can be used by the application to update the serial number in inactive bank and trigger reset after Live Update is Completed. Switcher in Boot Flash Memory should know the address at compile time where the serial number is stored in each bank. It reads the serial number from both banks, Compares the values and maps the bank with highest serial number to lower region. | Note: This Function will be generated only for MIPS based MCUs with dual flash bank support and when the dual bank for live update option is selected in MHC bootloader component settings . | Refer to Bootloader Configurations section for more details | . | . Precondition . | Live Update has to be completed before calling this function | . Parameters . None . Returns . None . Example . bootloader_SwapAndReset(); . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_library_interface.html#system-functions",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_library_interface.html#system-functions"
  },"337": {
    "doc": "Library Interface",
    "title": "Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_library_interface.html",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_library_interface.html"
  },"338": {
    "doc": "UDP Bootloader Protocol",
    "title": "UDP Bootloader Protocol",
    "content": "The Unified host application running on Host-PC uses below communication protocol to interact with the Bootloader firmware. The Unified host application acts as a master and issues commands to the Bootloader firmware to perform specific operations. ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_protocol.html#udp-bootloader-protocol",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_protocol.html#udp-bootloader-protocol"
  },"339": {
    "doc": "UDP Bootloader Protocol",
    "title": "Frame Format",
    "content": "The communication protocol follows the frame format, as shown below . [&lt;SOH&gt;…]&lt;SOH&gt;[&lt;DATA&gt;…]&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; . Where: . &lt;…&gt; Represents a byte . […] Represents an optional or variable number of bytes . | The frame format remains the same in both directions, that is, from the host application to the Bootloader, and from the Bootloader to the host application. | The frame starts with a control character, Start of Header (SOH), and ends with another control character, End of Transmission (EOT) . | The integrity of the frame is protected by two bytes of Cyclic Redundancy Check (CRC)-16, represented by CRCL (low-byte) and CRCH (high-byte) . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_protocol.html#frame-format",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_protocol.html#frame-format"
  },"340": {
    "doc": "UDP Bootloader Protocol",
    "title": "Control Characters",
    "content": "Some bytes in the Data field may imitate the control characters, SOH and EOT. The Data Link Escape (DLE) character is used to escape such bytes that could be interpreted as control characters. The Bootloader always accepts the byte following a &lt;DLE&gt; as data, and always sends a &lt;DLE&gt; before any of the control characters. | Control | Hex Value | Description | . | &lt;SOH&gt; | 0x01 | Marks the beginning of a frame | . | &lt;EOT&gt; | 0x04 | Marks the end of a frame | . | &lt;DLE&gt; | 0x10 | Data link escape | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_protocol.html#control-characters",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_protocol.html#control-characters"
  },"341": {
    "doc": "UDP Bootloader Protocol",
    "title": "Commands",
    "content": "The PC host application can issue the commands listed in below to the Bootloader. The first byte in the data field carries the command. | Command Value in Hexadecimal | Description | . | 0x01 | Read the Bootloader version information. | . | 0x02 | Erase the Flash. | . | 0x03 | Program the Flash. | . | 0x04 | Read the CRC. | . | 0x05 | Jump to the application. | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_protocol.html#commands",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_protocol.html#commands"
  },"342": {
    "doc": "UDP Bootloader Protocol",
    "title": "Read Bootloader Version Information",
    "content": "The Read Version command sequence is as shown in below table with corresponding response . | Request | Response | . | [&lt;SOH&gt;…]&lt;SOH&gt;[&lt;0x01&gt;]&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x01&gt;&lt;MAJOR_VER&gt;&lt;MINOR_VER&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | . | The Bootloader responds to the PC request for version information in two bytes as shown above . | MAJOR_VER = Major version of the Bootloader | MINOR_VER = Minor version of the Bootloader | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_protocol.html#read-bootloader-version-information",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_protocol.html#read-bootloader-version-information"
  },"343": {
    "doc": "UDP Bootloader Protocol",
    "title": "Erase Flash",
    "content": "The Erase Flash command sequence is as shown in below table with corresponding response . | Request | Response | . | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x02&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x02&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | . | On receiving the erase Flash command from the PC host application, the Bootloader erases that entire application program space starting from the application start address configured . | The Bootloader Task routine returns only after entire application space is erased . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_protocol.html#erase-flash",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_protocol.html#erase-flash"
  },"344": {
    "doc": "UDP Bootloader Protocol",
    "title": "Program Flash",
    "content": "The Program Flash command sequence is as shown in below table with corresponding response . | Request | Response | . | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x03&gt;[&lt;HEX_RECORD&gt;…]&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x03&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | . | HEX_RECORD is the Intel Hex record in hexadecimal format . | The PC host application sends one or multiple hex records in Intel Hex format along with the program Flash command . | The MPLAB XC32 C/C++ Compiler generates the image in the Intel Hex format. Each line in the Intel hexadecimal file represents a hexadecimal record . | Each hexadecimal record starts with a colon (:) and is in ASCII format. The PC host application discards the colon and converts the remaining data from ASCII to hexadecimal, and then sends the data to the Bootloader . | The Bootloader extracts the destination address and data from the hex record, and writes the data into program Flash . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_protocol.html#program-flash",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_protocol.html#program-flash"
  },"345": {
    "doc": "UDP Bootloader Protocol",
    "title": "Read CRC (Currently Not Supported)",
    "content": "The Read CRC command sequence is as shown in below table with corresponding response . | Request | Response | . | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x04&gt;&lt;ADRS_LB&gt;&lt;ADRS_HB&gt;&lt;ADRS_UB&gt;&lt;ADRS_MB&gt;&lt;NUMBYTES_LB&gt;&lt;NUMBYTES_HB&gt;&lt;NUMBYTES_UB&gt;&lt;NUMBYTES_MB&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x04&gt;&lt;FLASH_CRCL&gt;&lt;FLASH_CRCH&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | . | The read CRC command is used to verify the content of the program Flash after programming . | ADRS_LB, ADRS_HB, ADRS_UB and ADRS_MB represent the 32-bit Flash addresses from where the CRC calculation begins . | NUMBYTES_LB, NUMBYTES_HB, NUMBYTES_UB and NUMBYTES_MB represent the total number of bytes in 32-bit format for which the CRC is to be calculated . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_protocol.html#read-crc-currently-not-supported",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_protocol.html#read-crc-currently-not-supported"
  },"346": {
    "doc": "UDP Bootloader Protocol",
    "title": "Jump to Application",
    "content": "The Jump To Application command sequence is as shown in below table with corresponding response . | Request | Response | . | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x05&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x05&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | . | The Jump to Application command from the PC host application commands the Bootloader to execute the application . | Once response is sent it exits the firmware upgrade mode and begins executing the application . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_protocol.html#jump-to-application",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_protocol.html#jump-to-application"
  },"347": {
    "doc": "UDP Bootloader Protocol",
    "title": "UDP Bootloader Protocol",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_protocol.html",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_protocol.html"
  },"348": {
    "doc": "Bootloader System Execution Flow",
    "title": "UDP Bootloader system level execution flow",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_system_execution_flow.html#udp-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_system_execution_flow.html#udp-bootloader-system-level-execution-flow"
  },"349": {
    "doc": "Bootloader System Execution Flow",
    "title": "Basic Bootloader system level execution flow",
    "content": ". | The Bootloader code starts executing on a device Reset . | If there are no conditions to enter the firmware upgrade mode, the Bootloader starts executing the user application . | Refer to Bootloader Trigger Methods for different conditions to enter firmware upgrade mode | . | The Bootloader performs Flash erase/program operations while in the firmware upgrade mode . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_system_execution_flow.html#basic-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_system_execution_flow.html#basic-bootloader-system-level-execution-flow"
  },"350": {
    "doc": "Bootloader System Execution Flow",
    "title": "Live Update Bootloader system level execution flow",
    "content": ". | Supported for the devices which have a Dual Bank flash memory | . Cortex-M Based MCUs . | Special NVM Fuse setting (AFIRST) is used to identify which bank is mapped to NVM main address space after reset . | The bootloader live update code responsible to program the inactive bank is part of the application it self. Which means the programming operation can happen while the application is running . | Live Update Application = (Bootloader Code in Live Update mode + Application code) | . | The application code is responsible to send a request to bootloader live update code to perform a bank swap and reset to run the new firmware programmed in Inactive bank | . MIPS Based MCUs . | Switcher Application in Boot flash memory is required to select the bank with latest firmware . | At reset switcher first maps Bank 1 to lower region and reads the serial numbers from both banks . | If Bank 2 serial number is greater than Bank 1 serial number, it maps Bank 2 to lower region by setting the Swap bit and runs the new firmware from BANK 2 else continues to run firmware from BANK 1 . | . | The bootloader live update code responsible to program the inactive bank is part of the application it self. Which means the programming operation can happen while the application is running . | Live Update Application = (Bootloader Code in Live Update mode + Application code) | . | The bootloader live update code will always program the new image in the inactive bank . | The application code is responsible to send a request to bootloader live update code to perform a bank swap and reset to run the new firmware programmed in Inactive bank . | Once this request is received the bootloader live update code performs below operation before initiating a reset to run new firmware . | Inactive Serial number = Active serial number + 1 | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_system_execution_flow.html#live-update-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_system_execution_flow.html#live-update-bootloader-system-level-execution-flow"
  },"351": {
    "doc": "Bootloader System Execution Flow",
    "title": "Additional Information",
    "content": ". | Refer to Firmware Update Mode execution flow to understand how the firmware update takes place in bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_system_execution_flow.html#additional-information",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_system_execution_flow.html#additional-information"
  },"352": {
    "doc": "Bootloader System Execution Flow",
    "title": "Bootloader System Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_bootloader_system_execution_flow.html",
    "relUrl": "/templates/src/unified/docs/udp/udp_bootloader_system_execution_flow.html"
  },"353": {
    "doc": "Debugging Help",
    "title": "Debugging UDP Bootloader and Application to be bootloaded",
    "content": ". | Refer to Debugging Bootloader And Application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_debugging.html#debugging-udp-bootloader-and-application-to-be-bootloaded",
    "relUrl": "/templates/src/unified/docs/udp/udp_debugging.html#debugging-udp-bootloader-and-application-to-be-bootloaded"
  },"354": {
    "doc": "Debugging Help",
    "title": "Debugging Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/udp/udp_debugging.html",
    "relUrl": "/templates/src/unified/docs/udp/udp_debugging.html"
  },"355": {
    "doc": "Application Configurations",
    "title": "Configurations for the application to be bootloaded",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_application_configurations.html#configurations-for-the-application-to-be-bootloaded",
    "relUrl": "/templates/src/unified/docs/usb/usb_application_configurations.html#configurations-for-the-application-to-be-bootloaded"
  },"356": {
    "doc": "Application Configurations",
    "title": "For CORTEX-M based MCUs",
    "content": ". | Refer to Application project Configurations for information on how to configure an application to be bootloaded for CORTEX-M based MCus | . For MIPS based MCUs . | Refer to Application Linker Script Configurations for information on how to setup a linker script for the application to be bootloaded for MIPS based MCus . | Refer to Application project Configurations for information on how to configure an application to be bootloaded for MIPS based MCus . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_application_configurations.html#for-cortex-m-based-mcus",
    "relUrl": "/templates/src/unified/docs/usb/usb_application_configurations.html#for-cortex-m-based-mcus"
  },"357": {
    "doc": "Application Configurations",
    "title": "Application Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_application_configurations.html",
    "relUrl": "/templates/src/unified/docs/usb/usb_application_configurations.html"
  },"358": {
    "doc": "Bootloader Configurations",
    "title": "USB Device HID Bootloader Configurations",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_configurations.html#usb-device-hid-bootloader-configurations",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_configurations.html#usb-device-hid-bootloader-configurations"
  },"359": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Specific User Configurations",
    "content": "For Basic Bootloader . For Live Update Bootloader . | Bootloader NVM Memory Used: . | Specifies the memory peripheral used by bootloader to perform flash operations | The name of the peripheral will vary from device to device | . | Bootloader Size (Bytes): . | Specifies the maximum size of flash required by the bootloader | This size is calculated based on Bootloader type and Memory used | This size will vary from device to device and should always be aligned to device erase unit size | . | Enable Bootloader Trigger From Firmware: (Basic Mode Only) . | This Option can be used to Force Trigger bootloader from application firmware after a soft reset. It does so by reserving the specified number of bytes in SRAM from the start of the RAM. The reserved memory is updated by the application with a pre-defined pattern. The bootloader firmware in the bootloader_Trigger() routine, can check the reserved memory for the pre-defined pattern and enter bootloader mode if the pattern matches. | Number Of Bytes To Reserve From Start Of RAM: . | This option adds the provided offset to RAM Start address in bootloader linker script. | Application firmware can store some pattern in the reserved bytes region from RAM start for bootloader to check at reset in bootloader_Trigger() function | . | . | Use Dual Bank For Live Update: . | Used to configure bootloader library to use Inactive bank of the device to upload the new application | This option is visible only for devices supporting Dual flash banks . | Live Update Flash Bank Size (Bytes): . | Specifies the size of bank in which both the bootloader and application code reside. Thisvalue by default will be half of the available Flash memory | . | Trigger Reset After Update: . | This option can be used to trigger a Swap bank and reset immediatly after programming the application in inactive bank. | If not enabled, then the application code should call the bootloader_SwapAndReset() function to trigger Swap bank and reset | . | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_configurations.html#bootloader-specific-user-configurations",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_configurations.html#bootloader-specific-user-configurations"
  },"360": {
    "doc": "Bootloader Configurations",
    "title": "USB Device HID Driver Configurations",
    "content": ". | Vendor ID: 0x04D8 | Product Id Selection: usb_device_hid_bootloader | Product ID: 0x003C . | To be used to configure Unified Host Application | . | Product String Selection: USB HID Bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_configurations.html#usb-device-hid-driver-configurations",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_configurations.html#usb-device-hid-driver-configurations"
  },"361": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader System Configurations (Basic Mode Only)",
    "content": ". | Application Start Address (Hex): . | Start address of the application which will programmed by bootloader | This value is filled by bootloader when its loaded which is equal to the bootloader size. It can be modified as per user need | This value will be used by bootloader to Jump to application at device reset | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_configurations.html#bootloader-system-configurations-basic-mode-only",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_configurations.html#bootloader-system-configurations-basic-mode-only"
  },"362": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Linker Pre Processor Macros for CORTEX-M based MCUs",
    "content": ". | Based on the configurations the above linker pre processor macros will be generated in MPLAB X xc32-ld settings . | ROM_LENGTH specifies the size of the bootloader | . | . Basic Mode . Live Update Mode . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_configurations.html#bootloader-linker-pre-processor-macros-for-cortex-m-based-mcus",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_configurations.html#bootloader-linker-pre-processor-macros-for-cortex-m-based-mcus"
  },"363": {
    "doc": "Bootloader Configurations",
    "title": "Additional Information",
    "content": ". | Refer to MIPS Bootloader Linker Script Configurations for information on bootloader linker script generated by MHC for MIPS based MCUs . | Refer to Bootloader Sizing And Considerations for information on bootloader size change considerations . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_configurations.html#additional-information",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_configurations.html#additional-information"
  },"364": {
    "doc": "Bootloader Configurations",
    "title": "Bootloader Configurations",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_configurations.html",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_configurations.html"
  },"365": {
    "doc": "USB Device HID Bootloader Firmware Update Execution Flow",
    "title": "USB Device HID Bootloader Firmware Update mode execution flow",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_firmware_update_execution_flow.html#usb-device-hid-bootloader-firmware-update-mode-execution-flow",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_firmware_update_execution_flow.html#usb-device-hid-bootloader-firmware-update-mode-execution-flow"
  },"366": {
    "doc": "USB Device HID Bootloader Firmware Update Execution Flow",
    "title": "Bootloader Task Flow",
    "content": ". | Erases the Flash memory . | Programs the hex file records into Flash memory . | Jumps to the Application . | Calls the DataStream Task at end of its every state machine execution to receive any packet from the Host PC . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_firmware_update_execution_flow.html#bootloader-task-flow",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_firmware_update_execution_flow.html#bootloader-task-flow"
  },"367": {
    "doc": "USB Device HID Bootloader Firmware Update Execution Flow",
    "title": "DataStream Task Flow",
    "content": ". | This task is used to receive data bytes from host PC and to send response to host PC . | It notifies the Bootloader task on completion of Data Reception or data transmit through callback . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_firmware_update_execution_flow.html#datastream-task-flow",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_firmware_update_execution_flow.html#datastream-task-flow"
  },"368": {
    "doc": "USB Device HID Bootloader Firmware Update Execution Flow",
    "title": "USB Device HID Bootloader Firmware Update Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_firmware_update_execution_flow.html",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_firmware_update_execution_flow.html"
  },"369": {
    "doc": "How The Library Works",
    "title": "How the USB Device HID Bootloader library works",
    "content": "The USB Device HID Bootloader firmware communicates with the Unified Host application running on Host PC by using a predefined communication protocol. The USB Device HID Bootloader works in two different modes . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_how_library_works.html#how-the-usb-device-hid-bootloader-library-works",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_how_library_works.html#how-the-usb-device-hid-bootloader-library-works"
  },"370": {
    "doc": "How The Library Works",
    "title": "Basic Mode",
    "content": ". | This mode is supported for all the devices . | Resides from . | The starting location of the flash memory region for CORTEX-M based MCUs . | The starting location of the Boot flash memory region or Program flash memory region for MIPS based MCUs devices . | . | The Bootloader performs flash erase/program/verify operations with the application hex sent from host PC using the Unified Bootloader Host Application while in the firmware upgrade mode . | Bootloader always performs flash operation from the address received via hex record . | The application can use the entire flash memory region starting from the end of bootloader space . | . | Jumps to the application once programming is completed | . Memory layout . | Basic memory layout for CORTEX-M based MCUs . | Basic memory layout for MIPS based MCUs . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_how_library_works.html#basic-mode",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_how_library_works.html#basic-mode"
  },"371": {
    "doc": "How The Library Works",
    "title": "Live Update Mode",
    "content": ". | This mode is supported for the devices which have a Dual Bank flash memory . | Resides from . | The starting location of the flash memory region of both the banks on CORTEX-M based MCUs along with application code . | The starting location of the Program flash memory region of both the banks for MIPS based MCUs devices along with application code . | . | The Bootloader task performs flash erase/program/verify operations with the application hex sent from host PC using the Unified Bootloader Host Application in the Inactive bank . | Performs a bank swap and reset to run the application programmed in inactive bank on application task request . | For more information refer to below memory layouts | . Memory layout . | Live Update memory layout for CORTEX-M based MCUs . | Live Update memory layout for MIPS based MCUs . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_how_library_works.html#live-update-mode",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_how_library_works.html#live-update-mode"
  },"372": {
    "doc": "How The Library Works",
    "title": "Additional Information",
    "content": ". | For information on protocol used refer to USB Device HID Bootloader Protocol | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_how_library_works.html#additional-information",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_how_library_works.html#additional-information"
  },"373": {
    "doc": "How The Library Works",
    "title": "How The Library Works",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_how_library_works.html",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_how_library_works.html"
  },"374": {
    "doc": "Library Interface",
    "title": "USB Device HID Bootloader Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_library_interface.html#usb-device-hid-bootloader-library-interface",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_library_interface.html#usb-device-hid-bootloader-library-interface"
  },"375": {
    "doc": "Library Interface",
    "title": "Table of contents",
    "content": ". | System functions . | bootloader_Tasks | bootloader_Trigger | run_Application | bootloader_SwapAndReset | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_library_interface.html#table-of-contents",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_library_interface.html#table-of-contents"
  },"376": {
    "doc": "Library Interface",
    "title": "System functions",
    "content": "bootloader_Tasks . void bootloader_Tasks(void) . Summary . Starts bootloader execution. Description . This function can be used to start bootloader execution. The function waits for application firmware from the HOST-PC via USB Device HID communication protocol to program into internal flash memory. Once the complete application is received, programmed and verified successfully, it resets the device to jump into programmed application. Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . bootloader_Tasks(); . bootloader_Trigger . bool bootloader_Trigger(void); . Summary . Checks if Bootloader has to be executed at startup. Description . This function can be used to check for a External HW trigger or Internal firmware trigger to execute bootloader at startup. This function has to be implemented by the bootloader application to override the WEAK implementation in bootloader.c . The checks in trigger function should happen before any system resources are initialized apart for PORT, As the same system resource can be Re-initialized by the application if bootloader jumps to it and may cause issues. | External Trigger: . | Can be achieved by triggering a GPIO_PIN at startup. | . | Firmware Trigger: . | Application firmware which wants to execute bootloader at startup needs to fill first n bytes of ram location with a request pattern. The Number of bytes to be reserved for storing the pattern has to be configured in bootloader component configuration in MHC. | . | . uint32_t *sram = (uint32_t *)BTL_TRIGGER_RAM_START; sram[0] = 0x5048434D; sram[1] = 0x5048434D; sram[2] = 0x5048434D; sram[3] = 0x5048434D; . | Note: This API will not be generated when Live Update Support is enabled | . Precondition . PORT/PIO Initialize must have been called. Parameters . None . Returns . | True : If any of trigger is detected. | False : If no trigger is detected.. | . Example . #define BTL_TRIGGER_PATTERN 0x5048434D static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START; bool bootloader_Trigger(void) { // Check for Bootloader Trigger Pattern in first 16 Bytes of RAM to enter Bootloader. if (BTL_TRIGGER_PATTERN == ramStart[0] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[1] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[2] &amp;&amp; BTL_TRIGGER_PATTERN == ramStart[3]) { ramStart[0] = 0; return true; } // Check for Switch press to enter Bootloader if (SWITCH_Get() == 0) { return true; } return false; } void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . run_Application . void run_Application(void); . Summary . Runs the programmed application at startup. Description . This function can be used to run programmed application though bootloader at startup. If the first 4Bytes of Application Memory is not 0xFFFFFFFF then it jumps to the application start address to run the application programmed through bootloader and never returns. If the first 4Bytes of Application Memory is 0xFFFFFFFF then it returns from function and executes bootloader for accepting a new application firmware. | Note: This API will not be generated when Live Update Support is enabled | . Precondition . bootloader_Trigger() must be called to check for bootloader triggers at startup. Parameters . None . Returns . None . Example . void SYS_Initialize() { NVMCTRL_Initialize(); PORT_Initialize(); if (bootloader_Trigger() == false) { run_Application(); } CLOCK_Initialize(); } . bootloader_SwapAndReset . void bootloader_SwapAndReset( void ); . Summary . Updates the Serial number in Inactive Bank and triggers Reset. Description . This function can be used by the application to update the serial number in inactive bank and trigger reset after Live Update is Completed. Switcher in Boot Flash Memory should know the address at compile time where the serial number is stored in each bank. It reads the serial number from both banks, Compares the values and maps the bank with highest serial number to lower region. | Note: This Function will be generated only for MIPS based MCUs with dual flash bank support and when the dual bank for live update option is selected in MHC bootloader component settings . | Refer to Bootloader Configurations section for more details | . | . Precondition . | Live Update has to be completed before calling this function | . Parameters . None . Returns . None . Example . bootloader_SwapAndReset(); . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_library_interface.html#system-functions",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_library_interface.html#system-functions"
  },"377": {
    "doc": "Library Interface",
    "title": "Library Interface",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_library_interface.html",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_library_interface.html"
  },"378": {
    "doc": "USB Device HID Bootloader Protocol",
    "title": "USB Device HID Bootloader Protocol",
    "content": "The Unified host application running on Host-PC uses below communication protocol to interact with the Bootloader firmware. The Unified host application acts as a master and issues commands to the Bootloader firmware to perform specific operations. ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_protocol.html#usb-device-hid-bootloader-protocol",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_protocol.html#usb-device-hid-bootloader-protocol"
  },"379": {
    "doc": "USB Device HID Bootloader Protocol",
    "title": "Frame Format",
    "content": "The communication protocol follows the frame format, as shown below . [&lt;SOH&gt;…]&lt;SOH&gt;[&lt;DATA&gt;…]&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; . Where: . &lt;…&gt; Represents a byte . […] Represents an optional or variable number of bytes . | The frame format remains the same in both directions, that is, from the host application to the Bootloader, and from the Bootloader to the host application. | The frame starts with a control character, Start of Header (SOH), and ends with another control character, End of Transmission (EOT) . | The integrity of the frame is protected by two bytes of Cyclic Redundancy Check (CRC)-16, represented by CRCL (low-byte) and CRCH (high-byte) . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_protocol.html#frame-format",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_protocol.html#frame-format"
  },"380": {
    "doc": "USB Device HID Bootloader Protocol",
    "title": "Control Characters",
    "content": "Some bytes in the Data field may imitate the control characters, SOH and EOT. The Data Link Escape (DLE) character is used to escape such bytes that could be interpreted as control characters. The Bootloader always accepts the byte following a &lt;DLE&gt; as data, and always sends a &lt;DLE&gt; before any of the control characters. | Control | Hex Value | Description | . | &lt;SOH&gt; | 0x01 | Marks the beginning of a frame | . | &lt;EOT&gt; | 0x04 | Marks the end of a frame | . | &lt;DLE&gt; | 0x10 | Data link escape | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_protocol.html#control-characters",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_protocol.html#control-characters"
  },"381": {
    "doc": "USB Device HID Bootloader Protocol",
    "title": "Commands",
    "content": "The PC host application can issue the commands listed in below to the Bootloader. The first byte in the data field carries the command. | Command Value in Hexadecimal | Description | . | 0x01 | Read the Bootloader version information. | . | 0x02 | Erase the Flash. | . | 0x03 | Program the Flash. | . | 0x04 | Read the CRC. | . | 0x05 | Jump to the application. | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_protocol.html#commands",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_protocol.html#commands"
  },"382": {
    "doc": "USB Device HID Bootloader Protocol",
    "title": "Read Bootloader Version Information",
    "content": "The Read Version command sequence is as shown in below table with corresponding response . | Request | Response | . | [&lt;SOH&gt;…]&lt;SOH&gt;[&lt;0x01&gt;]&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x01&gt;&lt;MAJOR_VER&gt;&lt;MINOR_VER&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | . | The Bootloader responds to the PC request for version information in two bytes as shown above . | MAJOR_VER = Major version of the Bootloader | MINOR_VER = Minor version of the Bootloader | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_protocol.html#read-bootloader-version-information",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_protocol.html#read-bootloader-version-information"
  },"383": {
    "doc": "USB Device HID Bootloader Protocol",
    "title": "Erase Flash",
    "content": "The Erase Flash command sequence is as shown in below table with corresponding response . | Request | Response | . | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x02&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x02&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | . | On receiving the erase Flash command from the PC host application, the Bootloader erases that entire application program space starting from the application start address configured . | The Bootloader Task routine returns only after entire application space is erased . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_protocol.html#erase-flash",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_protocol.html#erase-flash"
  },"384": {
    "doc": "USB Device HID Bootloader Protocol",
    "title": "Program Flash",
    "content": "The Program Flash command sequence is as shown in below table with corresponding response . | Request | Response | . | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x03&gt;[&lt;HEX_RECORD&gt;…]&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x03&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | . | HEX_RECORD is the Intel Hex record in hexadecimal format . | The PC host application sends one or multiple hex records in Intel Hex format along with the program Flash command . | The MPLAB XC32 C/C++ Compiler generates the image in the Intel Hex format. Each line in the Intel hexadecimal file represents a hexadecimal record . | Each hexadecimal record starts with a colon (:) and is in ASCII format. The PC host application discards the colon and converts the remaining data from ASCII to hexadecimal, and then sends the data to the Bootloader . | The Bootloader extracts the destination address and data from the hex record, and writes the data into program Flash . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_protocol.html#program-flash",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_protocol.html#program-flash"
  },"385": {
    "doc": "USB Device HID Bootloader Protocol",
    "title": "Read CRC (Currently Not Supported)",
    "content": "The Read CRC command sequence is as shown in below table with corresponding response . | Request | Response | . | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x04&gt;&lt;ADRS_LB&gt;&lt;ADRS_HB&gt;&lt;ADRS_UB&gt;&lt;ADRS_MB&gt;&lt;NUMBYTES_LB&gt;&lt;NUMBYTES_HB&gt;&lt;NUMBYTES_UB&gt;&lt;NUMBYTES_MB&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x04&gt;&lt;FLASH_CRCL&gt;&lt;FLASH_CRCH&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | . | The read CRC command is used to verify the content of the program Flash after programming . | ADRS_LB, ADRS_HB, ADRS_UB and ADRS_MB represent the 32-bit Flash addresses from where the CRC calculation begins . | NUMBYTES_LB, NUMBYTES_HB, NUMBYTES_UB and NUMBYTES_MB represent the total number of bytes in 32-bit format for which the CRC is to be calculated . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_protocol.html#read-crc-currently-not-supported",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_protocol.html#read-crc-currently-not-supported"
  },"386": {
    "doc": "USB Device HID Bootloader Protocol",
    "title": "Jump to Application",
    "content": "The Jump To Application command sequence is as shown in below table with corresponding response . | Request | Response | . | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x05&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | [&lt;SOH&gt;…]&lt;SOH&gt;&lt;0x05&gt;&lt;CRCL&gt;&lt;CRCH&gt;&lt;EOT&gt; | . | The Jump to Application command from the PC host application commands the Bootloader to execute the application . | Once response is sent it exits the firmware upgrade mode and begins executing the application . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_protocol.html#jump-to-application",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_protocol.html#jump-to-application"
  },"387": {
    "doc": "USB Device HID Bootloader Protocol",
    "title": "USB Device HID Bootloader Protocol",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_protocol.html",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_protocol.html"
  },"388": {
    "doc": "Bootloader System Execution Flow",
    "title": "USB Device HID Bootloader system level execution flow",
    "content": " ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_system_execution_flow.html#usb-device-hid-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_system_execution_flow.html#usb-device-hid-bootloader-system-level-execution-flow"
  },"389": {
    "doc": "Bootloader System Execution Flow",
    "title": "Basic Bootloader system level execution flow",
    "content": ". | The Bootloader code starts executing on a device Reset . | If there are no conditions to enter the firmware upgrade mode, the Bootloader starts executing the user application . | Refer to Bootloader Trigger Methods for different conditions to enter firmware upgrade mode | . | The Bootloader performs Flash erase/program operations while in the firmware upgrade mode . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_system_execution_flow.html#basic-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_system_execution_flow.html#basic-bootloader-system-level-execution-flow"
  },"390": {
    "doc": "Bootloader System Execution Flow",
    "title": "Live Update Bootloader system level execution flow",
    "content": ". | Supported for the devices which have a Dual Bank flash memory | . Cortex-M Based MCUs . | Special NVM Fuse setting (AFIRST) is used to identify which bank is mapped to NVM main address space after reset . | The bootloader live update code responsible to program the inactive bank is part of the application it self. Which means the programming operation can happen while the application is running . | Live Update Application = (Bootloader Code in Live Update mode + Application code) | . | The application code is responsible to send a request to bootloader live update code to perform a bank swap and reset to run the new firmware programmed in Inactive bank | . MIPS Based MCUs . | Switcher Application in Boot flash memory is required to select the bank with latest firmware . | At reset switcher first maps Bank 1 to lower region and reads the serial numbers from both banks . | If Bank 2 serial number is greater than Bank 1 serial number, it maps Bank 2 to lower region by setting the Swap bit and runs the new firmware from BANK 2 else continues to run firmware from BANK 1 . | . | The bootloader live update code responsible to program the inactive bank is part of the application it self. Which means the programming operation can happen while the application is running . | Live Update Application = (Bootloader Code in Live Update mode + Application code) | . | The bootloader live update code will always program the new image in the inactive bank . | The application code is responsible to send a request to bootloader live update code to perform a bank swap and reset to run the new firmware programmed in Inactive bank . | Once this request is received the bootloader live update code performs below operation before initiating a reset to run new firmware . | Inactive Serial number = Active serial number + 1 | . | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_system_execution_flow.html#live-update-bootloader-system-level-execution-flow",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_system_execution_flow.html#live-update-bootloader-system-level-execution-flow"
  },"391": {
    "doc": "Bootloader System Execution Flow",
    "title": "Additional Information",
    "content": ". | Refer to Firmware Update Mode execution flow to understand how the firmware update takes place in bootloader | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_system_execution_flow.html#additional-information",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_system_execution_flow.html#additional-information"
  },"392": {
    "doc": "Bootloader System Execution Flow",
    "title": "Bootloader System Execution Flow",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_bootloader_system_execution_flow.html",
    "relUrl": "/templates/src/unified/docs/usb/usb_bootloader_system_execution_flow.html"
  },"393": {
    "doc": "Debugging Help",
    "title": "Debugging USB Device HID Bootloader and Application to be bootloaded",
    "content": ". | Refer to Debugging Bootloader And Application | . ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_debugging.html#debugging-usb-device-hid-bootloader-and-application-to-be-bootloaded",
    "relUrl": "/templates/src/unified/docs/usb/usb_debugging.html#debugging-usb-device-hid-bootloader-and-application-to-be-bootloaded"
  },"394": {
    "doc": "Debugging Help",
    "title": "Debugging Help",
    "content": ". ",
    "url": "http://localhost:4000/bootloader/templates/src/unified/docs/usb/usb_debugging.html",
    "relUrl": "/templates/src/unified/docs/usb/usb_debugging.html"
  },"395": {
    "doc": "Bootloader Library Help",
    "title": "Bootloader Library Help",
    "content": "![Microchip logo](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_logo.png) ![Harmony logo small](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_mplab_harmony_logo_small.png) # MPLAB® Harmony 3 Bootloader Module MPLAB® Harmony 3 is an extension of the MPLAB® ecosystem for creating embedded firmware solutions for Microchip 32-bit SAM and PIC® microcontroller and microprocessor devices. Refer to the following links for more information. - [Microchip 32-bit MCUs](https://www.microchip.com/design-centers/32-bit) - [Microchip 32-bit MPUs](https://www.microchip.com/design-centers/32-bit-mpus) - [Microchip MPLAB X IDE](https://www.microchip.com/mplab/mplab-x-ide) - [Microchip MPLAB Harmony](https://www.microchip.com/mplab/mplab-harmony) - [Microchip MPLAB Harmony Pages](https://microchip-mplab-harmony.github.io/) This repository contains the MPLAB® Harmony 3 Bootloader. The bootloader module components provide framework to develop bootloaders for Microchip 32-bit PIC32 and SAM microcontrollers. Refer to the following links for release notes, training materials, and interface reference information. - [Release Notes](/bootloader/release_notes.html) - [MPLAB® Harmony License](/bootloader/mplab_harmony_license.html) - [MPLAB® Harmony 3 Bootloader Wiki](https://github.com/Microchip-MPLAB-Harmony/bootloader/wiki) - [MPLAB® Harmony 3 Bootloader API Help](https://microchip-mplab-harmony.github.io/bootloader) # Contents Summary | Folder | Description |-----------|------------------------------------------------------------| config | Bootloader module configuration scripts | docs | Bootloader module library HTML help documentation | templates | Bootloader and system file templates | tools | Bootloader Host scripts | # Introduction The Bootloader Library can be used to upgrade firmware on a target device without the need for an external programmer or debugger. A Bootloader is a small application that starts the operation of the device. A Bootloader does not fully operate the device, but can perform various functions prior to starting the main application. **Such functions can include:** - Firmware upgrades - Application integrity - Starting the application ## Supported Bootloaders | Bootloader | Description |---------------------------------------------------------------------------|-------------------------------------------------------------| [UART](/bootloader/templates/src/optimized/docs/uart/readme.html) | This section provides help on the Optimized UART Bootloader library | [I2C](/bootloader/templates/src/optimized/docs/i2c/readme.html) | This section provides help on the Optimized I2C Bootloader library | [CAN](/bootloader/templates/src/optimized/docs/can/readme.html) | This section provides help on the Optimized CAN Bootloader library | [Serial Memory](/bootloader/templates/src/optimized/docs/serial_memory/readme.html) | This section provides help on the Serial Memory Bootloader library | [USB Device HID](/bootloader/templates/src/unified/docs/usb/readme.html) | This section provides help on the USB Device HID Bootloader library | [UDP](/bootloader/templates/src/unified/docs/udp/readme.html) | This section provides help on the UDP Bootloader library | [File System](/bootloader/templates/src/fs/docs/readme.html) | This section provides help on the File system Bootloader library | # Bootloader Application Repositories | Repo name | Description |-----------------------------------------------------------------------------------------------------------|---------------------------------| [bootloader_apps_uart](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_uart) | UART Bootloader Applications | [bootloader_apps_i2c](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_i2c) | I2C Bootloader Applications | [bootloader_apps_can](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_can) | CAN Bootloader Applications | [bootloader_apps_usb](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_usb) | USB Bootloader Applications | [bootloader_apps_ethernet](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_ethernet) | Ethernet Bootloader Applications| [bootloader_apps_sdcard](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_sdcard) | SDCARD Bootloader Applications | [bootloader_apps_serial_memory](https://github.com/Microchip-MPLAB-Harmony/bootloader_apps_serial_memory) | Serial Memory Bootloader Applications | ____ [![License](https://img.shields.io/badge/license-Harmony%20license-orange.svg)](https://github.com/Microchip-MPLAB-Harmony/bootloader/blob/master/mplab_harmony_license.md) [![Latest release](https://img.shields.io/github/release/Microchip-MPLAB-Harmony/bootloader.svg)](https://github.com/Microchip-MPLAB-Harmony/bootloader/releases/latest) [![Latest release date](https://img.shields.io/github/release-date/Microchip-MPLAB-Harmony/bootloader.svg)](https://github.com/Microchip-MPLAB-Harmony/bootloader/releases/latest) [![Commit activity](https://img.shields.io/github/commit-activity/y/Microchip-MPLAB-Harmony/bootloader.svg)](https://github.com/Microchip-MPLAB-Harmony/bootloader/graphs/commit-activity) [![Contributors](https://img.shields.io/github/contributors-anon/Microchip-MPLAB-Harmony/bootloader.svg)]() ____ [![Follow us on Youtube](https://img.shields.io/badge/Youtube-Follow%20us%20on%20Youtube-red.svg)](https://www.youtube.com/user/MicrochipTechnology) [![Follow us on LinkedIn](https://img.shields.io/badge/LinkedIn-Follow%20us%20on%20LinkedIn-blue.svg)](https://www.linkedin.com/company/microchip-technology) [![Follow us on Facebook](https://img.shields.io/badge/Facebook-Follow%20us%20on%20Facebook-blue.svg)](https://www.facebook.com/microchiptechnology/) [![Follow us on Twitter](https://img.shields.io/twitter/follow/MicrochipTech.svg?style=social)](https://twitter.com/MicrochipTech) [![](https://img.shields.io/github/stars/Microchip-MPLAB-Harmony/core.svg?style=social)]() [![](https://img.shields.io/github/watchers/Microchip-MPLAB-Harmony/core.svg?style=social)]() ",
    "url": "http://localhost:4000/bootloader/",
    "relUrl": "/"
  }
}
`;
var data_for_search

var repo_name = "bootloader";
var doc_folder_name = "docs";
var localhost_path = "http://localhost:4000/";
var home_index_string = "Bootloader Library Help";

(function (jtd, undefined) {

// Event handling

jtd.addEvent = function(el, type, handler) {
  if (el.attachEvent) el.attachEvent('on'+type, handler); else el.addEventListener(type, handler);
}
jtd.removeEvent = function(el, type, handler) {
  if (el.detachEvent) el.detachEvent('on'+type, handler); else el.removeEventListener(type, handler);
}
jtd.onReady = function(ready) {
  // in case the document is already rendered
  if (document.readyState!='loading') ready();
  // modern browsers
  else if (document.addEventListener) document.addEventListener('DOMContentLoaded', ready);
  // IE <= 8
  else document.attachEvent('onreadystatechange', function(){
      if (document.readyState=='complete') ready();
  });
}

// Show/hide mobile menu

function initNav() {
  jtd.addEvent(document, 'click', function(e){
    var target = e.target;
    while (target && !(target.classList && target.classList.contains('nav-list-expander'))) {
      target = target.parentNode;
    }
    if (target) {
      e.preventDefault();
      target.parentNode.classList.toggle('active');
    }
  });

  const siteNav = document.getElementById('site-nav');
  const mainHeader = document.getElementById('main-header');
  const menuButton = document.getElementById('menu-button');

  jtd.addEvent(menuButton, 'click', function(e){
    e.preventDefault();

    if (menuButton.classList.toggle('nav-open')) {
      siteNav.classList.add('nav-open');
      mainHeader.classList.add('nav-open');
    } else {
      siteNav.classList.remove('nav-open');
      mainHeader.classList.remove('nav-open');
    }
  });
}
// Site search

function initSearch() {

    data_for_search = JSON.parse(myVariable);
    lunr.tokenizer.separator = /[\s/]+/

    var index = lunr(function () {
        this.ref('id');
        this.field('title', { boost: 200 });
        this.field('content', { boost: 2 });
        this.field('url');
        this.metadataWhitelist = ['position']

        var location = document.location.pathname;
        var path = location.substring(0, location.lastIndexOf("/"));
        var directoryName = path.substring(path.lastIndexOf("/")+1);

        var cur_path_from_repo = path.substring(path.lastIndexOf(repo_name));

        // Decrement depth by 2 as HTML files are placed in repo_name/doc_folder_name
        var cur_depth_from_doc_folder = (cur_path_from_repo.split("/").length - 2);

        var rel_path_to_doc_folder = "";

        if (cur_depth_from_doc_folder == 0) {
            rel_path_to_doc_folder = "./"
        }
        else {
            for (var i = 0; i < cur_depth_from_doc_folder; i++)
            {
                rel_path_to_doc_folder = rel_path_to_doc_folder + "../"
            }
        }

        for (var i in data_for_search) {

            data_for_search[i].url = data_for_search[i].url.replace(localhost_path + repo_name, rel_path_to_doc_folder);

            if (data_for_search[i].title == home_index_string)
            {
                data_for_search[i].url = data_for_search[i].url + "index.html"
            }

            this.add({
                id: i,
                title: data_for_search[i].title,
                content: data_for_search[i].content,
                url: data_for_search[i].url
            });
        }
    });

    searchLoaded(index, data_for_search);
}function searchLoaded(index, docs) {
  var index = index;
  var docs = docs;
  var searchInput = document.getElementById('search-input');
  var searchResults = document.getElementById('search-results');
  var mainHeader = document.getElementById('main-header');
  var currentInput;
  var currentSearchIndex = 0;

  function showSearch() {
    document.documentElement.classList.add('search-active');
  }

  function hideSearch() {
    document.documentElement.classList.remove('search-active');
  }

  function update() {
    currentSearchIndex++;

    var input = searchInput.value;
    if (input === '') {
      hideSearch();
    } else {
      showSearch();
      // scroll search input into view, workaround for iOS Safari
      window.scroll(0, -1);
      setTimeout(function(){ window.scroll(0, 0); }, 0);
    }
    if (input === currentInput) {
      return;
    }
    currentInput = input;
    searchResults.innerHTML = '';
    if (input === '') {
      return;
    }

    var results = index.query(function (query) {
      var tokens = lunr.tokenizer(input)
      query.term(tokens, {
        boost: 10
      });
      query.term(tokens, {
        wildcard: lunr.Query.wildcard.TRAILING
      });
    });

    if ((results.length == 0) && (input.length > 2)) {
      var tokens = lunr.tokenizer(input).filter(function(token, i) {
        return token.str.length < 20;
      })
      if (tokens.length > 0) {
        results = index.query(function (query) {
          query.term(tokens, {
            editDistance: Math.round(Math.sqrt(input.length / 2 - 1))
          });
        });
      }
    }

    if (results.length == 0) {
      var noResultsDiv = document.createElement('div');
      noResultsDiv.classList.add('search-no-result');
      noResultsDiv.innerText = 'No results found';
      searchResults.appendChild(noResultsDiv);

    } else {
      var resultsList = document.createElement('ul');
      resultsList.classList.add('search-results-list');
      searchResults.appendChild(resultsList);

      addResults(resultsList, results, 0, 10, 100, currentSearchIndex);
    }

    function addResults(resultsList, results, start, batchSize, batchMillis, searchIndex) {
      if (searchIndex != currentSearchIndex) {
        return;
      }
      for (var i = start; i < (start + batchSize); i++) {
        if (i == results.length) {
          return;
        }
        addResult(resultsList, results[i]);
      }
      setTimeout(function() {
        addResults(resultsList, results, start + batchSize, batchSize, batchMillis, searchIndex);
      }, batchMillis);
    }

    function addResult(resultsList, result) {
      var doc = docs[result.ref];

      var resultsListItem = document.createElement('li');
      resultsListItem.classList.add('search-results-list-item');
      resultsList.appendChild(resultsListItem);

      var resultLink = document.createElement('a');
      resultLink.classList.add('search-result');
      resultLink.setAttribute('href', doc.url);
      resultsListItem.appendChild(resultLink);

      var resultTitle = document.createElement('div');
      resultTitle.classList.add('search-result-title');
      resultLink.appendChild(resultTitle);

      var resultDoc = document.createElement('div');
      resultDoc.classList.add('search-result-doc');
      resultDoc.innerHTML = '<svg viewBox="0 0 24 24" class="search-result-icon"><use xlink:href="#svg-doc"></use></svg>';
      resultTitle.appendChild(resultDoc);

      var resultDocTitle = document.createElement('div');
      resultDocTitle.classList.add('search-result-doc-title');
      resultDocTitle.innerHTML = doc.doc;
      resultDoc.appendChild(resultDocTitle);
      var resultDocOrSection = resultDocTitle;

      if (doc.doc != doc.title) {
        resultDoc.classList.add('search-result-doc-parent');
        var resultSection = document.createElement('div');
        resultSection.classList.add('search-result-section');
        resultSection.innerHTML = doc.title;
        resultTitle.appendChild(resultSection);
        resultDocOrSection = resultSection;
      }

      var metadata = result.matchData.metadata;
      var titlePositions = [];
      var contentPositions = [];
      for (var j in metadata) {
        var meta = metadata[j];
        if (meta.title) {
          var positions = meta.title.position;
          for (var k in positions) {
            titlePositions.push(positions[k]);
          }
        }
        if (meta.content) {
          var positions = meta.content.position;
          for (var k in positions) {
            var position = positions[k];
            var previewStart = position[0];
            var previewEnd = position[0] + position[1];
            var ellipsesBefore = true;
            var ellipsesAfter = true;
            for (var k = 0; k < 5; k++) {
              var nextSpace = doc.content.lastIndexOf(' ', previewStart - 2);
              var nextDot = doc.content.lastIndexOf('. ', previewStart - 2);
              if ((nextDot >= 0) && (nextDot > nextSpace)) {
                previewStart = nextDot + 1;
                ellipsesBefore = false;
                break;
              }
              if (nextSpace < 0) {
                previewStart = 0;
                ellipsesBefore = false;
                break;
              }
              previewStart = nextSpace + 1;
            }
            for (var k = 0; k < 10; k++) {
              var nextSpace = doc.content.indexOf(' ', previewEnd + 1);
              var nextDot = doc.content.indexOf('. ', previewEnd + 1);
              if ((nextDot >= 0) && (nextDot < nextSpace)) {
                previewEnd = nextDot;
                ellipsesAfter = false;
                break;
              }
              if (nextSpace < 0) {
                previewEnd = doc.content.length;
                ellipsesAfter = false;
                break;
              }
              previewEnd = nextSpace;
            }
            contentPositions.push({
              highlight: position,
              previewStart: previewStart, previewEnd: previewEnd,
              ellipsesBefore: ellipsesBefore, ellipsesAfter: ellipsesAfter
            });
          }
        }
      }

      if (titlePositions.length > 0) {
        titlePositions.sort(function(p1, p2){ return p1[0] - p2[0] });
        resultDocOrSection.innerHTML = '';
        addHighlightedText(resultDocOrSection, doc.title, 0, doc.title.length, titlePositions);
      }

      if (contentPositions.length > 0) {
        contentPositions.sort(function(p1, p2){ return p1.highlight[0] - p2.highlight[0] });
        var contentPosition = contentPositions[0];
        var previewPosition = {
          highlight: [contentPosition.highlight],
          previewStart: contentPosition.previewStart, previewEnd: contentPosition.previewEnd,
          ellipsesBefore: contentPosition.ellipsesBefore, ellipsesAfter: contentPosition.ellipsesAfter
        };
        var previewPositions = [previewPosition];
        for (var j = 1; j < contentPositions.length; j++) {
          contentPosition = contentPositions[j];
          if (previewPosition.previewEnd < contentPosition.previewStart) {
            previewPosition = {
              highlight: [contentPosition.highlight],
              previewStart: contentPosition.previewStart, previewEnd: contentPosition.previewEnd,
              ellipsesBefore: contentPosition.ellipsesBefore, ellipsesAfter: contentPosition.ellipsesAfter
            }
            previewPositions.push(previewPosition);
          } else {
            previewPosition.highlight.push(contentPosition.highlight);
            previewPosition.previewEnd = contentPosition.previewEnd;
            previewPosition.ellipsesAfter = contentPosition.ellipsesAfter;
          }
        }

        var resultPreviews = document.createElement('div');
        resultPreviews.classList.add('search-result-previews');
        resultLink.appendChild(resultPreviews);

        var content = doc.content;
        for (var j = 0; j < Math.min(previewPositions.length, 3); j++) {
          var position = previewPositions[j];

          var resultPreview = document.createElement('div');
          resultPreview.classList.add('search-result-preview');
          resultPreviews.appendChild(resultPreview);

          if (position.ellipsesBefore) {
            resultPreview.appendChild(document.createTextNode('... '));
          }
          addHighlightedText(resultPreview, content, position.previewStart, position.previewEnd, position.highlight);
          if (position.ellipsesAfter) {
            resultPreview.appendChild(document.createTextNode(' ...'));
          }
        }
      }
      var resultRelUrl = document.createElement('span');
      resultRelUrl.classList.add('search-result-rel-url');
      resultRelUrl.innerText = doc.relUrl;
      resultTitle.appendChild(resultRelUrl);
    }

    function addHighlightedText(parent, text, start, end, positions) {
      var index = start;
      for (var i in positions) {
        var position = positions[i];
        var span = document.createElement('span');
        span.innerHTML = text.substring(index, position[0]);
        parent.appendChild(span);
        index = position[0] + position[1];
        var highlight = document.createElement('span');
        highlight.classList.add('search-result-highlight');
        highlight.innerHTML = text.substring(position[0], index);
        parent.appendChild(highlight);
      }
      var span = document.createElement('span');
      span.innerHTML = text.substring(index, end);
      parent.appendChild(span);
    }
  }

  jtd.addEvent(searchInput, 'focus', function(){
    setTimeout(update, 0);
  });

  jtd.addEvent(searchInput, 'keyup', function(e){
    switch (e.keyCode) {
      case 27: // When esc key is pressed, hide the results and clear the field
        searchInput.value = '';
        break;
      case 38: // arrow up
      case 40: // arrow down
      case 13: // enter
        e.preventDefault();
        return;
    }
    update();
  });

  jtd.addEvent(searchInput, 'keydown', function(e){
    switch (e.keyCode) {
      case 38: // arrow up
        e.preventDefault();
        var active = document.querySelector('.search-result.active');
        if (active) {
          active.classList.remove('active');
          if (active.parentElement.previousSibling) {
            var previous = active.parentElement.previousSibling.querySelector('.search-result');
            previous.classList.add('active');
          }
        }
        return;
      case 40: // arrow down
        e.preventDefault();
        var active = document.querySelector('.search-result.active');
        if (active) {
          if (active.parentElement.nextSibling) {
            var next = active.parentElement.nextSibling.querySelector('.search-result');
            active.classList.remove('active');
            next.classList.add('active');
          }
        } else {
          var next = document.querySelector('.search-result');
          if (next) {
            next.classList.add('active');
          }
        }
        return;
      case 13: // enter
        e.preventDefault();
        var active = document.querySelector('.search-result.active');
        if (active) {
          active.click();
        } else {
          var first = document.querySelector('.search-result');
          if (first) {
            first.click();
          }
        }
        return;
    }
  });

  jtd.addEvent(document, 'click', function(e){
    if (e.target != searchInput) {
      hideSearch();
    }
  });
}

// Switch theme

jtd.getTheme = function() {
  var cssFileHref = document.querySelector('[rel="stylesheet"]').getAttribute('href');
  return cssFileHref.substring(cssFileHref.lastIndexOf('-') + 1, cssFileHref.length - 4);
}

jtd.setTheme = function(theme) {
  var cssFile = document.querySelector('[rel="stylesheet"]');
  cssFile.setAttribute('href', 'http://localhost:4000/bootloader/assets/css/just-the-docs-' + theme + '.css');
}

// Document ready

jtd.onReady(function(){
  initNav();
  initSearch();
});

})(window.jtd = window.jtd || {});


