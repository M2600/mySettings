#!/bin/bash

user=m270
command="firefox"

# 1. 画面の許可（$userのみ）
xhost +si:localuser:$user > /dev/null #2>&1

# 2. PipeWire(Pulse) のTCP受け口を開き、その「ID」を記憶する
# (すでに開いている場合も考慮して、新しく読み込まれたIDだけを取得)
MODULE_ID=$(pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 ) #2>/dev/null)

# 3. TCP経由で音声を流しつつ $user で Firefox を起動
# XIMを使ってIMEも使えるように。Dbusでは動作しなかった
# (バックグラウンドではなく、フォアグラウンドで実行して終了を待つ)
#echo -n "password for $user: "
su - $user -c "DISPLAY=:0.0 PULSE_SERVER=127.0.0.1 XMODIFIERS=@im=fcitx GTK_IM_MODULE=xim QT_IM_MODULE=xim NO_AT_BRIDGE=1 $command" #2>/dev/null
#echo ""

# ==========================================
# 4. 【後片付け】Firefoxが閉じられると、ここから下の処理が動きます
# ==========================================

# TCP受け入れモジュールを破棄（非公開にする）
if [ -n "$MODULE_ID" ]; then
    pactl unload-module "$MODULE_ID" > /dev/null 2>&1
fi

# 画面の許可も削除して元に戻す
xhost -si:localuser:m270 > /dev/null 2>&1

#echo "安全にセッションを終了し、ポートと画面権限を閉じました。"
echo "done."
