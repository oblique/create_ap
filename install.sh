#!/bin/bash
BSSID="h0tsp0t"
WPA2PASS="supersecretpassword"
DEPS="git bash util-linux dnsmasq iptables procps hostapd iproute iw iwconig haveged"

####################################################
### create_ap installation script made by rizzo  ###
####################################################

echo "installing dependencies"
sudo apt-get install $DEPS

echo "cloning create_ap git"
git clone https://github.com/oblique/create_ap
cd create_ap
echo "installing create_ap from git clone"
sudo make install

echo "edit /etc/create_ap.conf"
sudo nano /etc/create_ap.conf

echo "making create_ap start at boot"
systemctl enable create_ap
echo "create_ap starts at boot"

#uncomment this to start create_ap with systemctl 
#echo "start create_ap now (with settings from /etc/create_ap.conf)"
#systemctl start create_ap

#uncomment this to manually start create_ap
#create_ap wlan0 eth0 $BSSID $WPA2PASS
