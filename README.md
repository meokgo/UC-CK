<!--
  Title: UC-CK
  Description: Scripts, fixes, updates, etc. to help repurpose UC-CK as a general SBC running Debian Bullseye.
  Author: meokgo
  -->

# UC-CK
UniFi Cloud Key Model: UC-CK

Gen1 version of Cloud Key

Scripts, fixes, updates, etc. to help repurpose UC-CK as a general SBC running Debian Bullseye
<br/>
<br/>
<br/>
Download and run combined upgrade script:
```Shell
sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/1-Combined-Upgrade.sh && sudo chmod +x 1-Combined-Upgrade.sh && sudo ./1-Combined-Upgrade.sh
```
Download and run device configuration script:
```shell
sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/2-Device-Config.sh && sudo chmod +x 2-Device-Config.sh && sudo ./2-Device-Config.sh
```
Download and run script to install tools:
```shell
sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/3-Install-Tools.sh && sudo chmod +x 3-Install-Tools.sh && sudo ./3-Install-Tools.sh
```
