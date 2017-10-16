#!/bin/bash
BSSID="h0tsp0t"
WPA2PASS="supersecretpassword"
DEPS="git bash util-linux dnsmasq isc-dhcp-server net-tools iptables procps hostapd iproute iw haveged"

####################################################
### create_ap installation script made by rizzo  ###
####################################################

echo "installing dependencies"
sudo apt-get install $DEPS

echo "cloning create_ap git"
git clone https://github.com/itsdarklikehell/create_ap
cd create_ap
echo "installing create_ap from git clone"
sudo make install

echo "edit /etc/create_ap.conf"
echo "make sure to set the right values"
sudo nano /etc/create_ap.conf

#uncomment this to make create_ap start at boot"
#echo "making create_ap start at boot"
systemctl enable create_ap

#uncomment this to start create_ap with systemctl 
#echo "start create_ap now (with settings from /etc/create_ap.conf)"
systemctl start create_ap

#uncomment this to manually start create_ap with the $BBSID and $WPA2PASS provided at the start of this script
create_ap wlan0 eth0 $BSSID $WPA2PASS
