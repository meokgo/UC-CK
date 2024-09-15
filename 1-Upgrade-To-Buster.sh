#!/bin/sh
#This script will upgrade factory default state OS from Jessie to Buster on UniFi Cloud Key Model: UC-CK
#Factory reset Cloud Key: sudo ubnt-systool reset2defaults
#Download script: wget https://raw.githubusercontent.com/meokgo/UC-CK/main/1-Upgrade-To-Buster.sh
#Make script executable: chmod +x 1-Upgrade-To-Buster.sh
#Run script: ./1-Upgrade-To-Buster.sh
#Check if script is run as root
if ! [ $(id -u) = 0 ]; then
  echo '\033[0;31m'"\033[1mMust run script as root.\033[0m"
  exit 1
fi
read -p "$(echo '\033[0;106m'"\033[30mUpgrade Cloud Key OS to Buster? (y/n)\033[0m")" yn
  case $yn in
    [yY]) echo '\033[0;36m'"\033[1mProceeding with upgrade.\033[0m";;
    [nN]) echo '\033[0;35m'"\033[1mExiting...\033[0m";
      exit;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
      exit 1;;
  esac
echo $(date)":" '\033[0;36m'"\033[1mStarting upgrade.\033[0m" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
#Check for valid OS version
echo '\033[0;36m'"\033[1mChecking OS version...\033[0m"
  OS_Version=$(lsb_release -a | grep Codename)
    echo "OS Version $OS_Version"
  case $OS_Version in
    *"jessie") echo '\033[0;36m'"\033[1mValid OS.\033[0m";;
    *) echo '\033[0;31m'"\033[1mInvalid OS. Script only upgrades OS from Jessie (Debian 8) to Buster (Debian 10).\033[0m";
      exit 1;;
  esac
#Check for valid kernel version
echo '\033[0;36m'"\033[1mChecking kernel version...\033[0m"
  Kernel_Version=$(uname -r)
    echo "Kernel version: $Kernel_Version"
  case $Kernel_Version in
    3.10.20-ubnt-mtk ) echo '\033[0;36m'"\033[1mValid kernel.\033[0m";;
    * ) echo '\033[0;31m'"\033[1mInvalid kernel. Script only works on kernel 3.10.20-ubnt-mtk.\033[0m"
      exit 1;;
  esac
echo "************************************************************" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
echo "****Deleting old source lists****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
echo "************************************************************" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  rm /etc/apt/sources.list /etc/apt/sources.list.d/nodejs.list /etc/apt/sources.list.d/security.list /etc/apt/sources.list.d/ubnt-unifi.list
echo "****Uninstalling unifi and freeradius packages****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  apt-get -y --purge autoremove unifi freeradius
echo "****Creating new source list****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  touch /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian buster main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian buster main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian-security/ buster/updates main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian-security/ buster/updates main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian buster-updates main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian buster-updates main contrib non-free" | tee -a /etc/apt/sources.list
echo "****Updating repository package list****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  apt update
echo "****Updating Debian keyring****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  apt -y --force-yes --reinstall install debian-archive-keyring
echo "****Install nano****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  apt update
  DEBIAN_FRONTEND=noninteractive apt -y install nano
echo "****Initial upgrade to Buster****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  apt-get -y clean
  apt update
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo $(date)":" "****Initial upgrade complete****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  sleep 2
echo "****Install full Buster upgrade****" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  apt update
  DEBIAN_FRONTEND=noninteractive apt -y full-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  apt -y autoremove
echo $(date)":" '\033[0;36m'"\033[1m****Full upgrade complete****\033[0m" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
#Option to change hostname
read -p "$(echo '\033[0;106m'"\033[30mNew hostname (leave blank to keep current):\033[0m ")" New_Name
  if [ -z "$New_Name" ]; then
    echo '\033[0;35m'"\033[1mNot updating hostname.\033[0m"
  else
    hostnamectl set-hostname $New_Name --static
  fi
#Option to change timezone
read -p "$(echo '\033[0;106m'"\033[30mUpdate timezone? (y/n)\033[0m")" yn
  case $yn in
    [yY]) dpkg-reconfigure tzdata;;
    [nN]) echo '\033[0;35m'"\033[1mNot updating timezone.\033[0m";;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
#Option to replace motd
read -p "$(echo '\033[0;106m'"\033[30mReplace motd? (y/n)\033[0m")" yn
  case $yn in
    [yY]) wget -O /etc/motd https://raw.githubusercontent.com/meokgo/UC-CK/main/motd;;
    [nN]) echo '\033[0;35m'"\033[1mNot replacing motd.\033[0m";;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
echo $(date)":" '\033[0;32m'"\033[1mRebooting in 5 seconds...\033[0m" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  sleep 5
  reboot
