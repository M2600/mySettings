#!/bin/bash

# Wait for 10 sec for finishing the load of xfce4-panel
sleep 10


# Set Object named xfce4-panel to below with wmctrl.
while read line
do
	echo ">> $line"
	aray=($line)
	echo ">> ${aray[0]}"
	wmctrl -i -r ${aray[0]} -b add,below

done < <(wmctrl -l | grep xfce4-panel)

