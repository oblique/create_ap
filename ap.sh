#!/bin/bash
nmcli r wifi off
rfkill unblock wlan
killall -9 wpa_supplicant
screen -dmS  ap create_ap -w 2 -c 9 wlan1 eth0 Illuminati confirmed1337! && screen -x ap
#
echo "You now have 'Illuminati' AP setup on channel 9 with the password 'confirmed1337!' "
