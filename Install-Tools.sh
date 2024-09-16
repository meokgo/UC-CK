#!/bin/sh
#This script will install some useful tools
#Download script: wget https://raw.githubusercontent.com/meokgo/UC-CK/main/Install-Tools.sh
#Make script executable: chmod +x Install-Tools.sh
#Run script: ./Install-Tools.sh
#Check if script is run as root
if ! [ $(id -u) = 0 ]; then
  echo '\033[0;31m'"\033[1mMust run script as root.\033[0m"
  exit 1
fi
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mInstall tools? (y/n)\033[0m")" yn
  case $yn in
    [yY]) echo '\033[0;36m'"\033[1mProceeding with install.\033[0m"
      break;;
    [nN]) echo '\033[0;35m'"\033[1mExiting...\033[0m";
      exit;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
  esac
done
echo $(date)":" '\033[0;36m'"\033[1mStarting install...\033[0m"
#Add tailscale to repository
curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
#Install tools
apt update && apt -y install fzf tldr cmatrix iperf3 speedtest-cli stress s-tui nnn ncdu links2 telnet tailscale
#Enable device as a subnet router
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mEnable device as subnet router? (y/n)\033[0m")" yn
  case $yn in
    [yY]) echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf && echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf && sysctl -p /etc/sysctl.d/99-tailscale.conf
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot enabling as subnet router.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Advertise subnet routes
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mUpdate advertised subnet routes? (y/n)\033[0m")" yn
  case $yn in
    [yY]) tailscale up --advertise-routes=192.0.2.0/24,198.51.100.0/24
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot updating advertised subnet routes.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
