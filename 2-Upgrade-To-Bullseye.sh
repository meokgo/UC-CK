#!/bin/sh
#First upgrade OS from Jessie to Buster using 1-Upgrade-To-Buster.sh
#This script will upgrade OS from Buster to Bullseye on UniFi Cloud Key Model: UC-CK
#Factory reset Cloud Key: sudo ubnt-systool reset2defaults
#Default SSH user: root
#Default SSH password: ubnt
#Download script: sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/2-Upgrade-To-Bullseye.sh
#Make script executable: sudo chmod +x 2-Upgrade-To-Bullseye.sh
#Run script: sudo ./2-Upgrade-To-Bullseye.sh
#Start time
echo "$(date) - Script started" >> 2-Upgrade-To-Bullseye.log
(
#Check if script is run as root
if ! [ $(id -u) = 0 ]; then
  echo '\033[0;31m'"\033[1mMust run script as root.\033[0m"
  exit 1
fi
while : ; do
read -p "$(echo '\033[0;106m'"\033[30mUpgrade Cloud Key OS to Bullseye? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) echo '\033[0;36m'"\033[1mProceeding with upgrade.\033[0m"
      break;;
    [nN]) echo '\033[0;35m'"\033[1mExiting...\033[0m";
      exit;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
  esac
done
echo $(date)":" '\033[0;36m'"\033[1mStarting upgrade...\033[0m"
#Check for valid OS version
echo '\033[0;36m'"\033[1mChecking OS version...\033[0m"
  OS_Version=$(lsb_release -a | grep Codename)
  echo '\033[0;36m'"\033[1mCurrent OS $OS_Version\033[0m"
  case $OS_Version in
    *"buster") echo '\033[0;36m'"\033[1mValid OS.\033[0m";;
    *) echo '\033[0;31m'"\033[1mInvalid OS. Script only upgrades OS from Buster (Debian 10) to Bullseye (Debian 11).\033[0m";
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
echo '\033[0;36m'"\033[1mDeleting old source list...\033[0m"
  rm /etc/apt/sources.list
echo '\033[0;36m'"\033[1mCreating new source list...\033[0m"
  touch /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian bullseye main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian bullseye main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb https://security.debian.org/debian-security bullseye-security main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb-src https://security.debian.org/debian-security/ bullseye-security main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb https://deb.debian.org/debian bullseye-updates main contrib non-free" | tee -a /etc/apt/sources.list
  echo "deb-src https://deb.debian.org/debian bullseye-updates main contrib non-free" | tee -a /etc/apt/sources.list
echo '\033[0;36m'"\033[1mUpdating repository package list...\033[0m"
  apt update
echo '\033[0;36m'"\033[1mInitial upgrade to Bullseye...\033[0m"
  DEBIAN_FRONTEND=noninteractive apt -y upgrade --without-new-pkgs -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo $(date)":" '\033[0;36m'"\033[1mInitial upgrade complete.\033[0m"
  sleep 2
echo '\033[0;36m'"\033[1mInstall full Bullseye upgrade...\033[0m"
  apt update
  DEBIAN_FRONTEND=noninteractive apt -y full-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo $(date)":" '\033[0;36m'"\033[1mFull upgrade complete.\033[0m"
#Remove unnecessary packages
echo '\033[0;36m'"\033[1mCleanup...\033[0m"
  apt update
  apt -y --purge autoremove ubnt-archive-keyring ubnt-crash-report ubnt-unifi-setup bt-proxy cloudkey-webui
  apt -y --purge autoremove
  rm -R /etc/bt-proxy
echo '\033[0;36m'"\033[1mCleanup complete.\033[0m"
sleep 2
echo $(date)":" '\033[0;32m'"\033[1mRebooting in 5 seconds...\033[0m" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
  sleep 5
  reboot
#End time
echo "$(date) - Script finished" >> 2-Upgrade-To-Bullseye.log
) 2>&1 | tee -a 2-Upgrade-To-Bullseye.log
