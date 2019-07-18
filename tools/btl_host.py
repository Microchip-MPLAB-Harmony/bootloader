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
import time
import serial
import optparse

#------------------------------------------------------------------------------
BL_CMD_UNLOCK       = 0xa0
BL_CMD_DATA         = 0xa1
BL_CMD_VERIFY       = 0xa2
BL_CMD_RESET        = 0xa3
BL_CMD_BKSWAP_RESET = 0xa4

BL_RESP_OK          = 0x50
BL_RESP_ERROR       = 0x51
BL_RESP_INVALID     = 0x52
BL_RESP_CRC_OK      = 0x53
BL_RESP_CRC_FAIL    = 0x54

BL_GUARD            = 0x5048434D

PROGRAM_SIZE        = 256
BOOTLOADER_SIZE     = 2048

# Supported Devices [PROGRAM_SIZE, BOOTLOADER_SIZE]
devices = {
            "SAME7X"    : [8192, 8192],
            "SAME5X"    : [8192, 8192],
            "SAMD5X"    : [8192, 8192],
            "SAMC2X"    : [256, 2048],
            "SAMD2X"    : [256, 2048],
            "SAML2X"    : [256, 2048],
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
        print text

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
def uint32(v):
    return [(v >> 0) & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff]

#------------------------------------------------------------------------------
def get_response(port):
    v = port.read()

    if len(v) == 0:
        return None
    elif len(v) > 1:
        error('invalid response received (size > 1)')

    return ord(v[0])

#------------------------------------------------------------------------------
def send_request(port, cmd, size, data):
    req = uint32(BL_GUARD) + size + [cmd] + data

    port.write(''.join(map(chr, req)))

    for i in range(3):
        resp = get_response(port)

        if (resp is None):
            warning('no response received, retrying %d' % (i+1))
            time.sleep(0.2)
        else:
            return resp

    error('no response received, giving up')

#------------------------------------------------------------------------------
def main():
    parser = optparse.OptionParser(usage = 'usage: %prog [options]')
    parser.add_option('-v', '--verbose', dest='verbose', help='enable verbose output', default=False, action='store_true')
    parser.add_option('-t', '--tune', dest='tune', help='auto-tune UART baudrate', default=False, action='store_true')
    parser.add_option('-i', '--interface', dest='port', help='communication interface', metavar='PATH')
    parser.add_option('-f', '--file', dest='file', help='binary file to program', metavar='FILE')
    parser.add_option('-o', '--offset', dest='offset', help='destination offset (default 0x600)', default='0x600', metavar='OFFS')
    parser.add_option('-b', '--boot', dest='boot', help='enable write to the bootloader area', default=False, action='store_true')
    parser.add_option('-s', '--swap', dest='swap', help='swap banks after programming', default=False, action='store_true')
    parser.add_option('-d', '--device', dest='device', help='target device (same7x/same5x/samd5x/samc2x/samd2x/saml2x)', default="samc2x", metavar='DEV')

    (options, args) = parser.parse_args()

    if options.port is None:
        error('communication port is required (try -h option)')

    if options.file is None:
        error('file name is required')

    if options.device is None:
        error('target device is required')

    device = options.device.upper()

    if (device in devices):
        PROGRAM_SIZE        = devices[device][0]
        BOOTLOADER_SIZE     = devices[device][1]
    else:
        error('invalid device')

    if (options.swap == True):
        if ((device != "SAME5X") and (device != "SAMD5X")):
            error('Bank Swapping not supported on this device')

    try:
        offset = int(options.offset, 0)
    except ValueError, inst:
        error('invalid offset value: %s' % options.offset)

    if offset < BOOTLOADER_SIZE and options.boot == False:
        error('offset is within the bootlaoder area, use --boot options to unlock writes')

    try:
        port = serial.Serial(options.port, 115200, timeout=1)
    except serial.serialutil.SerialException, inst:
        error(inst)

    if options.tune:
        verbose(options.verbose, 'Auto-tuning UART baudrate')
        port.send_break(duration=0.01)
        port.write(chr(0x55))

    try:
        data = data = [ord(x) for x in open(options.file, 'rb').read()]
    except Exception, inst:
        error(inst)

    while len(data) % PROGRAM_SIZE > 0:
        data += [0xff]

    crc32_tab = crc32_tab_gen()
    crc = crc32(crc32_tab, data)

    size = len(data)

    verbose(options.verbose, 'Unlocking')
    resp = send_request(port, BL_CMD_UNLOCK, uint32(8), uint32(offset) + uint32(size))

    if resp != BL_RESP_OK:
        error('invalid response code (0x%02x). Check that your file size and offset are correct.' % resp)

    # Create data blocks of PROGRAM_SIZE each
    blocks = [data[i:i + PROGRAM_SIZE] for i in xrange(0, len(data), PROGRAM_SIZE)]

    verbose(options.verbose, 'Uploading %d blocks at offset %d (0x%x)' % (len(blocks), offset, offset))

    addr = offset

    for idx, blk in enumerate(blocks):
        verbose(options.verbose, '... block %d of %d' % (idx+1, len(blocks)))

        resp = send_request(port, BL_CMD_DATA, uint32(PROGRAM_SIZE + 4), uint32(addr) + blk)
        addr += PROGRAM_SIZE

        if resp != BL_RESP_OK:
            error('invalid response code (0x%02x)' % resp)

    # Send Verification command
    verbose(options.verbose, 'Verification')
    resp = send_request(port, BL_CMD_VERIFY, uint32(4), uint32(crc))

    if resp == BL_RESP_CRC_OK:
        verbose(options.verbose, '... success')
    else:
        error('... fail (status = 0x%02x)' % resp)

    # Send Reboot Command
    if (options.swap == True):
        verbose(options.verbose, 'Swapping Bank And Rebooting')
        resp = send_request(port, BL_CMD_BKSWAP_RESET, uint32(16), uint32(0) * 4)
    else:
        verbose(options.verbose, 'Rebooting')
        resp = send_request(port, BL_CMD_RESET, uint32(16), uint32(0) * 4)

    if resp == BL_RESP_OK:
        verbose(options.verbose, 'Reboot Done|')
    else:
        error('... Reset fail (status = 0x%02x)' % resp)

    port.close()

#------------------------------------------------------------------------------

main()
