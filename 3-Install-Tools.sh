#!/bin/sh
#This script will install some useful tools
#Download script: sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/3-Install-Tools.sh
#Make script executable: sudo chmod +x 3-Install-Tools.sh
#Run script: sudo ./3-Install-Tools.sh

#Function to download tmux session config and btop config for users
setup_users ()
{
  while : ; do
    #Continue setting up users?
    read -p "$(echo '\n\033[0;106m'"\033[30mSetup tmux session config for user? (y/n)\033[0m ")" yn
    case $yn in
      [yY]) unset Tmux_User
        read -p "$(echo '\n\033[0;106m'"\033[30mEnter user name to setup tmux session config:\033[0m ")" Tmux_User
        if [ -z "$Tmux_User" ]; then
          echo '\033[0;35m'"\033[1mNothing entered.\033[0m"
        else
          #Check if $Tmux_User exists in system
          if id -u $Tmux_User >/dev/null 2>&1; then
            #Download tmux config file for $Tmux_User
            if grep -Fxq "#Disable idle log out for tmux" /home/$Tmux_User/.tmux.conf
            then
              echo '\033[0;35m'"\033[1mtmux config file already exists for $Tmux_User.\033[0m"
            else 
              wget -O /home/$Tmux_User/.tmux.conf https://raw.githubusercontent.com/meokgo/UC-CK/main/.tmux.conf
            fi
            #Download btop config file for $Tmux_User
            if grep -Fxq "#Updated meokgo" /home/$Tmux_User/.config/btop/btop.conf
            then
              echo '\033[0;35m'"\033[1mbtop config file already exists for $Tmux_User.\033[0m"
            else
            wget -O /home/$Tmux_User/.config/btop/btop.conf https://raw.githubusercontent.com/meokgo/UC-CK/main/btop.conf
            #Create user alias for tldr update
            echo "
#User alias for tldr update
alias tldr-u='cd /home/$USER/.local/share/tldr/tldr && git pull origin main && cd -'" >> /home/$Tmux_User/.bashrc
            #Create user alias for Metasploit
            echo "
#User alias for Metasploit
alias metasploit='msfconsole'" >> /home/$Tmux_User/.bashrc
            #Update tldr for $Tmux_User
            cd /home/$Tmux_User/.local/share/tldr/tldr && git pull origin main && cd -
            fi
          else
            echo '\033[0;31m'"\033[1m$Tmux_User does not exist in system.\033[0m"
          fi
        fi;;
      [nN]) echo '\n\033[0;35m'"\033[1mDone setting up tmux session configs or users.\033[0m"
        break;;
      *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
    esac
  done
}
echo "$(date) - Script started" >> 3-Install-Tools.log
(
#Check if script is run as root
echo '\033[0;36m'"\033[1mChecking if script is run as root...\033[0m"
if ! [ $(id -u) = 0 ]; then
  echo '\033[0;31m'"\033[1mMust run script as root.\033[0m"
  exit 1
fi
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mInstall tools? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) echo '\n\033[0;36m'"\033[1m$(date): Starting install...\033[0m"
      break;;
    [nN]) echo '\033[0;35m'"\033[1mExiting...\033[0m";
      exit;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
  esac
done
#Add tailscale to repository
curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
#Install tools
apt update
DEBIAN_FRONTEND=noninteractive apt -y install nano fzf tldr cmatrix iperf3 speedtest-cli stress s-tui ncdu telnet tailscale tmux btop mc nmap -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
#Install Metasploit
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall
./msfinstall
msfdb init
#Move Metasploit data with symlink
mkdir -p /srv/opt
mv /opt/metasploit-framework /srv/opt
ln -s /srv/opt/metasploit-framework /opt/metasploit-framework
#Create global alias for Metasploit
echo "
#Global alias for Metasploit
alias metasploit='msfconsole'" >> /etc/profile.d/00-alias.sh
echo "
#Global alias for Metasploit
alias metasploit='msfconsole'" >> /etc/bash.bashrc
#Create root user alias for Metasploit
echo "
#User alias for Metasploit
alias metasploit='msfconsole'" >> /root/.bashrc
#Create global alias for tldr update
echo "
#Global alias for tldr update
alias tldr-u='cd /home/$USER/.local/share/tldr/tldr && git pull origin main && cd -'" >> /etc/profile.d/00-alias.sh
echo "
#Global alias for tldr update
alias tldr-u='cd /home/$USER/.local/share/tldr/tldr && git pull origin main && cd -'" >> /etc/bash.bashrc
#Create root user alias for tldr update
echo "
#root user alias for tldr update
alias tldr-u='cd /root/.local/share/tldr/tldr && git pull origin main && cd -'" >> /root/.bashrc
#Update tldr for root user
tldr -u
#Move /root/.local/share directory using symlink
echo '\033[0;36m'"\033[1m$(date): Moving /root/.local/share directory using symlink...\033[0m"
  mkdir -p /root/.local/share
  mkdir -p /srv/root/.local
  mv /root/.local/share /srv/root/.local/share
  ln -s /srv/root/.local/share /root/.local/share
#Download tmux config file for root user
wget -O /root/.tmux.conf https://raw.githubusercontent.com/meokgo/UC-CK/main/.tmux.conf
#Download btop config file for root user
wget -O /root/.config/btop/btop.conf https://raw.githubusercontent.com/meokgo/UC-CK/main/btop.conf
setup_users
#Option for Tailscale/Headscale initial setup
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mRun Tailscale/Headscale initial setup? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) echo '\n\033[0;36m'"\033[1mCreate a preauth-key in Tailscale or on your Headscale server.\033[0m"
    read -p "$(echo '\033[0;106m'"\033[30mEnter Tailscale/Headscale server:\033[0m ")" Server_Name
    read -p "$(echo '\n\033[0;106m'"\033[30mEnter Tailscale/Headscale preauth-key:\033[0m ")" Preauth_Key
      if test -z "$Server_Name" || test -z "$Preauth_Key" ; then
        echo '\033[0;35m'"\033[1mServer or preauth-key not entered, not running Tailscale/Headscale initial setup.\033[0m"
      else
        tailscale up --login-server=$Server_Name --authkey=$Preauth_Key
        tailscale status --peers=false
      fi
      break;;
    [nN]) echo '\033[0;35m'"\033[1mSkipping Tailscale/Headscale initial setup.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Option to enable access to advertised routes on other Tailscale/Headscale devices
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mEnable access to advertised routes on other Tailscale/Headscale devices? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) tailscale set --accept-routes
    tailscale debug prefs | grep RouteAll
    echo '\033[0;36m'"\033[1mAccess is enabled\033[0m"
      break;;
    [nN]) echo '\033[0;35m'"\033[1mDisabling access to advertised routes on other Tailscale/Headscale devices.\033[0m"
    tailscale set --accept-routes=false
    tailscale debug prefs | grep RouteAll
    echo '\033[0;36m'"\033[1mAccess is disabled\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Option to enable device as a Tailscale/Headscale subnet router
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mEnable device as Tailscale/Headscale subnet router? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf && echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf && sysctl -p /etc/sysctl.d/99-tailscale.conf
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot enabling as Tailscale/Headscale subnet router.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#Option to update Tailscale/Headscale advertised subnet routes
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mUpdate Tailscale/Headscale advertised subnet router on this device? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) read -p "$(echo '\n\033[0;106m'"\033[30mEnter new subnet/s to advertise (in 0.0.0.0/24 format):\033[0m ")" New_Subnet
      if [ -z "$New_Subnet" ]; then
        echo '\033[0;35m'"\033[1mNothing entered, not updating Tailscale/Headscale advertised subnet routes.\033[0m"
      else
        tailscale set --advertise-routes=$New_Subnet
        echo '\n\033[0;36m'"\033[1mRemember to enable advertised subnet routes from the server.\033[0m"
      fi
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot updating Tailscale/Headscale advertised subnet routes.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
echo "$(date) - Script finished" >> 3-Install-Tools.log
) 2>&1 | tee -a 3-Install-Tools.log
