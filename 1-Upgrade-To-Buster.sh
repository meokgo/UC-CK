#!/bin/sh
  rm /etc/apt/sources.list /etc/apt/sources.list.d/nodejs.list /etc/apt/sources.list.d/security.list /etc/apt/sources.list.d/ubnt-unifi.list
  apt-get -y --purge autoremove unifi freeradius
  touch /etc/apt/sources.list
  sudo echo "deb https://deb.debian.org/debian buster main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo echo "deb-src https://deb.debian.org/debian buster main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo echo "deb https://deb.debian.org/debian-security/ buster/updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo echo "deb-src https://deb.debian.org/debian-security/ buster/updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo echo "deb https://deb.debian.org/debian buster-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo echo "deb-src https://deb.debian.org/debian buster-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo apt update
  sudo apt -y --force-yes --reinstall install debian-archive-keyring
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt -y install nano
  sudo apt-get -y clean
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt -y full-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  sudo apt -y autoremove
  sudo reboot
