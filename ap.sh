#!/bin/bash
nmcli r wifi off
rfkill unblock wlan1
killall -9 wpa_supplicant
screen -d -m -S  ap create_ap -w 2 -c 11 wlan1 eth0 Illuminati confirmed1337!
# 
echo "You now have 'Illuminati' AP setup on channel 9 with the password 'confirmed1337!' "
