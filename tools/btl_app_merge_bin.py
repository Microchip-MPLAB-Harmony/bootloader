#!/usr/bin/env python

"""*****************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*****************************************************************************"""

import os
import sys
import optparse
import binascii

#------------------------------------------------------------------------------
ERASE_SIZE        = 0
BOOTLOADER_SIZE     = 0

destinationFile     = "btl_app_merged.bin"

# Supported Devices [ERASE_SIZE, BOOTLOADER_SIZE]
devices = {
            "SAME5X"    : [8192, 8192],
            "SAMD5X"    : [8192, 8192],
}

#------------------------------------------------------------------------------
def error(text):
    sys.stderr.write('Error: %s\n' % text)
    sys.exit(-1)

#------------------------------------------------------------------------------
def warning(text):
    sys.stderr.write('Warning: %s\n' % text)

#------------------------------------------------------------------------------
def verbose(verb, text):
    if verb:
        print ("\n" + text)

#------------------------------------------------------------------------------
def main():
    parser = optparse.OptionParser(usage = 'usage: %prog [options]')
    parser.add_option('-v', '--verbose', dest='verbose', help='enable verbose output', default=False, action='store_true')
    parser.add_option('-b', '--btl_file', dest='btl_file', help='bootloader binary file to program', metavar='BTL_FILE')
    parser.add_option('-a', '--app_file', dest='app_file', help='application binary file to program', metavar='APP_FILE')
    parser.add_option('-o', '--offset', dest='offset', help='application start offset (default 0x2000)', default='0x2000', metavar='OFFS')
    parser.add_option('-d', '--device', dest='device', help='target device (same5x/samd5x)', default="same5x", metavar='DEV')

    (options, args) = parser.parse_args()

    if options.btl_file is None:
        error('Bootloader file name is required')

    if options.app_file is None:
        error('Application file name is required')

    if options.device is None:
        error('target device is required')

    device = options.device.upper()

    if (device in devices):
        ERASE_SIZE        = devices[device][0]
        BOOTLOADER_SIZE     = devices[device][1]
    else:
        error('invalid device')

    try:
        offset = int(options.offset, 0)
    except ValueError as inst:
        error('invalid offset value: %s' % options.offset)

    if offset < BOOTLOADER_SIZE:
        error('offset is within the bootlaoder area')

    if (os.path.exists(destinationFile)):
        os.remove(destinationFile)

    btlFile         = open(options.btl_file, 'rb')
    appFile         = open(options.app_file, 'rb')
    btlMergedFile   = open(destinationFile, 'wb')

    cntr = 0

    # Write bootloader binary to destination file
    while True:
        byte = binascii.b2a_hex(btlFile.read(1))
        if byte:
            btlMergedFile.write(binascii.a2b_hex(byte))
            cntr = cntr + 1
        else:
            break

    # Append 'ff' from bootloader end to start of the application offset to destination file
    while cntr < offset:
        btlMergedFile.write(bytes((255,)))
        cntr = cntr + 1

    # Append application binary to destination file
    while True:
        byte = binascii.b2a_hex(appFile.read(1))
        if byte:
            btlMergedFile.write(binascii.a2b_hex(byte))
        else:
            break

    print("\r\n##### Merged Bootloader and Application binaries to ", destinationFile, "#####")

    btlMergedFile.close()

#------------------------------------------------------------------------------

main()
