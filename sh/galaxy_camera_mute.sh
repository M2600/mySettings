# Usage
# 1. Connect your Samsung Galaxy device to your computer via USB.
# 2. Make sure USB debugging is enabled on your device.
# 3. Run this script in your terminal.
#
# Install packages
if [ $(which adb) ]; then
	echo "adb is already installed"
else
	echo "adb is not installed, installing..."
	yay -S android-tools android-udev
fi
adb shell settings put system csc_pref_camera_forced_shuttersound_key 0 && echo "done!" || echo "failed to mute camera shutter sound"
