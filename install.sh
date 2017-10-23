#!/bin/bash
BSSID="h0tsp0t"
WPA2PASS="supersecretpassword"
DEPS="git build-essential bash util-linux procps hostapd iproute iw haveged  dnsmasq isc-dhcp-server net-tools iptables"

####################################################
### create_ap installation script made by rizzo  ###
####################################################

echo "installing dependencies"
sudo apt-get install $DEPS

cd ~
echo "cloning create_ap git"
git clone https://github.com/itsdarklikehell/create_ap
cd create_ap
echo "installing create_ap from git clone"
make install

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
#sudo create_ap wlan0 eth0 $BSSID $WPA2PASS

echo "if all succedded there should now be a network with the supplied config"
