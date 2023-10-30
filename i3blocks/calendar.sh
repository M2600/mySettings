#!/usr/bin/sh

mouseLocation=$(xdotool getmouselocation)
#echo $mouseLocation
# split with ":" and " "
mouseLocations=(${mouseLocation//:/ })
#echo ${mouseLocations[0]}
mouseX=${mouseLocations[1]}
mouseY=${mouseLocations[3]}

#echo mouseX: $mouseX
#echo mouseY: $mouseY

WIDTH=300
HEIGHT=200
posX=$((mouseX - WIDTH/2))
#posY=$((mouseY))
posY=25

yad --calendar \
        --width=$WIDTH --height=$HEIGHT \
	    --undecorated --fixed \
	    --close-on-unfocus --no-buttons \
	    --posx=$posX --posy=$posY \
	    > /dev/null
