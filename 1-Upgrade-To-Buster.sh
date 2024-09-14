#!/bin/sh
#This script will upgrade OS from Jessie to Buster on UniFi Cloud Key Model: UC-CK
#Make script executable: chmod +x 1-Upgrade-To-Buster.sh
#Run script: ./1-Upgrade-To-Buster.sh
read -p "$(echo -e '\E[37;44m'"\033[1mUpgrade Cloud Key OS to Buster? (y/n)\033[0m")" yn
case $yn in
  [yY] ) echo -e '\033[0;36m'"\033[1mProceeding with upgrade\033[0m";;
  [nN] ) echo -e '\033[0;36m'"\033[1mExiting...\033[0m";
    exit;;
  * ) echo -e '\033[0;31m'"\033[1mInvalid response\033[0m";
    exit 1;;
esac
#Check for valid OS version
echo -e '\033[0;36m'"\033[1mChecking OS version...\033[0m"
env -i bash -c '. /etc/os-release; echo -e '\E[33;106m'"\033[30mCurrent OS version is:\033[0m" $ID $VERSION_CODENAME'
case $VERSION_CODENAME in
  jessie ) echo -e '\033[0;36m'"\033[1mValid OS\033[0m";;
  * ) echo -e '\033[0;31m'"\033[1mInvalid OS. This script only works to upgrade OS from Jessie to Buster.\033[0m";
    exit 1;;
esac
#Check for valid kernel version
echo -e '\033[0;36m'"\033[1mChecking kernel version...\033[0m"
VERSION_LIMIT=3.10.20-ubnt-mtk
CURRENT_VERSION=$(uname -r)
  echo -e '\E[33;106m'"\033[30mKernel version:\033[0m $CURRENT_VERSION"
case $CURRENT_VERSION in
  3.10.20-ubnt-mtk ) echo -e '\033[0;36m'"\033[1mValid kernel\033[0m";;
  * ) echo -e '\033[0;31m'"\033[1mInvalid kernel. This script only works on kernel 3.10.20-ubnt-mtk.\033[0m"
    exit 1;;
esac
  echo "************************************************************" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  echo "****Deleting old source lists****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  echo "************************************************************" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
    rm /etc/apt/sources.list /etc/apt/sources.list.d/nodejs.list /etc/apt/sources.list.d/security.list /etc/apt/sources.list.d/ubnt-unifi.list
  echo "****Uninstalling freeradius package****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
    apt-get -y --purge autoremove unifi freeradius
  echo "****Creating new source list****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
    touch /etc/apt/sources.list
    sudo echo "deb https://deb.debian.org/debian buster main contrib non-free" | sudo tee -a /etc/apt/sources.list
    sudo echo "deb-src https://deb.debian.org/debian buster main contrib non-free" | sudo tee -a /etc/apt/sources.list
    sudo echo "deb https://deb.debian.org/debian-security/ buster/updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
    sudo echo "deb-src https://deb.debian.org/debian-security/ buster/updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
    sudo echo "deb https://deb.debian.org/debian buster-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
    sudo echo "deb-src https://deb.debian.org/debian buster-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  echo "****Updating repository package list****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
    sudo apt update
  echo "****Updating Debian keyring****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
    sudo apt -y --force-yes --reinstall install debian-archive-keyring
  echo "****Install nano****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt -y install nano
  echo "****Initial upgrade to Buster****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
    sudo apt-get -y clean
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
    echo $(date)":" "Initial upgrade complete" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
    sleep 2
  echo "****Install full Buster upgrade****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt -y full-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
    sudo apt -y autoremove
  echo $(date)":" "Full upgrade complete" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  echo $(date)":" "Rebooting in 5 seconds..." | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
    sleep 5
    sudo reboot
else
  echo "Exiting" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
fi
