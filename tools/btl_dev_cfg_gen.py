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
def crc32_tab_gen():
    res = []

    for i in range(256):
        value = i

        for j in range(8):
            if value & 1:
                value = (value >> 1) ^ 0xedb88320
            else:
                value = value >> 1

        res += [value]

    return res

#------------------------------------------------------------------------------
def crc32(tab, data):
    crc = 0xffffffff

    for d in data:
        crc = tab[(crc ^ d) & 0xff] ^ (crc >> 8)

    return crc

#------------------------------------------------------------------------------
def generate_sha256(data):

    sha256Obj = hashlib.sha256()

    for d in data:
        sha256Obj.update(bytes((d,)))

    sha256HexDigest = sha256Obj.hexdigest()

    sha256Digest = sha256Obj.digest()

    sha256 = [(v) for v in sha256Digest]

    return sha256

#------------------------------------------------------------------------------
def generate_device_configurations(inDevCfgFile, outDevCfgFile):
    crc32Data = []
    sha256Data = []
    crc32_start = False
    sha256_start = False
    addCRC32ToSha = False
    crc32_value = 0
    value = 0

    if not os.path.exists(inDevCfgFile):
        error('Unable to locate file %s' % inDevCfgFile)

    if (os.path.exists(outDevCfgFile)):
        os.remove(outDevCfgFile)

    # Expected Format for Device Configurations in text file.
    # Device Configurations for each row has to start with ROW_START followed by address
    # Device configurations should end with ROW_END
    # Each 32-Bit Fuse bit value has to be newline separated

    # ROW_START 0x00804000
    # 0x78563412
    # 0x00EFCDAB
    # ROW_END

    # If CRC32 or SHA256 has to be generated for device configuration records below format
    # has to be followed.

    # ROW_START 0x0080C000
    # SHA256_START
    # CRC32_START
    # 0xF00FFFFF
    # 0xFFE81001
    # CRC32_END  // Calculated CRC32 value will be placed here in the output configuration file
    # 0xFFFFFFFF
    # 0xFFFFFFFF
    # 0xFFFFFFFF
    # ...
    # SHA256_END // Calculated SHA256 value 32 Bytes (8 Words) will be placed starting from here
    # ROW_END


    input_file = open(inDevCfgFile, 'r')
    output_file = open(outDevCfgFile, 'w')

    for line in input_file:
        if ("ROW_START" in line):
            # Start of new device configuration row
            try:
                address = int(line.split(' ')[1], 0)
            except:
                error('Provide valid address for the Row in the device configuration file (Example: ROW_START 0x12345678')

            output_file.write(line)

        elif ("CRC32_START" in line):
            crc32_start = True

        elif ("SHA256_START" in line):
            sha256_start = True

        else:
            if ("CRC32_END" in line):
                # Generate the CRC32 on received Device configurations and write to file
                crc32_tab = crc32_tab_gen()

                crc32_value = crc32(crc32_tab, crc32Data)

                crc32_start = False
                crc32Data = []

                if (sha256_start == True):
                    addCRC32ToSha = True

                output_file.write("0x%08x" % crc32_value + "\n")

            elif ("SHA256_END" in line):
                # Generate the SHA256 on received Device configurations and write to file
                sha256 = generate_sha256(sha256Data)

                for i in range(0, 32, 4):
                    sha256Word = sha256[i] & 0xFF
                    sha256Word |= (sha256[i+1] << 8) & 0xFF00
                    sha256Word |= (sha256[i+2] << 16) & 0xFF0000
                    sha256Word |= (sha256[i+3] << 24) & 0xFF000000

                    output_file.write("0x%08x" % sha256Word + "\n")

                sha256_start = False
                sha256Data = []

            else:
                # Write the Configuration record to output file
                output_file.write(line)

            # Start storing the configuration record for CRC32 calculation
            if ((crc32_start == True) and (line.startswith("0x"))):
                value = int(line.strip(), 0)

                # Store device configuration record LSB first
                crc32Data += [value & 0xFF]
                crc32Data += [(value >> 8) & 0xFF]
                crc32Data += [(value >> 16 )& 0xFF]
                crc32Data += [(value >> 24) & 0xFF]

            # Start storing the configuration record for SHA256 calculation
            if (((sha256_start == True) and (line.startswith("0x"))) or ((sha256_start == True) and (addCRC32ToSha == True))):
                if (addCRC32ToSha == True):
                    value = crc32_value
                    addCRC32ToSha = False
                else:
                    value = int(line.strip(), 0)

                # Store device configuration record LSB first
                sha256Data += [value & 0xFF]
                sha256Data += [(value >> 8) & 0xFF]
                sha256Data += [(value >> 16 )& 0xFF]
                sha256Data += [(value >> 24) & 0xFF]

    input_file.close()
    output_file.close()

#------------------------------------------------------------------------------
def main():
    parser = optparse.OptionParser(usage = 'usage: %prog [options]')
    parser.add_option('-v', '--verbose', dest='verbose', help='enable verbose output', default=False, action='store_true')
    parser.add_option('-f', '--indevcfgfile', dest='indevcfgfile', help='Input device configuration text file', metavar='INDEVCFGFILE')
    parser.add_option('-o', '--outdevcfgfile', dest='outdevcfgfile', help='Output device configuration text file', metavar='OUTDEVCFGFILE')

    (options, args) = parser.parse_args()

    if options.indevcfgfile is None:
        error('Input device configuration file is required (use -f option)')

    if options.outdevcfgfile is None:
        error('Output device configuration file name is required (use -o option)')

    generate_device_configurations(options.indevcfgfile, options.outdevcfgfile)

    verbose(options.verbose, 'Device Configuration file creation complete')

#------------------------------------------------------------------------------

main()
