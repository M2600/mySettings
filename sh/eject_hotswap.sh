#!/usr/bin/bash

# shutdown SATA device.

function echo_usage () {
	echo "Usage:"
	echo "$0 [OPTIONS] device_name"
	echo "Options:"
	echo ""
}


# [ -n "" ] -n option: Return true if string is not empty.
if [ -n "$1" ]; then
	DEVICE=$1
else
	echo "Select device name"
	echo_usage
	exit 1
fi

# -z option: Return true if string is empty.
if [ -z $DEVICE ]; then
	echo "Select device name"
	echo_usage
	exit 1
fi

DEVICE_PATH="/sys/block/$DEVICE/device/delete"

# -e option: Return true if file path exist.
if [ ! -e $DEVICE_PATH ]; then
	echo "Invalid device"
	exit 1
fi

if [ $(mount | grep $DEVICE | wc -l) -gt 0 ]; then
	echo "Device still mounted"
	exit 1
fi

echo "Shutting down $DEVICE..."
echo 1 > $DEVICE_PATH \
&& echo "Done. Now you can eject device safely."

