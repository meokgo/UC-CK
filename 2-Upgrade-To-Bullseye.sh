#!/bin/sh
#First upgrade OS from Jessie to Buster using instructions in 1-Upgrade-To-Buster.txt.
#This script will upgrade OS from Buster to Bullseye on UniFi Cloud Key Model: UC-CK.
#Factory reset Cloud Key: sudo ubnt-systool reset2defaults
#Download script: wget https://raw.githubusercontent.com/meokgo/UC-CK/main/2-Upgrade-To-Bullseye.sh.
#Make script executable: chmod +x 2-Upgrade-To-Bullseye.sh.
#Run script: ./2-Upgrade-To-Bullseye.sh.
#Check if script is run as root.
if ! [ $(id -u) = 0 ]; then
  echo '\033[0;31m'"\033[1mMust run script as root.\033[0m"
  exit 1
fi
read -p "$(echo '\033[0;106m'"\033[30mUpgrade Cloud Key OS to Bullseye? (y/n)\033[0m")" yn
  case $yn in
    [yY]) echo '\033[0;36m'"\033[1mProceeding with upgrade.\033[0m";;
    [nN]) echo '\033[0;35m'"\033[1mExiting...\033[0m";
      exit;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
      exit 1;;
  esac
#Check for valid OS version.
echo '\033[0;36m'"\033[1mChecking OS version...\033[0m"
  OS_Version=$(lsb_release -a | grep Codename)
    echo "OS Version $OS_Version"
  case $OS_Version in
    *"buster") echo '\033[0;36m'"\033[1mValid OS.\033[0m";;
    *) echo '\033[0;31m'"\033[1mInvalid OS. Script only upgrades OS from Buster (Debian 10) to Bullseye (Debian 11).\033[0m";
      exit 1;;
  esac
#Check for valid kernel version.
echo '\033[0;36m'"\033[1mChecking kernel version...\033[0m"
  Kernel_Version=$(uname -r)
    echo "Kernel version: $Kernel_Version"
  case $Kernel_Version in
    3.10.20-ubnt-mtk ) echo '\033[0;36m'"\033[1mValid kernel.\033[0m";;
    * ) echo '\033[0;31m'"\033[1mInvalid kernel. Script only works on kernel 3.10.20-ubnt-mtk.\033[0m"
      exit 1;;
  esac
echo "************************************************************" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
echo "****Deleting old source list****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
echo "************************************************************" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  rm /etc/apt/sources.list
echo "****Creating new source list****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  touch /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian bullseye main contrib non-free" | sudo tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian bullseye main contrib non-free" | sudo tee -a /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian-security/ bullseye/updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian-security/ bullseye/updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian bullseye-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian bullseye-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
echo "****Updating repository package list****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  apt update
echo "****Initial upgrade to Bullseye****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  DEBIAN_FRONTEND=noninteractive apt -y upgrade --without-new-pkgs -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo $(date)":" "****Initial upgrade complete****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  sleep 2
echo "****Install full Bullseye upgrade****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  apt update
  DEBIAN_FRONTEND=noninteractive apt -y full-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo $(date)":" '\033[0;36m'"\033[1m****Full upgrade complete****\033[0m" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
#Remove un-needed packages.
echo "****Cleanup****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  apt update && sudo apt -y --purge autoremove ubnt-archive-keyring ubnt-crash-report ubnt-unifi-setup bt-proxy cloudkey-webui
#Fix network settings.
  update-alternatives --set iptables /usr/sbin/iptables-legacy
#Option to change hostname.
read -p "$(echo '\033[0;106m'"\033[30mNew hostname (leave blank to keep current):\033[0m ")" New_Name
  if [ -z "$New_Name" ]; then
    echo '\033[0;35m'"\033[1mNot updating hostname.\033[0m"
  else
    hostnamectl set-hostname $New_Name --static
  fi
#Option to change timezone.
read -p "$(echo '\033[0;106m'"\033[30mUpdate timezone? (y/n)\033[0m")" yn
  case $yn in
    [yY]) dpkg-reconfigure tzdata;;
    [nN]) echo '\033[0;35m'"\033[1mNot updating timezone.\033[0m";;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
echo $(date)":" '\033[0;32m'"\033[1mRebooting in 5 seconds...\033[0m" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  sleep 5
  reboot
