#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <user> <command...>" >&2
    exit 1
fi
user="$1"
shift
command="$*"

# ==========================================
# 後片付け関数（trapから呼ばれる）
# ==========================================
cleanup() {
    if [ "$WE_LOADED_IT" = true ]; then
        pactl unload-module module-native-protocol-tcp > /dev/null 2>&1
    fi
    xhost -si:localuser:$user > /dev/null 2>&1
    echo "done."
}

# INT (Ctrl+C), TERM, EXIT すべてでcleanupを実行
trap cleanup INT TERM EXIT

# 1. 画面の許可
xhost +si:localuser:$user > /dev/null 2>&1

# ==========================================
# 2. PipeWire(Pulse) のTCP受け口を開く
# ==========================================
if pactl list short modules | grep -q "module-native-protocol-tcp"; then
    WE_LOADED_IT=false
else
    pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 > /dev/null 2>&1
    WE_LOADED_IT=true
fi

# ==========================================
# 3. アプリ起動
# ==========================================
su - $user -c "DISPLAY=:0.0 PULSE_SERVER=127.0.0.1 XMODIFIERS=@im=fcitx GTK_IM_MODULE=xim QT_IM_MODULE=xim NO_AT_BRIDGE=1 $command; pkill -u $user"

# EXITトラップがcleanupを呼ぶので、ここには後処理不要
