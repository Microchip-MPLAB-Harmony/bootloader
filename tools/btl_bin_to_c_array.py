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

import binascii
import os
import sys
import optparse

# Supported Devices [ERASE_PAGE_SIZE, BOOTLOADER_SIZE]
devices = {
            "SAME7X"    : [8192, 8192],
            "SAMV7X"    : [8192, 8192],
            "SAME5X"    : [8192, 8192],
            "SAMD5X"    : [8192, 8192],
            "SAMC2X"    : [256, 2048],
            "SAMD1X"    : [256, 2048],
            "SAMD2X"    : [256, 2048],
            "SAMDA1"    : [256, 2048],
            "SAML1X"    : [256, 2048],
            "SAML2X"    : [256, 2048],
            "SAMHA1"    : [256, 2048],
            "PIC32CM"   : [256, 2048],
}

def bin_hex_convert(bin_file, dest_file, erase_page_size):

    if os.path.exists(bin_file):
        count = 16

        binfile = open(bin_file, "rb")

        if (os.path.exists(dest_file)):
            os.remove(dest_file)

        sys.stdout = hexfile = open(dest_file, 'w+')

        fstat = os.stat(bin_file)

        delta_size = erase_page_size - (fstat.st_size % erase_page_size)

        size = fstat.st_size + delta_size

        print ("#ifndef IMAGE_PATTERN_HEX_H_")
        print ("#define IMAGE_PATTERN_HEX_H_\n")
        print ("const uint8_t image_pattern[" + str(size) + "] = \n{")

        while True:
            byte = binfile.read(1)
            str1 = ""
            if byte:
                count = count - 1
                num = int.from_bytes(byte, byteorder='big')
                str1 = "0x{:02x}".format(num)
                print (str1 + ", ", end="")
                if (count == 0):
                    print ("")
                    count = 16
            else:
                break

        while delta_size > 0:
            count = count - 1
            print ("0xff, ",end="")
            if (count == 0):
                print ("")
                count = 16
            delta_size = delta_size - 1

        binfile.close()
        print("\n};\n")
        print ("#endif")
        hexfile.close()
    else:
        print ("\nUnable to locate " + bin_file)


def main():
    parser = optparse.OptionParser(usage = 'usage: %prog [options]')
    parser.add_option('-v', '--verbose', dest='verbose', help='enable verbose output', default=False, action='store_true')
    parser.add_option('-b', '--binfile', dest='binfile', help='binary file to convert', metavar='FILE')
    parser.add_option('-o', '--outputHexfile', dest='hexfile', help='output hex file', metavar='FILE')
    parser.add_option('-d', '--device', dest='device', help='target device (samc2x/samd1x/samd2x/samda1/samd5x/same5x/same7x/samha1/saml1x/saml2x/samv7x/pic32cm)', metavar='DEV')

    (options, args) = parser.parse_args()

    if options.binfile is None:
        error('binfile name is required (use -b option)')

    if options.hexfile is None:
        error('hexfile name is required (use -o option)')

    if options.device is None:
        error('target device is required (use -d option)')

    device = options.device.upper()

    if (device in devices):
        ERASE_PAGE_SIZE         = devices[device][0]
        bin_hex_convert(options.binfile, options.hexfile, ERASE_PAGE_SIZE)
    else:
        error('invalid device')


#------------------------------------------------------------------------------

main()