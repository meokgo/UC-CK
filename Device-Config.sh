#!/bin/sh
#This script will help configure device settings on UniFi Cloud Key Model: UC-CK
#Download script: sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/Device-Config.sh
#Make script executable: sudo chmod +x Device-Config.sh
#Run script: sudo ./Device-Config.sh
(
echo "$(date): Script started." >> Device-Config.log
#Check if script is run as root
echo "$(date): Checking if script is run as root." >> Device-Config.log
if ! [ $(id -u) = 0 ]; then
  echo '\033[0;31m'"\033[1mMust run script as root.\033[0m"
  exit 1
fi
#Option to change hostname
read -p "$(echo '\033[0;106m'"\033[30mNew hostname (leave blank to keep current):\033[0m ")" New_Name
  if [ -z "$New_Name" ]; then
    echo '\033[0;35m'"\033[1mNot updating hostname.\033[0m"
  else
    hostnamectl set-hostname $New_Name --static
    sed -i "s|UniFi-CloudKey|$New_Name|g" /etc/hosts
    #sed -i "s|localhost|$New_Name|g" /etc/hosts
  fi
#Option to set static IP
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mConfigure static IP? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) echo "#*****************************
#To set static IP change DHCP to no.
#Uncomment #Address #Gateway #DNS.
#Update with static IP info.
#*****************************
[Match]
Name = eth0
[Address]
#Address = 192.168.1.100/24
[Route]
#Gateway = 192.168.1.1
[Network]
DHCP=yes
#DNS = 8.8.4.4 8.8.8.8" > /etc/systemd/network/eth0.network
      read -p "$(echo '\033[0;106m'"\033[30mStatic IP in 0.0.0.0/24 format (leave blank to keep DHCP):\033[0m ")" New_IP
        if [ -z "$New_IP" ]; then
          echo '\033[0;35m'"\033[1mNot configuring static IP, leaving as DHCP.\033[0m"
          rm /etc/systemd/network/eth0.network
        else
          sed -i "s|192.168.1.100/24|$New_IP|g" /etc/systemd/network/eth0.network
          sed -i 's|#Address|Address|g' /etc/systemd/network/eth0.network
          sed -i 's|DHCP=yes|DHCP=no|g' /etc/systemd/network/eth0.network
          read -p "$(echo '\033[0;106m'"\033[30mStatic gateway in 0.0.0.0 format (leave blank to keep DHCP):\033[0m ")" New_Gateway
            if [ -z "$New_Gateway" ]; then
              echo '\033[0;35m'"\033[1mNot configuring static IP, leaving as DHCP.\033[0m"
              rm /etc/systemd/network/eth0.network
            else
               sed -i "s|192.168.1.1|$New_Gateway|g" /etc/systemd/network/eth0.network
               sed -i 's|#Gateway|Gateway|g' /etc/systemd/network/eth0.network
               read -p "$(echo '\033[0;106m'"\033[30mStatic DNS in 0.0.0.0 format (leave blank to keep DHCP):\033[0m ")" New_DNS
                 if [ -z "$New_DNS" ]; then
                   echo '\033[0;35m'"\033[1mNot configuring static IP, leaving as DHCP.\033[0m"
                   rm /etc/systemd/network/eth0.network
                 else
                   sed -i "s|8.8.4.4|$New_DNS|g" /etc/systemd/network/eth0.network
                   sed -i 's|#DNS|DNS|g' /etc/systemd/network/eth0.network
                   systemctl restart systemd-networkd.service
                 fi
            fi
        fi
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot configuring static IP, leaving as DHCP.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Option to replace motd
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mReplace motd? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) wget -O /etc/motd https://raw.githubusercontent.com/meokgo/UC-CK/main/motd
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot replacing motd.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Option to enable automatic updates
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mEnable automatic updates and reboots? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) apt -y install unattended-upgrades
      DEBIAN_FRONTEND=noninteractive dpkg-reconfigure --priority=low unattended-upgrades
      sed -i 's|//Unattended-Upgrade::Automatic-Reboot "false";|Unattended-Upgrade::Automatic-Reboot "true";|g' /etc/apt/apt.conf.d/50unattended-upgrades
      systemctl start unattended-upgrades
      systemctl enable unattended-upgrades
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot enabling automatic updates and reboots.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Update root and ubnt user passwords, option to add user
echo '\033[0;106m'"\033[30mUpdate root user password:\033[0m"
passwd root
passwd ubnt
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mAdd new sudo user? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) read -p "$(echo '\033[0;106m'"\033[30mEnter new user name:\033[0m ")" New_User && 
      if [ -z "$New_User" ]; then
        echo '\033[0;35m'"\033[1mNothing entered, not adding new sudo user.\033[0m"
      else
        adduser $New_User
        usermod -aG sudo $New_User
        echo '\033[0;36m'"\033[1m$New_User added to sudo group.\033[0m"
      fi
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot adding new sudo user.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Option to harden SSH
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mHarden SSH settings? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) sed -i 's|LoginGraceTime 120|LoginGraceTime 2m|g' /etc/ssh/sshd_config
      sed -i 's|PermitRootLogin yes|PermitRootLogin no|g' /etc/ssh/sshd_config
      echo "MaxAuthTries 5" >> /etc/ssh/sshd_config
      echo "MaxSessions 1" >> /etc/ssh/sshd_config
      echo "AddressFamily inet" >> /etc/ssh/sshd_config
      read -p "$(echo '\033[0;106m'"\033[30mEnter new SSH port:\033[0m ")" New_Port
      if [ -z "$New_Port" ]; then
        echo '\033[0;35m'"\033[1mNothing entered, SSH port: 22.\033[0m"
      else
        sed -i "s|Port 22|Port $New_Port|g" /etc/ssh/sshd_config
      fi
      /etc/init.d/ssh restart
      echo '\033[0;36m'"\033[1mSSH settings updated.\033[0m"
      echo '\033[0;36m'"\033[1mInstalling ufw and creating firewall rule for SSH...\033[0m"
      apt -y install ufw
      sed -i 's|IPV6=yes|IPV6=no|g' /etc/default/ufw
      SSH_Port=$(cat /etc/ssh/sshd_config | grep Port | sed 's|Port ||g')
      echo '\033[0;36m'"\033[1mCurrent SSH port:\033[0m "$SSH_Port
      ufw allow $SSH_Port/tcp comment 'SSH Port'
      ufw enable
      ufw status verbose
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot hardening SSH settings.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Option to change timezone, default is PDT
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mUpdate timezone? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) dpkg-reconfigure tzdata
      clear
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot updating timezone.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
echo "$(date): Script finished" >> Device-Config.log
) 2>&1 | tee -a 1-Combined-Upgrade.log
