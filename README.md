# Create_ap MANA 
Script has been modified to run [hostapd-mana](https://github.com/sensepost/hostapd-mana) with multiple options

## Setup
This script requires hostapd-mana to be in the path.

This may be done by adding the binary to your path directly:
```
export PATH="$PATH:/path/to/hostapd-mana"
```
To make this permanent you may add to your shells .rc file

or you may link hostapd-mana into a directory that is within your path
```
cd /usr/bin
sudo ln -s /path/to/hostapd-mana hostapd-mana
```

## Attacks

Run Mana to trick users into connecting to your access point. The eap users file is not passed so that the default mana eap user file is used: 

    create_ap --eap --mana wlan0 eth0 MyAccessPoint 

Run Mana in loud mode to show devices every access point seen by Mana:

    create_ap --eap --mana --mana-loud wlan0 eth0 MyAccessPoint 

Run Mana and bridge the network connection to your ethernet address: 

    create_ap --eap --mana -m bridge wlan0 eth0 MyAccessPoint 

Run Mana and be stingy by not providing any upstream Internet access:

    create_ap --eap --mana -n wlan0 eth0 MyAccessPoint  

## Features
* Create an AP (Access Point) at any channel.
* Choose one of the following encryptions: WPA, WPA2, WPA/WPA2, Open (no encryption).
* Support for Enterprise setups
* Hide your SSID.
* Disable communication between clients (client isolation).
* IEEE 802.11n & 802.11ac support
* Internet sharing methods: NATed or Bridged or None (no Internet sharing).
* Choose the AP Gateway IP (only for 'NATed' and 'None' Internet sharing methods).
* You can create an AP with the same interface you are getting your Internet connection.
* You can pass your SSID and password through pipe or through arguments (see examples).


## Dependencies
### General
* bash (to run this script)
* util-linux (for getopt)
* procps or procps-ng
* hostapd
* iproute2
* iw
* iwconfig (you only need this if 'iw' can not recognize your adapter)
* haveged (optional)

### For 'NATed' or 'None' Internet sharing method
* dnsmasq
* iptables


## Installation
### Generic
    git clone https://github.com/oblique/create_ap
    cd create_ap
    make install

### ArchLinux
    pacman -S create_ap

### Gentoo
    emerge layman
    layman -f -a jorgicio
    emerge net-wireless/create_ap

## Examples
### No passphrase (open network):
    create_ap wlan0 eth0 MyAccessPoint

### WPA + WPA2 passphrase:
    create_ap wlan0 eth0 MyAccessPoint MyPassPhrase

### AP without Internet sharing:
    create_ap -n wlan0 MyAccessPoint MyPassPhrase

### Bridged Internet sharing:
    create_ap -m bridge wlan0 eth0 MyAccessPoint MyPassPhrase

### Bridged Internet sharing (pre-configured bridge interface):
    create_ap -m bridge wlan0 br0 MyAccessPoint MyPassPhrase

### Internet sharing from the same WiFi interface:
    create_ap wlan0 wlan0 MyAccessPoint MyPassPhrase

### Choose a different WiFi adapter driver
    create_ap --driver rtl871xdrv wlan0 eth0 MyAccessPoint MyPassPhrase

### No passphrase (open network) using pipe:
    echo -e "MyAccessPoint" | create_ap wlan0 eth0

### WPA + WPA2 passphrase using pipe:
    echo -e "MyAccessPoint\nMyPassPhrase" | create_ap wlan0 eth0

### Enable IEEE 802.11n
    create_ap --ieee80211n --ht_capab '[HT40+]' wlan0 eth0 MyAccessPoint MyPassPhrase

### Client Isolation:
    create_ap --isolate-clients wlan0 eth0 MyAccessPoint MyPassPhrase

### Enterprise Network built-in RADIUS
    create_ap --eap --eap-user-file /tmp/users.eap_hosts --eap-cert-path /tmp/certificates wlan0 eth0 MyAccessPoint 

### Enterprise Network Remote RADIUS
    create_ap --eap --radius-server 192.168.1.1:1812 --radius-secret=P@ssw0rd wlan0 eth0 MyAccessPoint

## Systemd service
Using the persistent [systemd](https://wiki.archlinux.org/index.php/systemd#Basic_systemctl_usage) service
### Start service immediately:
    systemctl start create_ap

### Start on boot:
    systemctl enable create_ap


## License
FreeBSD
