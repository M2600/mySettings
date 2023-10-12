#!/usr/bin/sh

if [[ -n $(ip link show up dev wlan0) ]]; then
    network=$(iwctl station wlan0 show | grep 'Connected network')
    level=$(iwctl station wlan0 show | grep 'RSSI')
    network_arry=(${network//,/})
    level_arry=(${level//,/})
    
    echo ${network_arry[2]}: ${level_arry[1]}dB
fi
