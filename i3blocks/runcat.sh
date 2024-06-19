#!/usr/bin/sh

animations=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

speed=0.1
maxSpeed=0.5
minSpeed=0.01
ratioMax=100
ratioMin=0
speedLen=$(bc -l <<<"$maxSpeed - $minSpeed")
cpuSpeedRatio=$(bc -l <<<"$speedLen / $ratioMax")
echo $speed > /tmp/runcat_speed


signals() {
  rm /tmp/runcat_speed
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



while true; do
	for i in "${animations[@]}"; do
		echo "$i"
		if [ -f /tmp/runcat_speed ]; then
			speed=$(cat /tmp/runcat_speed)
			sleep $speed
		else
			exit
		fi
	done
done



