#!/bin/bash
################################################################################
#
# mount_image.sh
#
# Script to mount a Kali arm image locally
#
################################################################################

# vars
MYNAME=$(basename $0)
MNT="/t"

# For whatever reason I still can't remember shell t|f even after 25 years
FALSE=$(/bin/false)
TRUE=$(/bin/true)

# Make sure we have an image to use
if [[ -z "$1" ]]; then
	echo "Usage: $MYNAME <image>"
	exit $FALSE
else
	IMAGE="$1"
fi

# Create the top level mount directory
if [[ ! -d $MNT ]]; then
	echo "Creating mount dir: $MNT"
	mkdir $MNT
else
	echo "Mount dir: $MNT already exists"
fi

# make sure /t/boot exists, if not create it
if [[ ! -d "$MNT/boot" ]]; then
	echo "Creating boot dir: $MNT/boot"
	mkdir "$MNT/boot"
else
	echo "$MNT/boot already exists"
fi

# make sure /t/root exists, if not create it
if [[ ! -d "$MNT/root" ]]; then
	echo "Creating root dir: $MNT/root"
	mkdir "$MNT/root"
else
	echo "$MNT/root already exists"
fi


### Use losetup to get a loop device for the file
echo "Getting loop device"
loopdevice=`losetup -f --show $IMAGE`
echo "LOOPDEVICE: $loopdevice"

### get the assigned device partitions
device=`kpartx -va $loopdevice| sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
echo "DEVICE: $device"
sleep 5

### devs for the partitions
device="/dev/mapper/${device}"
echo "DEVICE: $device"

### partitions, p1 is boot, p2 is root from the base image
bootp=${device}p1
rootp=${device}p2

### print stuffs
echo "BOOTP: $bootp"
echo "ROOTP: $rootp"

### mount up
echo "Mounting"
mount $bootp $MNT/boot
mount $rootp $MNT/root

# exit true
exit $TRUE
