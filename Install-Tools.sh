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
  read -p "$(echo '\033[0;106m'"\033[30mInstall tools? (y/n)\033[0m ")" yn
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
#Tailscale/Headscale setup
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mSetup Tailscale/Headscale? (y/n)\033[0m ")" yn
  case $yn in
    echo '\033[0;106m'"\033[30mCreate a preauth-key in Tailscale (https://tailscale.com/kb/1099/device-approval) or on your Headscale server (headscale preauthkeys create --user <User> --reusable --expiration 2h).\033[0m"
    [yY]) read -p "$(echo '\033[0;106m'"\033[30mEnter Tailscale/Headscale server and preauth-key:\033[0m ")" Server_Name Preauth_Key
      while : ; do
        if [ -z "$Server_Name" ]; then
          echo '\033[0;35m'"\033[1mNothing entered try again.\033[0m"
        else
          tailscale up --login-server=$Server_Name --authkey=$Preauth_Key
          break
        fi
      done;;
    [nN]) echo '\033[0;35m'"\033[1mSkipping Tailscale/Headscale setup.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Tailscale/Headscale enable device as a subnet router
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mEnable device as subnet router? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf && echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf && sysctl -p /etc/sysctl.d/99-tailscale.conf
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot enabling as subnet router.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Tailscale/Headscale advertise subnet routes
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mUpdate advertised subnet routes? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) read -p "$(echo '\033[0;106m'"\033[30mEnter new subnet/s to advertise: (e.g., 192.168.1.0/24 or 192.168.1.0/24,10.1.1.0/24)\033[0m ")" New_Subnet && 
      if [ -z "$New_Subnet" ]; then
        echo '\033[0;35m'"\033[1mNothing entered, not updating advertised subnet routes.\033[0m"
      else
        tailscale up --advertise-routes=$New_Subnet
      fi
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot updating advertised subnet routes.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
