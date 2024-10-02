#!/bin/sh
#This script will install some useful tools
#Download script: sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/Install-Tools.sh
#Make script executable: sudo chmod +x Install-Tools.sh
#Run script: sudo ./Install-Tools.sh
#Start time
echo "$(date) - Script started" >> Install-Tools.log
(
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
apt update && apt -y install fzf tldr cmatrix iperf3 speedtest-cli stress s-tui nnn ncdu links2 telnet 7zip tailscale
#!/bin/sh
#Option for Tailscale/Headscale initial setup
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mRun Tailscale/Headscale initial setup? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) echo '\033[0;36m'"\033[1mCreate a preauth-key in Tailscale or on your Headscale server.\033[0m"
    read -p "$(echo '\033[0;106m'"\033[30mEnter Tailscale/Headscale server:\033[0m ")" Server_Name
    read -p "$(echo '\033[0;106m'"\033[30mEnter Tailscale/Headscale preauth-key:\033[0m ")" Preauth_Key
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
  read -p "$(echo '\033[0;106m'"\033[30mUpdate Tailscale/Headscale advertised subnet routes? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) read -p "$(echo '\033[0;106m'"\033[30mEnter new subnet/s to advertise:\033[0m ")" New_Subnet
      if [ -z "$New_Subnet" ]; then
        echo '\033[0;35m'"\033[1mNothing entered, not updating Tailscale/Headscale advertised subnet routes.\033[0m"
      else
        tailscale set --advertise-routes=$New_Subnet
      fi
      break;;
    [nN]) echo '\033[0;35m'"\033[1mNot updating Tailscale/Headscale advertised subnet routes.\033[0m"
      break;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";;
  esac
done
#End time
echo "$(date) - Script finished" >> Install-Tools.log
) 2>&1 | tee -a Install-Tools.log
