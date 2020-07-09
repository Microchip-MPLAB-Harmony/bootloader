# README	General information
* Unified Bootloader Host Application 
- Used with the MCC Bootloader Generated Software Library for 8-bit or 16-bit MCU devices, or the 32-bit AN1388 bootloader.
- The graphical front-end of the 8-bit, 16-bit and 32-bit Bootloader project.

# Support
Email: MCC_Support@microchip.com
This application requires the Java 1.8 runtime.
Users of Microchip products can receive assistance through several channels:

 - Distributor or Representative
 - Local Sales Office
 - Field Application Engineer (FAE)
 - Technical Support

Customers should contact their distributor, representative or Field Application Engineer (FAE) for support.
Local sales offices are also available to help customers.
A listing of sales offices and locations may be found on the [Microchip web site][3].

Technical support is available through the [Microchip web site][4].

# CHANGELOG	A detailed changelog, intended for programmers
v 0.1.9:	Added readme, added logger, added checksum support to PIC32; added handling for record type 0x05 (currently ignored)
v 0.1.10:	Internal release
v 0.1.11:	Internal release
v 0.1.14:	Added PIC32 CRC bytes used at end of packets. Added Erase feature to USB PIC32 command chain. Extended Timeouts added support for 24-bit packet length.
v 0.1.15:	Fixed bug in PIC16 erase being half expected length during command chain. Added support for larger PIC18 device checksum commands, appending over previous Access Key bytes.
v 1.0.0:	Release version to support PIC24 family of devices. Added beta support for AVR devices.
v 1.15.0:   Release version to support dsPIC33 family of devices. Release support for AVR devices.
v 1.15.1:   Fixed bugs to support PIC-IOT WG Development Board, phantom byte for degenerate blocks and restrict data packet size to MAX_PACKET_SIZE - HEADER_SIZE.
v 1.16.1:   Updated HID4JAVA library used for USB communication. Updates to AVR support to support MCC generated code. Extended PIC32 timeout(s) to 20s (from 8) UDP, USB
v 1.16.2:   32-bit devices no longer wait for responds from Reset Command. Bugfixes for 16-bit support: 1) Self Verify issue with larger parts with 2) no report, 3) End Address corruption on read properties, 4) Exception thrown on UART disconnect.

# NEWS	A basic changelog, intended for users
-Incremented version information; see Changelog
-Added readme file on release of version: 0.1.14
-Added Checksum support for PIC32
-Bug fixes, Added Release Notes v 0.1.15 along with readme file. Added support for up to 32-bit checksum value calculation.
-Added Synch Byte expectation to AVR packet support.
-Fixed Typo in Help-->About text which indicated incorrect Utility version
-Added logger support requires launching from command prompt with below text:
* -Djava.util.logging.config.file="C:\<DirectoryLocation>"

i.e.: To Launch from Command Prompt
>java -Djava.util.logging.config.file="<Drive: e.g. C>:\<MyDirectory>\<UnifiedHost-version>\logging.properties" -jar UnifiedHost-<version>.jar

# INSTALL	Installation instructions
Installation of Java JRE

# COPYING / LICENSE	Copyright and licensing information
See LICENSE.txt for licensing information.