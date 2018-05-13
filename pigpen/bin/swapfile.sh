#!/bin/bash
###############################################################################
#
# swapfile.sh
#
# Create swap file and activate it
#
###############################################################################

DIRNAME=$(dirname $0)
MYNAME=$(basename $0)
LIBDIR="$DIRNAME/../lib"
source "$LIBDIR/functions.sh"
source "$LIBDIR/common.sh"

###############################################################################
DEBUG=""
###############################################################################


###############################################################################
TEMP=`getopt -o dl: --long d-long,l-long: \
     -n $MYNAME -- "$@"`

if [ $? != 0 ] ; then echo "$MYNAME: terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
    case "$1" in
        -d|--d-long) echo "Debug enabled" ; DEBUG="true"; shift ;;
        -l|--l-long)
            case "$2" in
                "") echo "Option l, no argument"; shift 2 ;;
                *) LOGFILE=$2 ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

# Startup
logmsg "$MYNAME: starting"
debug "Logfile: $LOGFILE"

# Dir and file names
SWAPDIR="/var/swap"
SWAPFILE="swapfile001"

# 1GB file
SIZE="1048576"

# Directory for the swap file
logmsg "Creating swapdir $SWAPDIR"
mkdir -p $SWAPDIR

# Create an empty file of the specified size
logmsg "Creating a $SIZE swapfile $SWAPFILE in $SWAPDIR"
dd if=/dev/zero of=$SWAPDIR/$SWAPFILE bs=1024 count=$SIZE

# Set perms
logmsg "Setting permissions on swapfile"
chown root:root $SWAPDIR/$SWAPFILE
chmod 0600 $SWAPDIR/$SWAPFILE

# Make the swafile
logmsg "Setting up swapfile"
mkswap $SWAPDIR/$SWAPFILE

# Enable it
logmsg "Enabling swapfile"
swapon $SWAPDIR/$SWAPFILE

# Add it to fstab
logmsg "Backing up current fstab to fstab.BAK"
cp /etc/fstab /etc/fstab.BAK

logmsg "Adding swapfile to /etc/fstab"
echo "$SWAPDIR/$SWAPFILE none swap sw 0 0" >> /etc/fstab

logmsg "Script: $MYNAME done"
