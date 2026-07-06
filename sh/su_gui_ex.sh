#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <user> <command...>" >&2
    exit 1
fi
user="$1"
shift
command="$*"

cleanup() {
    if [ "$WE_LOADED_IT" = true ]; then
        pactl unload-module module-native-protocol-tcp > /dev/null 2>&1
    fi
    xhost -si:localuser:$user > /dev/null 2>&1
    echo "done."
}

trap cleanup INT TERM EXIT

xhost +si:localuser:$user > /dev/null 2>&1

if pactl list short modules | grep -q "module-native-protocol-tcp"; then
    WE_LOADED_IT=false
else
    pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 > /dev/null 2>&1
    WE_LOADED_IT=true
fi

su - "$user" -c "
uid=\$(id -u)
runtime_dir=\"/run/user/\$uid\"

if [ ! -S \"\$runtime_dir/bus\" ]; then
    echo '警告: セッションD-Busバスが見つかりません。'
    echo 'あらかじめ管理者に loginctl enable-linger $user を依頼してください。'
    exit 1
fi

export DISPLAY=:0.0
export PULSE_SERVER=127.0.0.1
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim
export NO_AT_BRIDGE=1
export XDG_RUNTIME_DIR=\"\$runtime_dir\"
export DBUS_SESSION_BUS_ADDRESS=\"unix:path=\$runtime_dir/bus\"

dbus-update-activation-environment --systemd DISPLAY PULSE_SERVER XMODIFIERS GTK_IM_MODULE QT_IM_MODULE NO_AT_BRIDGE

$command
pkill -u $user
"
