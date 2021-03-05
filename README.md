## NOT MAINTAINED

This project is no longer maintained.


## Forks and continuation of this project

* [linux-wifi-hotspot] - Fork that is focused on providing GUI and improvements.
* [linux-router] - Fork that is focused on providing new features and
    improvements which are not limited to WiFi. Some interesting features are:
    sharing Internet to a wired interface and sharing Internet via a transparent
    proxy using redsocks.


## Features

* Create an AP (Access Point) at any channel.
* Choose one of the following encryptions: WPA, WPA2, WPA/WPA2, Open (no encryption).
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

## Systemd service
Using the persistent [systemd](https://wiki.archlinux.org/index.php/systemd#Basic_systemctl_usage) service
### Start service immediately:
    systemctl start create_ap

### Start on boot:
    systemctl enable create_ap


## License
FreeBSD


[linux-wifi-hotspot]: https://github.com/lakinduakash/linux-wifi-hotspot
[linux-router]: https://github.com/garywill/linux-router
