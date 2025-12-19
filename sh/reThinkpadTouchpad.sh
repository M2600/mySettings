#!/bin/sh

sudo modprobe -r elan_i2c psmouse i2c_i801
sudo modprobe i2c_i801
sudo modprobe psmouse elan_i2c
