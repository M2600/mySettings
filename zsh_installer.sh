#!/bin/sh

HISTCONTROL=ignorespace

if [ "$(id -u)" -ne 0 ]; then
	 echo "This script must be run as root"
	 exit 1
fi
	

 sudo apt update
 sudo apt install zsh -y

 chsh -s $(which zsh)



if [ ! -e {~/.zsh/zsh-autosuggestions} ]; then
	 mkdir -p ~/.zsh/zsh-autosuggestions
fi

if !(type "git" > /dev/null 2>&1); then
	 echo git command not found.
	 echo Install git...
	 sudo apt install git -y
fi

 git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions

if !(type "curl" > /dev/null 2>&1); then
	 sudo apt install curl -y
fi

 curl https://raw.githubusercontent.com/M2600/mySettings/main/zshrc > ~/.zshrc

