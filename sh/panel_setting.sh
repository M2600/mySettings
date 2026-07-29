#!/bin/bash

# Wait for 10 sec for finishing the load of xfce4-panel
sleep 10


# Set Object named xfce4-panel to below with wmctrl.
while read line
do
	echo ">> $line"
	xfce4panels=($line)
	echo ">> ${xfce4panels[0]}"
	wmctrl -i -r ${xfce4panels[0]} -b add,below

done < <(wmctrl -l | grep xfce4-panel)


# Set Object named tint2 to below with wmctrl.
# It can config by tint2 config file
#while read line
#do
#	echo ">> $line"
#	tint2s=($line)
#	echo ">> ${tint2s[0]}"
#	wmctrl -i -r ${tint2s[0]} -b add,below
#done < <(wmctrl -l | grep tint2)
