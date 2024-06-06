#!/bin/bash

# Set Object named xfce4-panel to below with wmctrl.

while read line
do
	echo ">> $line"
	aray=($line)
	echo ">> ${aray[0]}"
	wmctrl -i -r ${aray[0]} -b add,below

done < <(wmctrl -l | grep xfce4-panel)

