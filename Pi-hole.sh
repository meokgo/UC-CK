#!/bin/sh
#Option to install Pi-hole
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mInstall Pi-hole? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) echo '\033[0;36m'"\033[1m$(date): Starting Pi-hole install...\033[0m"
      curl -sSL https://install.pi-hole.net | bash
      #Select: eth0
      #Fix for DNS issue
      systemctl mask systemd-resolved
      echo '\033[0;106m'"\033[30mUpdate Pi-hole Web UI password:\033[0m"
      pihole -a -p
      #Start Pi-hole FTL at boot
      cp /etc/rc.local /etc/rc.local2.bak
      if grep -Fxq "pihole-FTL" /etc/rc.local
      then
        echo '\033[0;35m'"\033[1mpihole-FTL already set to start at boot.\033[0m"
      else
        sed -i 's|^exit 0|pihole-FTL\x0A\x0Aexit 0|g' /etc/rc.local
      fi
      echo '\033[0;36m'"\033[1m$(date): Pi-hole install complete.\033[0m"
      break;;
    [nN]) echo '\033[0;35m'"\033[1mExiting...\033[0m";
      exit;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
  esac
done
#Add firewall rules for Pi-hole
apt -y install ufw
  sed -i 's|IPV6=yes|IPV6=no|g' /etc/default/ufw
  #Set UFW's default policies
    ufw default deny incoming
    ufw default allow outgoing
  #Allow access to ports from LAN and tailnet only
    SSH_PortA=$(cat /etc/ssh/sshd_config | grep "^Port" | sed 's|Port ||g')
    echo '\033[0;36m'"\033[1mAdding rule for current SSH port:\033[0m "$SSH_PortA
    #Get subnet from eth0 and pass to variable
      LAN_IP=$(ip -f inet addr show eth0 | awk '/inet / {print $2}')
    #Get subnet from tailnet and pass to variable
      TAILNET_IP=$(ip -f inet addr show tailscale0 | awk '/inet / {print $2}')
    ufw allow from $LAN_IP to any port $SSH_PortA proto tcp comment 'SSH Port from LAN'
    ufw allow from $TAILNET_IP to any port $SSH_PortA proto tcp comment 'SSH Port from tailnet'
    ufw allow from $LAN_IP to any port 80 proto tcp comment 'Pi-hole Web UI from LAN'
    ufw allow from $TAILNET_IP to any port 80 proto tcp comment 'Pi-hole Web UI from tailnet'
    ufw allow from $LAN_IP to any port 53 proto tcp comment 'Pi-hole DNS TCP from LAN'
    ufw allow from $LAN_IP to any port 53 proto udp comment 'Pi-hole DNS UDP from LAN'
    ufw allow from 127.0.0.1 to any port 4711 proto tcp comment 'Pi-hole FTL from localhost'
  ufw --force enable
  ufw status verbose
  ufw reload

#Restart FTL: systemctl restart pihole-FTL
#Start FTL: pihole-FTL
#Enable: pihole enable
#Restart DNS: pihole restartdns
#Status: pihole status
#Repair: pihole -r
#Reset Web UI password: pihole -a -p

#http://<IP>/admin

#Block lists:
  #https://firebog.net/
  #https://github.com/hagezi/dns-blocklists
