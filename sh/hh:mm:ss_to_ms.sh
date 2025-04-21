#!/bin/sh

# Convert mm:ss to milliseconds

hh=$(echo "$1" | cut -d ':' -f 1)
mm=$(echo "$1" | cut -d ':' -f 2)
ss=$(echo "$1" | cut -d ':' -f 3)

ms=$(($hh * 3600000 + $mm * 60000 + $ss * 1000))
echo $ms
