#!/usr/bin/env python
################################################################################
#
# pigpen.py
#
# The main pigpen library
#
################################################################################
#
# NOTES:
#
################################################################################

import netifaces as nif
import logging
import sys
import redis
import os


#9yy###############################################################################
#        NAME : template
# DESCRIPTION :
#      PARAMS :
#     RETURNS :
################################################################################
def template(argument):
    name = sys._getframe().f_code.co_name
    logging.debug(name + "(): Entering")


################################################################################
#        NAME : calcHostname
# DESCRIPTION : Calculate the hostname based on the interface MAC
#      PARAMS : string(interface)
#     RETURNS : string(hostname)
################################################################################
def hostnameByInterface(interface):
    name = sys._getframe().f_code.co_name
    logging.debug(name + "(): Entering")

    try:
        mac = getMACForInterface(interface)
        lastTwo = getMACLastTwo(mac)
        calcName = "pi-" + lastTwo
        return calcName
    except ValueError as e:
        logging.debug(name + "(): requested interface %s does not exist", interface)
        raise


################################################################################
#        NAME : getMACLastTwo
# DESCRIPTION : Get the last 2 octets of the mac, concat them and return it
#      PARAMS : string(mac)
#     RETURNS : string(lastTwo)
################################################################################
def getMACLastTwo(mac):
    name = sys._getframe().f_code.co_name
    logging.debug(name + "(): Entering")
    logging.debug(name + "(): MAC => " + mac)

    oct1,oct2,oct3,oct4,oct5,oct6 = mac.split(":")

    lastTwo = oct5 + oct6

    logging.debug(name + "(): returning lastTwo => " + lastTwo)
    return(lastTwo)


################################################################################
#        NAME : convertMACToPort
# DESCRIPTION : Take the last 2 octets of the mac address and convert it to a
#             : port number. This is unique "enough" for our needs
#      PARAMS : string(mac)
#     RETURNS : int(port)
################################################################################
def convertMACToPort(mac):
    name = sys._getframe().f_code.co_name
    logging.debug(name + "(): Entering")
    logging.debug(name + "(): MAC => " + mac)

    oct1,oct2,oct3,oct4,oct5,oct6 = mac.split(":")

    # take the last 2 octets, convert them from hex to decimal
    # convert those to strings and concat their values
    strPort = str(int(oct5,16)) + str(int(oct6,16))

    # Convert to an int so we can do math
    # I wish this was Perl, IJW(*)
    port = int(strPort)

    # If the port is too high, divide by 2 to get the final value
    if port >= 65535:
        port = port / 2

    #logging.debug(name + "(): returning port => " + port)
    return port


################################################################################
#        NAME : getMACForInterface
# DESCRIPTION : Get the AF_LINK (mac) address for a given interface
#      PARAMS : string(interface)
#     RETURNS : string(mac)
################################################################################
def getMACForInterface(interface):
    name = sys._getframe().f_code.co_name
    logging.debug(name + "(): Entering")

    ###
    # Get a list of the addresses associated with the interface
    # If the interface doesn't exist a ValueError exception will be raised
    # and passed straight back to the caller
    # If it does exist we will find the MAC address and return it as a string
    ###
    try:
        addrs = nif.ifaddresses(interface)

        # spin through the address types and get the MAC address
        for addrtype in addrs:

            # TODO: check if the requested interface has an address of type AF_LINK
            # if it does, get the value and return it
            # otherwise except or set mac to None and return that
            if addrtype == nif.AF_LINK:
                mac = nif.ifaddresses(interface)[nif.AF_LINK][0]['addr']
                logging.debug(name + "(): returning MAC => " + mac)
                return mac
    except ValueError as e:
        logging.debug(name + "(): %s", e)
        raise


################################################################################
#        NAME : getCurrentHostname
# DESCRIPTION : Return the value from a file that contains the hostname
#             : on Debian/Kali this is /etc/hostname, can change for others
#      PARAMS : string(file)
#     RETURNS : string(hostname)
################################################################################
def getCurrentHostname(hostnameFile):
    name = sys._getframe().f_code.co_name
    logging.debug(name + "(): Entering")
    logging.debug(name + "(): hostnameFile => " + hostnameFile)

    try:
        with open(hostnameFile, 'r') as f:
            currentHostname = f.read()
            currentHostname = currentHostname.rstrip()
            logging.debug(name + "(): read file " + hostnameFile)
            logging.debug(name + "(): returning hostname => " + currentHostname)
            return currentHostname
        if not currentHostname:
            logging.debug(name + "(): no data in file " + hostnameFile)
            return
    except IOError as e:
        logging.debug(name + "(): I/O error({0}): {1}".format(e.errno, e.strerror))
    except: # handle other exceptions such as attribute errors
        logging.debug(name + "(): Unexpected error:", sys.exc_info()[0])


################################################################################
#        NAME : setHostname
# DESCRIPTION : Set the dynamic hostname in the hostname file
#      PARAMS : string(file, name)
#     RETURNS :
################################################################################
def setHostname(hostnameFile, hostname):
    name = sys._getframe().f_code.co_name
    logging.debug(name + "(): Entering")
    logging.debug(name + "(): hostnameFile => " + hostnameFile)
    logging.debug(name + "(): hostname => " + hostname)


################################################################################
#        NAME : redisConnect
# DESCRIPTION :
#      PARAMS :
#     RETURNS :
################################################################################
def redisConnect(server, port, db):
    name = sys._getframe().f_code.co_name
    logging.debug(name + "(): Entering")
    logging.debug(name + "(): server => " + server)
    logging.debug(name + "(): port => {}".format(port))
    logging.debug(name + "(): db => {}".format(db))

    try:
        logging.debug(name + "(): Connecting to Redis")
        r = redis.StrictRedis(host=server, port=port, db=db)
        logging.debug(name + "(): Connected to Redis")
        return r
    except:
        logging.debug(name + "(): Exception")
        raise



################################################################################
#        NAME : getLoadAverage
# DESCRIPTION : get the load average for the host, 1, 5 and 15 min
#      PARAMS : None
#     RETURNS : Dict(loadAverage)
################################################################################
def getLoadAverage():
    name = sys._getframe().f_code.co_name
    logging.debug(name + "(): Entering")

    ### Get the load average and shove it into a dic
    loadAverage = {
            "1min"  : os.getloadavg()[0],
            "5min"  : os.getloadavg()[1],
            "15min" : os.getloadavg()[2]
        }

    return loadAverage

