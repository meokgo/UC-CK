#This script will upgrade OS from Jessie to Buster on UniFi Cloud Key Model: UC-CK
#To make script executable: chmod +x 1-Upgrade-To-Buster.sh
#Run script: ./1-Upgrade-To-Buster.sh
echo "****Deleting old source lists****"
  sudo rm /etc/apt/sources.list /etc/apt/sources.list.d/nodejs.list /etc/apt/sources.list.d/security.list /etc/apt/sources.list.d/ubnt-unifi.list
echo "****Uninstalling freeradius package****"
  sudo apt-get -y --purge autoremove unifi freeradius
echo "****Creating new source list****"
  touch /etc/apt/sources.list
  sudo echo "deb https://deb.debian.org/debian buster main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo echo "deb-src https://deb.debian.org/debian buster main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo echo "deb https://deb.debian.org/debian-security/ buster/updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo echo "deb-src https://deb.debian.org/debian-security/ buster/updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo echo "deb https://deb.debian.org/debian buster-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
  sudo echo "deb-src https://deb.debian.org/debian buster-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list
echo "****Updating repository package list****"
  sudo apt update
echo "****Updating Debian keyring****"
  sudo apt -y --force-yes --reinstall install debian-archive-keyring
echo "****Install nano****"
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt -y install nano
echo "****Initial upgrade to Buster****"
  sudo apt-get -y clean
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo $(date)":" "Initial upgrade complete"
  sleep 2
echo "****Install full Buster upgrade****"
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt -y full-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  sudo apt -y autoremove
  echo $(date)":" "Full upgrade complete"
echo $(date)":" "Rebooting in 5 seconds..."
  sleep 5
  sudo reboot
