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
