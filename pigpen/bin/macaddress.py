#!/usr/bin/env python
################################################################################
#
# macaddress.py
#
# print the mac (LINK) address for a given interface
#
################################################################################

# Internal and installed modules we use
import logging
import os
import sys
import argparse
import ConfigParser

# Set up various paths we need
dir_path = os.path.dirname(os.path.realpath(__file__))
lib_path = dir_path + "/../lib"
etc_path = dir_path + "/../etc"

# Add the library path so we can find our modules
sys.path.append(lib_path)

# Load in our modules
from pigpen import *

# More global variables
cfgfile = etc_path + "/pigpen.cfg"


###
# m a M A I N i n
###
if __name__ == "__main__":

    interface = ""  # interface to act on
    mac       = ""  # mac for the named interface
    hostname  = ""  # the calculated hostname
    debug     = ""  # debug yay or nay

    logformat = "%(asctime)-15s %(clientip)s %(user)-8s %(message)s"

    # parse the config file if it's there
    # TODO: add the check for if it exists
    Config = ConfigParser.ConfigParser()
    files_read = Config.read(cfgfile)

    # parse the command line args
    ap = argparse.ArgumentParser(description="Print the hostname calculated for this device")
    ap.add_argument('interface', nargs='?', help="the interface to act on")
    ap.add_argument("-d", "--debug", action='store_true', help="Debug output")
    args = ap.parse_args()

    # set the debug on logging if needed
    if args.debug:
        logging.basicConfig(level=logging.DEBUG)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        logging.basicConfig(format=logformat)

    # if the arg passed an interface, use that, otherwise use the config file one
    if args.interface:
        interface = args.interface
    else:
        interface = Config.get('main', 'interface')

    # attempt to get the MAC address for the given interface
    # if it's there, print it otherwise grab the exception, print and exit
    try:
        mac = getMACForInterface(interface)
        print mac
        sys.exit(0)
    except ValueError as e:
        print e
        sys.exit(1)

