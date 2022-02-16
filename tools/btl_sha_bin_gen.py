#!/usr/bin/env python

"""*****************************************************************************
* Copyright (C) 2022 Microchip Technology Inc. and its subsidiaries.
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
import time
import serial
import optparse
import hashlib

# Should be equal to Device Erase size
ERASE_SIZE        = 256

# Supported Devices [ERASE_SIZE]
devices = {
            "PIC32CM"   : [256],
}

#------------------------------------------------------------------------------
def error(text):
    sys.stderr.write('\nError: %s\n' % text)
    sys.exit(-1)

#------------------------------------------------------------------------------
def warning(text):
    sys.stderr.write('\nWarning: %s\n' % text)

#------------------------------------------------------------------------------
def verbose(verb, text):
    if verb:
        print("\n" + text)

#------------------------------------------------------------------------------
def generate_sha256(data):

    sha256Obj = hashlib.sha256()

    for d in data:
        sha256Obj.update(bytes((d,)))

    sha256HexDigest = sha256Obj.hexdigest()

    print(sha256HexDigest)

    sha256Digest = sha256Obj.digest()

    sha256 = [(v) for v in sha256Digest]

    return sha256

#------------------------------------------------------------------------------
def generate_binary_with_sha256(data, bootProtSize, bootNSCSize, outBinaryFile):
    sha256Data = []

    bootNSCStart = 0

    if (bootNSCSize > 0):
        bootNSCStart = (bootProtSize - bootNSCSize)

    sha256Start = (bootProtSize - bootNSCSize - 32)

    sha256Data = data[0:sha256Start]

    if (bootNSCStart):
        sha256Data += data[bootNSCStart:]

    sha256 = generate_sha256(sha256Data)

    # Add the generated SHA256 at SHA location
    for i in range(0, len(sha256)):
        data[sha256Start + i] = sha256[i]

    if (os.path.exists(outBinaryFile)):
        os.remove(outBinaryFile)

    output_file = open(outBinaryFile, 'wb')

    for d in data:
        output_file.write(bytes((d,)))

    output_file.close()

#------------------------------------------------------------------------------
def main():
    parser = optparse.OptionParser(usage = 'usage: %prog [options]')
    parser.add_option('-v', '--verbose', dest='verbose', help='enable verbose output', default=False, action='store_true')
    parser.add_option('-f', '--inbinaryfile', dest='inbinaryfile', help='Input bootloader binary file', metavar='INBINARYFILE')
    parser.add_option('-o', '--outbinaryfile', dest='outbinaryfile', help='Output bootloader binary file', metavar='OUTBINARYFILE')
    parser.add_option('-b', '--bootprotsize', dest='bootprotsize', help='Size of bootloader region (BOOTPROT)', metavar='BOOTPROTSIZE')
    parser.add_option('-n', '--bootnscsize', dest='bootnscsize', help='Size of bootloader non-secure callable region (BNSC)', metavar='BOOTNSCSIZE')
    parser.add_option('-d', '--device', dest='device', help='target device (pic32cm)', metavar='DEV')

    (options, args) = parser.parse_args()

    if options.device is None:
        error('target device is required (use -d option)')

    if options.inbinaryfile is None:
        error('Input device configuration file is required (use -f option)')

    if options.outbinaryfile is None:
        error('Output device configuration file name is required (use -o option)')

    if options.bootprotsize is None:
        error('Bootloader size is required (use -s option)')

    device = options.device.upper()

    if (device in devices):
        ERASE_SIZE      = devices[device][0]
    else:
        error('invalid device')

    bootprotsize = 0
    bootnscsize  = 0

    try:
        bootprotsize = int(options.bootprotsize, 0)
    except ValueError as inst:
        error('invalid bootprotsize value: %s' % options.bootprotsize)

    if options.bootnscsize:
        try:
            bootnscsize = int(options.bootnscsize, 0)
        except ValueError as inst:
            error('invalid bootnscsize value: %s' % options.bootnscsize)

    if not os.path.exists(options.inbinaryfile):
        error('Unable to locate file %s' % options.inbinaryfile)

    try:
        data = data = [(x) for x in open(options.inbinaryfile, 'rb').read()]
    except Exception as inst:
        error(inst)

    dataSize = len(data)

    # Add 0xFF if the size of binary is not equal to bootprotsize
    for i in range(dataSize, bootprotsize):
        data += [0xff]

    # Add 0xFF if size of binary is not aligned to device erase size
    while len(data) % ERASE_SIZE > 0:
        data += [0xff]

    generate_binary_with_sha256(data, bootprotsize, bootnscsize, options.outbinaryfile)

    verbose(options.verbose, 'Creation of binary file with embedded SHA256 value completed')

#------------------------------------------------------------------------------

main()
