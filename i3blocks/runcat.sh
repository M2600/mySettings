#!/usr/bin/sh


#animations=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
animations=(⠉⠉ ⠈⠙ "⠀⠹" "⠀⢸" "⠀⣰" ⢀⣠ ⣀⣀ ⣄⡀ "⣆⠀" "⡇⠀" "⠏⠀" ⠋⠁)

terminal=false
for i in "${@}"; do
	if [ $i = "-t" ]; then
		terminal=true
	fi
done


speed=0.1
maxSpeed=0.5
minSpeed=0.01
ratioMax=100
ratioMin=0
speedLen=$(bc -l <<<"$maxSpeed - $minSpeed")
cpuSpeedRatio=$(bc -l <<<"$speedLen / $ratioMax")
echo $speed > /tmp/runcat_speed


signals() {
	kill $backgroundPid
	if [ -f /tmp/runcat_speed ]; then
		rm /tmp/runcat_speed
	fi
	exit
}

trap signals SIGHUP SIGINT SIGKILL SIGTERM



{
while true; do
	sleep 1
	cpuUsage=$(vmstat 1 2 | tail -1 | awk '{print $15}')
	speed=$(bc -l <<<"$cpuSpeedRatio * $cpuUsage")
	speed=$(bc -l <<<"$speed + $minSpeed")
	echo $speed > /tmp/runcat_speed
done
} &

backgroundPid=$!

while true; do
	for i in "${animations[@]}"; do
		if [ $terminal = true ]; then
			echo -ne "\r$i"
		else
			echo "$i"
		fi
		if [ -f /tmp/runcat_speed ]; then
			speed=$(cat /tmp/runcat_speed)
			sleep $speed
		else
			signals
		fi
	done
done



