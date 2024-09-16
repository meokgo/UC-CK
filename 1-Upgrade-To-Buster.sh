#!/bin/sh
#This script will upgrade factory default state OS from Jessie to Buster on UniFi Cloud Key Model: UC-CK
#Factory reset Cloud Key: sudo ubnt-systool reset2defaults
#Default SSH user: root
#Default SSH password: ubnt
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
echo $(date)":" '\033[0;36m'"\033[1mStarting upgrade.\033[0m"
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
echo '\033[0;36m'"\033[1mDeleting old source lists...\033[0m"
  rm /etc/apt/sources.list /etc/apt/sources.list.d/nodejs.list /etc/apt/sources.list.d/security.list /etc/apt/sources.list.d/ubnt-unifi.list
echo '\033[0;36m'"\033[1mUninstalling unifi and freeradius packages...\033[0m"
  apt-get -y --purge autoremove unifi freeradius
echo '\033[0;36m'"\033[1mCreating new source list...\033[0m"
  touch /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian buster main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian buster main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian-security/ buster/updates main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian-security/ buster/updates main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian buster-updates main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian buster-updates main contrib non-free" | tee -a /etc/apt/sources.list
echo '\033[0;36m'"\033[1mUpdating repository package list...\033[0m" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  apt update
echo '\033[0;36m'"\033[1mUpdating Debian keyring...\033[0m"
  apt -y --force-yes --reinstall install debian-archive-keyring
echo '\033[0;36m'"\033[1mInstalling nano...\033[0m"
  apt update
  DEBIAN_FRONTEND=noninteractive apt -y install nano
echo '\033[0;36m'"\033[1mInitial upgrade to Buster...\033[0m"
  apt-get -y clean
  apt update
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo $(date)":" '\033[0;36m'"\033[1Initial upgrade complete\033[0m"
  sleep 2
echo '\033[0;36m'"\033[1Install full Buster upgrade...\033[0m"
  apt update
  DEBIAN_FRONTEND=noninteractive apt -y full-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  apt -y autoremove
echo $(date)":" '\033[0;36m'"\033[1mFull upgrade complete.\033[0m"
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
#Option to enable automatic updates
read -p "$(echo '\033[0;106m'"\033[30mEnable automatic updates? (y/n)\033[0m")" yn
  case $yn in
    [yY]) apt -y install unattended-upgrades && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure --priority=low unattended-upgrades && sed -i 's|//Unattended-Upgrade::Automatic-Reboot "false";|Unattended-Upgrade::Automatic-Reboot "true";|g' /etc/apt/apt.conf.d/50unattended-upgrades && systemctl start unattended-upgrades && systemctl enable unattended-upgrades;;
    [nN]) echo '\033[0;35m'"\033[1mNot enabling automatic updates.\033[0m";;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
#Update root password, option to add user
echo '\033[0;106m'"\033[30mUpdate root user password\033[0m"
passwd root
read -p "$(echo '\033[0;106m'"\033[30mAdd new sudo user? (y/n)\033[0m")" yn
  case $yn in
    [yY]) read -p "$(echo '\033[0;106m'"\033[30mEnter new user name:\033[0m ")" New_User && 
        if [ -z "$New_User" ]; then
          echo '\033[0;35m'"\033[1mNothing entered, not adding new sudo user.\033[0m"
        else
          adduser $New_User
          usermod -aG sudo $New_User
          echo "$New_User added to sudo group."
        fi;;
    [nN]) echo '\033[0;35m'"\033[1mNot adding new sudo user.\033[0m";;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
#Option to harden SSH
read -p "$(echo '\033[0;106m'"\033[30mHarden SSH settings? (y/n)\033[0m")" yn
  case $yn in
    [yY]) sed -i 's|LoginGraceTime 120|LoginGraceTime 2m|g' /etc/ssh/sshd_config && sed -i 's|PermitRootLogin yes|PermitRootLogin no|g' /etc/ssh/sshd_config && echo "MaxAuthTries 5" >> /etc/ssh/sshd_config && echo "MaxSessions 1" >> /etc/ssh/sshd_config && echo "AddressFamily inet" >> /etc/ssh/sshd_config && read -p "$(echo '\033[0;106m'"\033[30mEnter new SSH port:\033[0m ")" New_Port && 
      if [ -z "$New_Port" ]; then
        echo '\033[0;35m'"\033[1mNothing entered, not updating SSH port.\033[0m"
      else
        sed -i "s|Port 22|Port $New_Port|g" /etc/ssh/sshd_config
      fi
      /etc/init.d/ssh restart
      echo "SSH settings updated.";;
    [nN]) echo '\033[0;35m'"\033[1mNot hardening SSH settings.\033[0m";;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
echo $(date)":" '\033[0;32m'"\033[1mRebooting in 5 seconds...\033[0m"
  sleep 5
  reboot
