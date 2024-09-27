Upgrade from Jessie to Buster:
  Factory reset Cloud Key:
    Use web browser go to IP (fallback IP: 192.168.1.30) of Cloud Key - Maintenance - RESET TO DEFAULTS
    Or use PuTTY to SSH to IP of Cloud Key:
      ```Shell
      sudo ubnt-systool reset2defaults
      ```
    Or reset from Emergency Recovery UI:
      Power off device
        Hold down reset button then power on device
        Keep reset button held for about 10 seconds, until you see recovery LED pattern (blue - off - white)
        Use web browser go to IP (fallback IP: 192.168.1.30) of Cloud Key
        Click on RESET TO FACTORY DEFAULTS then reboot
  Use web browser go to IP of Cloud Key:
    Click on CONFIGURE
    Enter "ubnt" for username and password
    Change login password
    Configuration - edit Device Name and Timezone
    APPLY CHANGES
  Use PuTTY to SSH to IP of Cloud Key:
    Username is "ubnt", password was set in previous step
    sudo rm /etc/apt/sources.list /etc/apt/sources.list.d/nodejs.list /etc/apt/sources.list.d/security.list /etc/apt/sources.list.d/ubnt-unifi.list && sudo apt-get -y --purge autoremove unifi freeradius
  Create new file /etc/apt/sources.list:
    sudo echo "deb https://deb.debian.org/debian buster main contrib non-free
deb-src https://deb.debian.org/debian buster main contrib non-free
deb https://deb.debian.org/debian-security/ buster/updates main contrib non-free
deb-src https://deb.debian.org/debian-security/ buster/updates main contrib non-free
deb https://deb.debian.org/debian buster-updates main contrib non-free
deb-src https://deb.debian.org/debian buster-updates main contrib non-free" > /etc/apt/sources.list
  Upgrade to Buster:
    sudo apt update && sudo apt -y --force-yes --reinstall install debian-archive-keyring && sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt -y install nano && sudo apt-get -y clean && sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" && echo $(date)":" "Rebooting in 5 seconds..." && sleep 5 && sudo reboot
  Install optional updates:
    sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt -y full-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" && sudo apt -y autoremove && echo $(date)":" "Rebooting in 5 seconds..." && sleep 5 && sudo reboot
