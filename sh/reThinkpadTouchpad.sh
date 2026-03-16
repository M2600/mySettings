#!/bin/sh

sudo modprobe -r elan_i2c psmouse i2c_i801
sudo modprobe i2c_i801
sudo modprobe psmouse elan_i2c

sudo -u m260 libinput-gestures-setup restart >> /home/m260/tmp/log/libinput-gestures-setup.log 2>&1
