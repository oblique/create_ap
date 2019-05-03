#!/bin/bash
sudo apt install util-linux procps-ng hostapd iproute2 iw iwconfig haveged dnsmasq iptables -y
apt-get install build-essential dkms git linux-headers -y #linux-headers-generic
apt-get remove hostapd -y
apt-get build-dep hostapd -y
