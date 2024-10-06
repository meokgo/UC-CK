# UC-CK
UniFi Cloud Key Model: UC-CK

Gen1 version of Cloud Key

Scripts, fixes, updates, etc. to help repurpose UC-CK as a general SBC running Debian
<br/>
<br/>
<br/>
Download and run script to upgrade to Buster:
```Shell
sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/1-Upgrade-To-Buster.sh && sudo chmod +x 1-Upgrade-To-Buster.sh && sudo ./1-Upgrade-To-Buster.sh
```
Download and run script to upgrade to Bullseye (must run 1-Upgrade-To-Buster.sh first):
```shell
sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/2-Upgrade-To-Bullseye.sh && sudo chmod +x 2-Upgrade-To-Bullseye.sh && sudo ./2-Upgrade-To-Bullseye.sh
```
Download and run script to install useful tools:
```shell
sudo wget https://raw.githubusercontent.com/meokgo/UC-CK/main/Install-Tools.sh && sudo chmod +x Install-Tools.sh && sudo ./Install-Tools.sh
```
