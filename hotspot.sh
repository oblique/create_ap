#!/bin/bash
# Start
# Configure IP address for WLAN
        sudo ifconfig wlan0 10.10.10.1
# Start DHCP/DNS server
        sudo service dnsmasq restart
# Enable routing
        sudo sysctl net.ipv4.ip_forward=1
# Enable NAT
        sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# Run access point daemon
        sudo hostapd /etc/hostapd.conf
# Stop
# Disable NAT
        sudo iptables -D POSTROUTING -t nat -o eth0 -j MASQUERADE
# Disable routing
        sudo sysctl net.ipv4.ip_forward=0
# Disable DHCP/DNS server
        sudo service dnsmasq stop
        sudo service hostapd stop
