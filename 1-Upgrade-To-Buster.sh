#!/bin/sh
#This script will upgrade OS from Jessie to Buster on UniFi Cloud Key Model: UC-CK
#To make script executable: chmod +x 1-Upgrade-To-Buster.sh
#Run script: ./1-Upgrade-To-Buster.sh
echo "Do you wish to upgrade to Buster?"
  select yn in "Yes" "No"; do
    case $yn in
      Yes ) make install; break;;
      No ) exit;;
    esac
  done
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
