#!/bin/sh
#This script will upgrade factory default state OS from Debian Jessie to Debian Buster on UniFi Cloud Key Model: UC-CK
#This script will disabe or remove most UniFi packages, the device will no longer function as a Cloud Key for UniFi devices, but Emergency Recovery UI still works.
#Factory reset Cloud Key: sudo ubnt-systool reset2defaults
#Default SSH user: root
#Default SSH password: ubnt
#Download script: sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/1-Upgrade-To-Buster.sh
#Make script executable: sudo chmod +x 1-Upgrade-To-Buster.sh
#Run script: sudo ./1-Upgrade-To-Buster.sh
#Script start time stamp
echo "$(date) - Script started" >> 1-Upgrade-To-Buster.log
(
#Check if script is run as root
if ! [ $(id -u) = 0 ]; then
  echo '\033[0;31m'"\033[1mMust run script as root.\033[0m"
  exit 1
fi
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mUpgrade Cloud Key OS to Buster? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) echo '\033[0;36m'"\033[1mProceeding with upgrade.\033[0m"
      break;;
    [nN]) echo '\033[0;35m'"\033[1mExiting...\033[0m";
      exit;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
  esac
done
#Check for valid OS version
echo '\033[0;36m'"\033[1mChecking OS version...\033[0m"
  OS_Version=$(lsb_release -a | grep Codename)
  echo '\033[0;36m'"\033[1mCurrent OS $OS_Version\033[0m"
  case $OS_Version in
    *"jessie") echo '\033[0;36m'"\033[1mValid OS.\033[0m";;
    *) echo '\033[0;31m'"\033[1mInvalid OS. Script only upgrades OS from Jessie (Debian 8) to Buster (Debian 10).\033[0m";
      exit 1;;
  esac
#Check for valid kernel version
echo '\033[0;36m'"\033[1mChecking kernel version...\033[0m"
  Kernel_Version=$(uname -r)
  echo '\033[0;36m'"\033[1mKernel version: $Kernel_Version\033[0m"
  case $Kernel_Version in
    3.10.20-ubnt-mtk ) echo '\033[0;36m'"\033[1mValid kernel.\033[0m";;
    * ) echo '\033[0;31m'"\033[1mInvalid kernel. Script only works on kernel 3.10.20-ubnt-mtk.\033[0m"
      exit 1;;
  esac
#Option to change hostname
read -p "$(echo '\033[0;106m'"\033[30mNew hostname (leave blank to keep current):\033[0m ")" New_Name
  if [ -z "$New_Name" ]; then
    echo '\033[0;35m'"\033[1mNot updating hostname.\033[0m"
  else
    hostnamectl set-hostname $New_Name --static
    sed -i "s|UniFi-CloudKey|$New_Name|g" /etc/hosts
    sed -i "s|localhost|$New_Name|g" /etc/hosts
  fi
#Option to change timezone, default is PDT
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mUpdate timezone? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) dpkg-reconfigure tzdata
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot updating timezone.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Start OS upgrade time stamp
echo "$(date) - Upgrade started" >> 1-Upgrade-To-Buster.log
echo '\033[0;36m'"\033[1mUninstalling unifi and freeradius packages...\033[0m"
  apt-get -y --purge autoremove unifi freeradius
echo '\033[0;36m'"\033[1mDeleting old source lists...\033[0m"
  rm /etc/apt/sources.list /etc/apt/sources.list.d/nodejs.list /etc/apt/sources.list.d/security.list /etc/apt/sources.list.d/ubnt-unifi.list
echo '\033[0;36m'"\033[1mCreating new source list...\033[0m"
echo "deb https://deb.debian.org/debian buster main contrib non-free
deb-src https://deb.debian.org/debian buster main contrib non-free
deb https://deb.debian.org/debian-security/ buster/updates main contrib non-free
deb-src https://deb.debian.org/debian-security/ buster/updates main contrib non-free
deb https://deb.debian.org/debian buster-updates main contrib non-free
deb-src https://deb.debian.org/debian buster-updates main contrib non-free" > /etc/apt/sources.list
echo '\033[0;36m'"\033[1mUpdating Debian keyring...\033[0m"
  apt update
  apt -y --force-yes --reinstall install debian-archive-keyring
echo '\033[0;36m'"\033[1mInitial upgrade to Buster...\033[0m"
  apt-get -y clean
  apt update
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo $(date)":" '\033[0;36m'"\033[1mInitial upgrade complete.\033[0m"
echo '\033[0;36m'"\033[1mInstall full Buster upgrade...\033[0m"
  apt update
  DEBIAN_FRONTEND=noninteractive apt -y full-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo $(date)":" '\033[0;36m'"\033[1mFull upgrade complete.\033[0m"
#Fix network settings
update-alternatives --set iptables /usr/sbin/iptables-legacy
  #Fix DNS:
  systemctl disable systemd-resolved.service
  systemctl stop systemd-resolved
  echo "nameserver 8.8.8.8
nameserver 8.8.4.4" > /etc/resolv.conf
echo $(date)":" '\033[0;32m'"\033[1mRebooting in 5 seconds...\033[0m"
  sleep 5
  reboot
#End time stamp
echo "$(date) - Script finished" >> 1-Upgrade-To-Buster.log
) 2>&1 | tee -a 1-Upgrade-To-Buster.log
