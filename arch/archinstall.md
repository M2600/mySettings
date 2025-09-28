# ArchLinux インストール

## 0. 下準備
- archiso
- インストール先ディスク


## 1. パーティション
パーティション方式
- BIOSならMBR
- UEFIならGPT
最近のマシンは基本的にUEFIなので、特別な理由が無い場合はGPTを選択します。


### 必要なパーティション
#### BIOS
BIOSの場合は`ルートディレクトリのパーティション` (`スワップ`)が必要です。

|Mount point | Partition type            | Size       |
|:-----------|:-------------------       |:-----------|
|swap        |Linux swap                 | RAM*1~2    |
|/           |Linux filesystem           | 残り        |

#### UEFI
UEFIの場合は`EFIシステムパーティション` `ルートディレクトリのパーティション` (`スワップ`)が必要です。

|Mount point | Partition type            | Size       |
|:-----------|:-------------------       |:-----------|
|/boot       |EFI system partition (ef00)| >512MB     |
|swap        |Linux swap (8200)          | RAM*1~2    |
|/           |Linux filesystem (8300)    | 残り        |

#### スワップについて
スワップはパーティションで作る方法とファイルで作る方法があります。

どちらでも良いようですが、パフォーマンスはパーティション、柔軟性はファイルに分があるようです。

今回はスワップファイルを利用します。スワップファイルの設定は後術。

### コマンド
MBRの場合は`cfdisk`、GPTの場合は`cgdisk`を使用します。
TUIで操作できるので簡単でよいですね。

```
# MBR
# cfdisk /dev/sdb
# GPT
# cgdisk /dev/sdb
```
でパーティション編集できます。`/dev/sdb`の部分はインストールしたいディスクを選びます。
ディスク一覧は`lsblk`で参照できます。
```
# lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sdb           8:16   0 931.5G  0 disk
```

## 2. フォーマット
フォーマットは以下のように行います。
```
# EFI system partition
# mkfs.fat -F 32 /dev/sdb1
# /
# mkfs.ext4 /dev/sdb2
```

### EFIシステムパーティション
EFIシステムパーティションはFAT32でフォーマットします。
```
# mkfs.fat -F 32 /dev/sdb1
```

### Swapパーティション
swapパーティションがある場合は`mkswap`を用いてフォーマットします。
```
# mkswap /dev/sdb3
```

### その他のパーティション
OS用やデータ保存用などのパーティションのフォーマットではいくつかの選択肢があります。
現状よく使われるのは`ext4`です。
```
# mkfs.ext4 /dev/sdb2
```

ここまででフォーマットは完了です。`lsblk --fs`で確認してみます。
```
# lsblk --fs
NAME      FSTYPE FSVER LABEL UUID                                 
sdb
├─sdb1    vfat   FAT32       34CC-9D1E
└─sdb2    ext4   1.0         6ef48f42-0c60-490f-9a1a-937bbeda7b20
```

## 3. マウント
作成したパーティションをマウントします。
まず、OS用のパーティションを`/mnt`にマウントします。
```
# mount /dev/sdb2 /mnt
```
続いて、EFIシステムパーティションを`/mnt/boot`にマウントします。
```
# mkdir /mnt/boot
# mount /dev/sdb1 /mnt/boot
```

## 4. サーバーミラー
### reflector
`reflector`コマンドは条件を指定してミラーURLを取得できます。
```
# reflector --sort rate --coutry jp --latest 10 --save /etc/pacman.d/mirrorlist
```
この例では日本のミラーをスコアが高い順に10個取得し、`/etc/pacman.d/mirrorlist`に保存します。

### 手動
あるいは手動で`/etc/pacman.d/mirrorlist`を編集し、使いたいミラーのコメントを外します。

## 5. インストール
Linuxのパッケージをインストールします。

```
# pacstrap -i /mnt base base-devel linux linux-firmware linux-headers vim sudo
```

`pacstrap`でインストールできます。

`-i`オプションでインストール中の確認事項を有効にできます。

`/mnt`インストール先を指定します。

以降はインストールしたいパッケージの指定です。

`base`,`linux`このあたりは必須パッケージです。

`linux-firmware`,`vim`,`sudo`ハードウェア用のファームウェアやエディタ、sudoも事実上必須パッケージです。


## 6. fstab
`/etc/fstab`は起動時にパーティションを自動でマウントするための定義ファイルです。

### genfstab
```
# genfstab -t PARTUUID /mnt >> /mnt/etc/fstab
```
`genfstab`で現在のマウント構成からfstabファイルを生成します。

`-t PARTUUID`パーティションを指定する際、PARTUUIDを使用します。このIDはパーティションに紐づけられた値でフォーマットしても値が維持されます。GPTでのみ使えます。

`-U`でUUIDで指定することもできます。

これらのオプションを使用しないと、パーティションを`/dev/sda1`のような値で指定します。ディスクの接続構成が変化するとこの値が変わり、正常に起動できなくなります。経験上UUID若しくはPARTUUIDで指定することをおすすめします。

`/mnt`で`/mnt`ディレクトリ配下の構成から生成します。

`>> /mnt/etc/fstab`で出力を`/mnt/etc/fstab`に追記します。
新しくインストールするArchのfstabファイルは`/mnt`下のものになります。`/etc/fstab`では現在起動しているArchのfstabを指定することになりますので注意してください。

## 7. arch-chroot
この先はインストールするOSに入って作業を行います。
```
# arch-chroot /mnt
```

## 8. タイムゾーン
`/etc/localtime`にタイムゾーンのシンボリックリンクを作成します。
```
# ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
```

## 9. ハードウェアクロック


## 10. ロケール
使用する言語を設定します。
ここでは日本語と英語を有効化します。

### local.genの編集
```
# vim /etc/locale.gen
```
`en_US.UTF-8 UTF-8`と`ja_JP.UTF-8 UTF-8`の行をアンコメントします。

### locale-genの実行
`locale-gen`コマンドで設定した言語のロケールを生成します。
```
# locale-gen
```

### locale.confの設定
`/etc/locale.conf`にデフォルトのロケールを指定します。
私はどのみち言語設定は英語を使う予定ですが、

**Linuxの言語を日本語にしたい場合でもこの段階では英語を指定してください。**

```
# echo LANG=en_US.UTF-8 > /etc/locale.conf
```

Linuxのターミナル(GUI上のエミュレータではなくネイティブのターミナル)上では日本語を表示できないため、この段階で日本語を設定するとこのあとのインストール作業に支障をきたします。

万が一、そのような状況になっても以下のコマンドで一時的にロケールを英語に変更できます。
```
# export LANG=en_US.UTF-8
```

## 11. キーマップ
英字配列以外のキーボードを使用している場合は、キーボード配列の設定を変更します。

日本語配列なら以下を設定します。
```
# echo KEYMAP=jp106 > /etc/vconsole.conf
```

**ここでの設定はネイティブなターミナル上の設定です。GUI上は別で設定する必要があります。**


## 12. ホスト名
コンピュータのホスト名を設定します。ホスト名はネットワーク上でマシンを識別するための名前です。
`/etc/hostname`にホスト名を記述します。

ホスト名`arch`を指定する例です。
```
# echo arch > /etc/hostname
```


## 13. ネットワーク設定
chrootの時点でネットワーク接続に必要なパッケージの設定をしておきます。
ここでは`sytemd-networkd`と`systemd-resolved`を使用します。
```
# systemctl enable systemd-networkd systemd-resolved
```

### 設定ファイル
`/etc/systemd/network/*.network`に設定を記述します。
ファイル名は任意で作ります。
```
vim /etc/systemd/network/1.network
```
有線LANの場合は以下を記述します。
```
[Match]
Name=<インターフェイス名>
[Network]
DHCP=yes
```
無線LANの場合は以下を記述します。
```
[Match]
Name=wlan0

[Network]
DHCP=yes
IPv6PrivacyExtensions=true
IgnoreCarrierLoss=3s
```
`IPv6PrivacyExtensions=true`はIPv6のIPアドレスをプライバシー拡張機能を使って取得します。
セキュリティの理由から有効化推奨です。

`IgnoreCarrierLoss=3s`は接続ロスト時に、指定時間以下で回復すれば構成を維持する設定です。

無線LANを使う場合はさらに`iwd`パッケージをインストール、サービス有効化する必要があります。
```
# pacman -S iwd
# systemctl enable iwd
```

systemd-resolvedの設定は`/etc/resolv.conf`に用意する必要があります。
/run/systemd/resolve/にあるファイルをリンクします。
```
# ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```
**このリンクは`arch-chroot`段階では実行しないでください**

## 14. パスワード
rootのパスワードを設定します。コマンド実行後、指示に従ってパスワード、パスワード確認を入力してください。
```
# passwd
```

## 15. マイクロコード
マイクロコード(CPUファームウェア)の更新等を管理するパッケージをインストールします。

Intel CPUの場合は`intel-ucode`,AMD CPUの場合は`amd-ucode`をインストールします。
```
// Intel CPU
# pacman -S intel-ucode

// AMD CPU
# pacman -S amd-ucode
```

**マイクロコードを自動更新するにはブートローダの設定も行う必要があります。**

詳細はブートローダの項で記述します。


## 16. ブートローダー
ここではGRUBを使用します。

### マイクロコード
マイクロコードの自動更新を設定したい場合は前述のマイクロコードパッケージをインストールしておいてください。

### GRUB (UEFI-GPT 64bit)
必要パッケージをインストールします。
```
# pacman -S grub efibootmgr
```

#### GRUBのファイル
ブートに必要なファイルをインストールします。
```
# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub
```
/boot/grub 以下に GRUB のファイル、/boot/EFI/arch_grub に EFI ブートファイルが作成されます。

`--target=x86_64-efi`でUEFI(64bit)用のファイルを生成します。

`--efi-directory=/boot`: EFIシステムパーティションをマウントしてディレクトリを指定します。

`--bootlader-id=arch_grub`: 作成するブートローダの名前です。同じディスクに複数のOSをインストトールする場合は被らないように名前をつけてください。

#### .efiのコピー
一部のUEFIファームウェアでは`/boot/EFI/boot`内に`bootx64.efi`という名前のデフォルトefiファイルが必要です。
念の為、efiファイルをコピーします。
```
# mkdir /boot/EFI/boot
# cp /boot/EFI/arch_grub/grubx64.efi /boot/EFI/boot/bootx64.efi
```
`arch_grub`の部分は1つ前のコマンドで指定したブートローダ名を指定してください。

#### マルチブートしている場合
一台のマシンにWindows等複数のOSをインストールしている場合、起動時にGRUBメニューから起動するOSを選択できるようにすることができます。

##### os-prober
まずは`os-prober`をインストールします。
```
# pacman -S os-prober
```

##### OSがインストールされているパーティションをマウント
既存のOSのパーティションをマウントします。
Linuxの場合は`/`(root)にマウントされるパーティション及び`EFIシステムパーティション`、Windowsの場合は`EFIシステムパーティション`(100MB)をマウントします。

マウント場所はどこでも良いと思いますが、習慣上`/mnt`にマウントします。
```
# mount /dev/sda2 /mnt
# mount /dev/sda1 /mnt/boot
```
既存OSが複数ある場合は`/mnt`配下にディレクトリを作ってそこにマウントします。
```
// ディレクトリ作成
# mkdir /ubuntu
# mkdir /windows

// マウント

// Linuxの場合はシステムルートをマウント
// 念の為EFIシステムパーティションも起動時と同じ位置にマウントしておく
# mount /dev/sda2 /mnt/ubuntu
# mount /dev/sda1 /mnt/ubuntu/boot

// Windowsの場合はEFIシステムパーティション(100MBのパーティション)をマウント
# mount /dev/nvmp1n1p1 /mnt/windows
```

`os-prober`コマンドを実行し、OSが認識されるか確認します。
```
# os-prober
```
インストールされているOSが出力されるはずです。
```
/dev/nvme1n1p1@/EFI/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi
/dev/sda2:Arch Linux (rolling):Arch:linux
```

##### grubの設定
`/etc/default/grub`を編集します。
```
# vim /etc/default/grub
```
以下の項目をアンコメントします。
```
GRUB_DISABLE_OS_PROBER=false
```
これで`grub-mkconfig`実行時に`os-prober`が実行され、見つかったOSを設定ファイルに取り込んでくれます。


#### grub.cfgの生成
grubの設定ファイルを生成します。
```
# grub-mkconfig -o /boot/grub/grub.cfg
```

### GRUB (BIOS-MBR)
必要なパッケージをインストールします。
```
# pacman -S grub
```

#### GRUBファイル
起動に必要なファイルをインストールします。
MBRの場合はパーティションではなく、書き込み対象のディスクを指定します。
```
# grub-install --target=i386-pc /dev/sdb
# grub-mkconfig -o /boot/grub/grub.cfg
```
`--target=i386-pc`と指定します。64bitでもこのオプションを指定してください。

**`/dev/sdb`の部分は環境に合わせてください。このとき`/dev/sdb1`のようにパーティションを指定しないでください。**


## 17. 再起動
GRUBのマルチブートの設定をしていた場合はそこでマウントしたパーティションをアンマウントします。

`arch-chroot`を抜け、アンマウントして再起動します。
```
# exit
# unmount -R /mnt
# reboot
```

起動時にbootメニューでArchをインストールしたディスクを選択してください。


## 18. ログイン
最初はユーザ`root`パスワードは14項で設定したものを使用する

## 19. ネットワーク設定の続き


