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
sudo make install

echo "Please enter the internet interface (eth0, wlan0 or wlxxxxxxxxxx): "
read INTER
echo "Please enter the hotspot interface  (wlan0 or wlxxxxxxxxxx): "
read APFC
echo "Please enter the BSSID network name: "
read BSSID
echo "Please enter the WPA2 Password to use: "
read WPA2PASS

#uncomment this to manually start create_ap with the $BBSID and $WPA2PASS provided at the start of this script
cd ~/create_ap
sudo create_ap $APFC $INTER $BSSID $WPA2PASS
echo ""
echo "there should now be a network called $BSSID on $APFC connected with $INTER now."
read -rsp $'Press enter to continue...\n'

echo "edit /etc/create_ap.conf to make a static config"
echo "please make sure to set the right values."
read -rsp $'Press enter to continue...\n'
sudo nano /etc/create_ap.conf

#uncomment this to make create_ap start at boot"
echo "making create_ap start at boot"
read -rsp $'Press enter to continue...\n'
sudo systemctl enable create_ap

#uncomment this to start create_ap with systemctl
echo "starting create_ap now (with settings from /etc/create_ap.conf)"
read -rsp $'Press enter to continue...\n'
sudo systemctl start create_ap
echo "if all succedded there should now be a network with the supplied config in /etc/create_ap.conf"
