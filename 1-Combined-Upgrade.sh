#!/bin/sh
#This script will upgrade the factory default state OS from Debian Jessie to Debian Buster or Debian Buster to Debian Bullseye on UniFi Cloud Key Model: UC-CK
#This script will disabe or remove most UniFi packages, the device will no longer function as a Cloud Key for UniFi devices, but Emergency Recovery UI still works.
#****It is highly recommended to factory reset the Cloud Key before running script the first time****
#Factory reset Cloud Key: sudo ubnt-systool reset2defaults
#Default SSH user: root
#Default SSH password: ubnt
#Download script: sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/1-Combined-Upgrade.sh
#Make script executable: sudo chmod +x 1-Combined-Upgrade.sh
#Run script: sudo ./1-Combined-Upgrade.sh

remove_packages ()
{
  echo '\033[0;36m'"\033[1m$(date): Removing packages...\033[0m"
  echo "Killing all processes owned by unifi user." >> 1-Combined-Upgrade.log
    killall -v -u unifi
  DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove ubnt-archive-keyring ubnt-crash-report ubnt-unifi-setup bt-proxy cloudkey-webui firmware-Atheros ubnt-systemhub unifi libcups2 libxml2 rfkill bluez nginx nginx-light nginx-common x11-common libx11-6 freeradius freeradius-common freeradius-utils libfreeradius2 libjpeg62-turbo:armhf libpng12-0:armhf libx11-data ubnt-mtk-initramfs cloudkey-mtk7623-base-files -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  userdel -rf unifi
  #Fix for dpkg hook error
  echo '\033[0;36m'"\033[1mFix for dpkg hook error...\033[0m"
  touch /sbin/ubnt-dpkg-status-pre /sbin/ubnt-dpkg-status-post /sbin/ubnt-dpkg-cache
  chmod +x /sbin/ubnt-dpkg-status-pre /sbin/ubnt-dpkg-status-post /sbin/ubnt-dpkg-cache
  #Remove directories
  echo '\033[0;36m'"\033[1mRemoving unnecessary directories...\033[0m"
  rm -r /var/www/html /etc/bt-proxy /etc/freeradius
  echo '\033[0;36m'"\033[1m$(date): Removal complete.\033[0m"
}
initial_upgrade ()
{
  apt update
  DEBIAN_FRONTEND=noninteractive apt -y upgrade --without-new-pkgs -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo '\033[0;36m'"\033[1m$(date): Initial upgrade complete.\033[0m"
}
full_upgrade ()
{
  apt update
  DEBIAN_FRONTEND=noninteractive apt -y full-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo '\033[0;36m'"\033[1m$(date): Full upgrade complete.\033[0m"
}
(
#Set timezone to CST, default is PDT
echo '\033[0;36m'"\033[1m$(date): Setting timezone to CST...\033[0m"
timedatectl set-timezone America/Chicago
echo "$(date): Script started." >> 1-Combined-Upgrade.log
#Check if script is run as root
echo '\033[0;36m'"\033[1mChecking if script is run as root...\033[0m"
if ! [ $(id -u) = 0 ]; then
  echo '\033[0;31m'"\033[1mMust run script as root.\033[0m"
  exit 1
fi
#Check for valid kernel version
echo '\033[0;36m'"\033[1m$(date): Checking kernel version...\033[0m"
Kernel_Version=$(uname -r)
echo '\033[0;36m'"\033[1mKernel version: $Kernel_Version\033[0m"
case $Kernel_Version in
  3.10.20-ubnt-mtk ) echo '\033[0;36m'"\033[1mValid kernel.\033[0m";;
  * ) echo '\033[0;31m'"\033[1mInvalid kernel. Script only works on kernel 3.10.20-ubnt-mtk.\033[0m"
    exit 1;;
esac
#Check OS version
echo '\033[0;36m'"\033[1m$(date): Checking OS version...\033[0m"
  OS_Version=$(lsb_release -a | grep Codename)
  echo '\033[0;36m'"\033[1mCurrent OS $OS_Version\033[0m"
  case $OS_Version in
    *"jessie") echo '\033[0;36m'"\033[1mValid OS.\033[0m"
      while : ; do
        read -p "$(echo '\033[0;106m'"\033[30mUpgrade Cloud Key OS to Buster? (y/n)\033[0m ")" yn
        case $yn in
          [yY]) echo '\033[0;36m'"\033[1mProceeding with Buster upgrade.\033[0m"
            break;;
          [nN]) echo '\033[0;35m'"\033[1mStopping upgrade...\033[0m";
            exit;;
          *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
        esac
      done
      remove_packages
      #Start Buster OS upgrade
      echo '\033[0;36m'"\033[1mDeleting old source lists...\033[0m"
        rm /etc/apt/sources.list /etc/apt/sources.list.d/nodejs.list /etc/apt/sources.list.d/security.list /etc/apt/sources.list.d/ubnt-unifi.list
      echo '\033[0;36m'"\033[1mCreating new source list...\033[0m"
        echo "deb https://deb.debian.org/debian buster main contrib non-free
deb-src https://deb.debian.org/debian buster main contrib non-free
deb https://deb.debian.org/debian-security/ buster/updates main contrib non-free
deb-src https://deb.debian.org/debian-security/ buster/updates main contrib non-free
deb https://deb.debian.org/debian buster-updates main contrib non-free
deb-src https://deb.debian.org/debian buster-updates main contrib non-free" > /etc/apt/sources.list
      echo '\033[0;36m'"\033[1m$(date): Updating Debian keyring...\033[0m"
        apt update
        apt -y --force-yes --reinstall install debian-archive-keyring
      echo '\033[0;36m'"\033[1m$(date): Initial upgrade to Buster...\033[0m"
        apt-get -y clean
        initial_upgrade
      echo '\033[0;36m'"\033[1m$(date): Installing full Buster upgrade...\033[0m"
        full_upgrade
      #Fix network settings
      echo '\033[0;36m'"\033[1m$(date): Fixing network settings...\033[0m"
        update-alternatives --set iptables /usr/sbin/iptables-legacy
        #Fix DNS and free up port 53
        echo '\033[0;36m'"\033[1mFix DNS and free up port 53...\033[0m"
        cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak
        rm /etc/systemd/resolved.conf
          echo "[Resolve]
DNS=1.1.1.1
FallbackDNS=8.8.8.8 8.8.4.4
#Domains=
#LLMNR=no
#MulticastDNS=no
#DNSSEC=no
#DNSOverTLS=no
#Cache=no
DNSStubListener=no
#ReadEtcHosts=yes" > /etc/systemd/resolved.conf
          ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
          service systemd-resolved restart
      #Fix for dpkg unknown system group error
      echo '\033[0;36m'"\033[1m$(date): Fix dpkg unkown system group error...\033[0m"
      rm /var/lib/dpkg/statoverride
      rm /var/lib/dpkg/lock
      dpkg --configure -a
      apt-get -f install
      remove_packages
      echo '\033[0;35m'"\033[1mTo continue upgrading to Bullseye, reboot the device then re-run script (sudo ./1-Combined-Upgrade.sh):\033[0m"
      ;;
    *"buster") echo '\033[0;36m'"\033[1mValid OS.\033[0m"
      while : ; do
        read -p "$(echo '\033[0;106m'"\033[30mUpgrade Cloud Key OS to Bullseye? (y/n)\033[0m ")" yn
        case $yn in
          [yY]) echo '\033[0;36m'"\033[1m$(date): Proceeding with Bullseye upgrade.\033[0m"
            break;;
          [nN]) echo '\033[0;35m'"\033[1mStopping upgrade...\033[0m";
            exit;;
          *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
        esac
      done
      #Start Bullseye OS upgrade
      echo '\033[0;36m'"\033[1mDeleting old source list...\033[0m"
        rm /etc/apt/sources.list
      echo '\033[0;36m'"\033[1mCreating new source list...\033[0m"
        echo "deb https://deb.debian.org/debian bullseye main contrib non-free
deb-src https://deb.debian.org/debian bullseye main contrib non-free
deb https://security.debian.org/debian-security bullseye-security main contrib non-free
deb-src https://security.debian.org/debian-security/ bullseye-security main contrib non-free
deb https://deb.debian.org/debian bullseye-updates main contrib non-free
deb-src https://deb.debian.org/debian bullseye-updates main contrib non-free
deb https://deb.debian.org/debian bullseye-backports main contrib non-free
deb-src https://deb.debian.org/debian bullseye-backports main contrib non-free" > /etc/apt/sources.list
      echo '\033[0;36m'"\033[1m$(date): Initial upgrade to Bullseye...\033[0m"
        initial_upgrade
      echo '\033[0;36m'"\033[1m$(date): Installing full Bullseye upgrade...\033[0m"
        full_upgrade
      #Remove unnecessary packages
      DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove cpp-8 fdisk libapt-inst2.0 libapt-pkg5.0 libasan5 libevent-2.1-6 libfdisk1 libhogweed4 libicu63 libip4tc0 libip6tc0 libiptc0 libisl19 libjson-c3 libnettle6 libnftables0 libperl5.28 libprocps7 libpython2-stdlib libpython3.7-minimal libpython3.7-stdlib libreadline7 perl-modules-5.28 python2 python2-minimal python3.7-minimal usb.ids exim4-config exim4-base exim4-daemon-light -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
      remove_packages
      DEBIAN_FRONTEND=noninteractive apt-get -y purge ~c -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
      DEBIAN_FRONTEND=noninteractive apt-get -y clean ~c -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
      #Update NTP servers
      echo '\033[0;36m'"\033[1m$(date): Updating NTP servers...\033[0m"
        sed -i "s|0.ubnt.pool.ntp.org ||g" /etc/systemd/timesyncd.conf
        systemctl restart systemd-timesyncd
        timedatectl
      #Set LED to blue after finished booting
      echo '\033[0;36m'"\033[1m$(date): Updating LED settings...\033[0m"
      cp /etc/rc.local /etc/rc.local.bak
      echo '
echo rfkill0 > /sys/class/leds/blue/trigger
echo none > /sys/class/leds/white/trigger

exit 0' >> /etc/rc.local
      #Move storage using symlink
      echo '\033[0;36m'"\033[1m$(date): Moving cache and temp storage using symlink...\033[0m"
      mkdir -p /srv/var/lib
      mv /var/cache /srv/var/cache
      ln -s /srv/var/cache /var/cache
      mv /var/log /srv/var/log
      ln -s /srv/var/log /var/log
      mv /var/lib/apt /srv/var/lib/apt
      ln -s /srv/var/lib/apt /var/lib/apt
      mv /var/lib/dpkg /srv/var/lib/dpkg
      ln -s /srv/var/lib/dpkg /var/lib/dpkg
      #Update motd
      echo '\033[0;36m'"\033[1m$(date): Updating motd...\033[0m"
      wget -O /etc/motd https://raw.githubusercontent.com/meokgo/UC-CK/main/motd
        echo '#!/bin/sh
cat /etc/motd
' > /etc/update-motd.d/10-motd
        mv /etc/update-motd.d/10-uname /etc/update-motd.d/20-uname
        sed -i 's|uname -snrvm|uname -nmo|g' /etc/update-motd.d/20-uname
        echo '#!/bin/sh
echo "Date: " $(date)
echo "Logged in users: " $(who)
echo "Uptime: " $(uptime -p)
ip -c -f inet addr show eth0 | awk '\''/inet / {print "eth0 IP: " $2}'\''
ip -c -f inet addr show tailscale0 | awk '\''/inet / {print "tailnet IP: " $2}'\''' > /etc/update-motd.d/30-stats
        chmod +x /etc/update-motd.d/10-motd /etc/update-motd.d/30-stats
        sed -i 's|^session    optional     pam_motd.so noupdate|#session    optional     pam_motd.so noupdate|g' /etc/pam.d/sshd
        #Display motd
        run-parts /etc/update-motd.d
        #Update color settings from 8 to 256
        echo '\033[0;36m'"\033[1m$(date): Update color settings from 8 to 256...\033[0m"
        sudo echo "
TERM=xterm-256color" >> /etc/bash.bashrc
      #Option to run 2-Device-Config.sh
      while : ; do
        read -p "$(echo '\033[0;106m'"\033[30mRun Device-Config (set static IP, hostname, harden SSH, etc.)? (y/n)\033[0m ")" yn
        case $yn in
          [yY]) sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/2-Device-Config.sh && sudo chmod +x 2-Device-Config.sh && sudo ./2-Device-Config.sh
            break;;
          [nN]) echo '\033[0;35m'"\033[1mNot running config.\033[0m";
            break;;
          *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
        esac
      done
      #Option to install tools using 3-Install-Tools.sh
      while : ; do
        read -p "$(echo '\033[0;106m'"\033[30mInstall tools? (y/n)\033[0m ")" yn
        case $yn in
          [yY]) sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/3-Install-Tools.sh && sudo chmod +x 3-Install-Tools.sh && sudo ./3-Install-Tools.sh
            break;;
          [nN]) echo '\033[0;35m'"\033[1mNot installing tools.\033[0m";
            break;;
          *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
        esac
      done
      ;;
    *) echo '\033[0;31m'"\033[1mInvalid OS. Script only upgrades OS from Jessie (Debian 8) to Buster (Debian 10) or from Buster (Debian 10) to Bullseye (Debian 11).\033[0m";
      exit 1;;
  esac
echo "$(date): Script finished" >> 1-Combined-Upgrade.log
) 2>&1 | tee -a 1-Combined-Upgrade.log
#Option to reboot device
while : ; do
  read -p "$(echo '\033[0;106m'"\033[30mDevice must be rebooted. Reboot now? (y/n)\033[0m ")" yn
  case $yn in
    [yY]) echo '\033[0;32m'"\033[1m$(date): Rebooting in 5 seconds...\033[0m"
      sleep 5
      reboot
      break;;
    [nN]) echo '\033[0;35m'"\033[1mExiting...\033[0m";
      exit;;
    *) echo '\033[0;31m'"\033[1mInvalid response.\033[0m";
  esac
done
