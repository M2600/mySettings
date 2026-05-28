#!/bin/bash

user=m270
command="firefox"

# 1. 画面の許可（$userのみ）
xhost +si:localuser:$user > /dev/null 2>&1

# ==========================================
# 2. PipeWire(Pulse) のTCP受け口を賢く開く
# ==========================================
# IDではなく「名前」ですでに開いているかチェックする
if pactl list short modules | grep -q "module-native-protocol-tcp"; then
    WE_LOADED_IT=false
else
    pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 > /dev/null 2>&1
    WE_LOADED_IT=true
fi

# ==========================================
# 3. アプリ起動 ＆ 残党キル（パスワード入力はここでの1回のみ）
# ==========================================
# アプリ($command)が終了したら、連続して pkill を実行してからログアウトする
su - $user -c "DISPLAY=:0.0 PULSE_SERVER=127.0.0.1 XMODIFIERS=@im=fcitx GTK_IM_MODULE=xim QT_IM_MODULE=xim NO_AT_BRIDGE=1 $command; pkill -u $user"

# ==========================================
# 4. 【後片付け】m260（メインユーザー）側で開いた設定を戻す
# ==========================================
# 今回新規で開いた場合のみ、「名前指定」で音声モジュールを閉じる
if [ "$WE_LOADED_IT" = true ]; then
    pactl unload-module module-native-protocol-tcp > /dev/null 2>&1
fi

# 画面の許可も削除して元に戻す
xhost -si:localuser:$user > /dev/null 2>&1

echo "done."
