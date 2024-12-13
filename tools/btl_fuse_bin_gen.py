import optparse
import os
import sys
from intelhex import IntelHex

global output_bin_file
global output_hex_file

output_hex_file = "devcfg.hex"  # Intermediate Intel HEX file


# Define the device configuration address ranges as a list of tuples
devices_dict = {
    "PIC32CM_GC00_SG00": [(0xA000000, 0xA001000), (0xA002000, 0xA003000)]
}

def error(text):
    sys.stderr.write('\nError: %s\n' % text)
    sys.exit(-1)


def warning(text):
    sys.stderr.write('\nWarning: %s\n' % text)


def verbose(verb, text):
    if verb:
        print("\n" + text)

def extract_ranges(input_hex, output_hex, output_bin, address_ranges):
    """
    Extract specified address ranges from an Intel HEX file and save to a new file.

    :param input_hex: Path to the input HEX file.
    :param output_hex: Path to the output HEX file.
    :param address_ranges: List of tuples specifying address ranges (low, high).
    """
    # Load the input HEX file
    ih = IntelHex(input_hex)

    # Create a new IntelHex object for the output
    output_ih = IntelHex()

    # Iterate over the provided ranges
    for low, high in address_ranges:
        # Copy data from the specified range
        for addr in range(low, high):  # +1 to include the high address
            try:
                output_ih[addr] = ih[addr]
            except KeyError:
                # Address not present in the input HEX file, skip it
                continue

    # Write the output HEX file without additional records
    output_ih.write_hex_file(output_hex)

    # Write the output binary file
    output_ih.tofile(output_bin, format='bin')



def main():
    parser = optparse.OptionParser(usage = 'usage: %prog [options]')

    parser.add_option('-d', '--device', dest='device', help='target device (PIC32CM_GC00_SG00)', metavar='DEV')
    parser.add_option('-f', '--inhexfile', dest='inhexfile', help='Input Hex file with fuse information', metavar='INHEXFILE')
    parser.add_option('-o', '--outbinfile', dest='outbinfile', help='Output binary file containing only fuse information (optional, default devcfg.bin)', metavar='OUTBINFILE')

    (options, args) = parser.parse_args()

    if options.device is None:
        error('target device is required (use -d option)')
    if options.inhexfile is None:
        error('Input hex file is required (use -f option)')
    if options.outbinfile is not None:
        output_bin_file = options.outbinfile
    else:
        output_bin_file = "devcfg.bin"  # Default output binary file

    device = options.device

    if device in devices_dict:
        # Extract the ranges and generate the output HEX file
        extract_ranges(options.inhexfile, output_hex_file, output_bin_file, devices_dict[device])


#------------------------------------------------------------------------------

main()