## FOR HELP TYPE create_ap --help
This was not in the original README.md or repository. I figured this out on my own.
## BEFORE USING THE PERSISTENT SERVICE PLEASE READ

create_ap is going to read from the config at /etc/create_ap.conf not the one in the directory from the build.

 Do not forget to edit /etc/create_ap.conf before reboot.

## Dependencies
### General
    bash (to run this script)
    util-linux (for getopt)
    procps or procps-ng
    hostapd
    iproute2
    iw
    iwconfig (you only need this if 'iw' can not recognize your adapter)
    haveged (optional)
    dnsmasq
    iptables
    build-essential
    linux-headers-generic (or linux-headers)
    dkms
    git


## Installation
### Debian

    git clone https://github.com/diveyez/create_ap
    cd create_ap
    make install
    sudo bash install-dep.sh
    sudo service hostapd stop
    sudo service dnsmasq stop
    sudo update-rc.d hostapd disable
    sudo update-rc.d dnsmasq disable

    in terminal type: nano /etc/dnsmasq.conf and add the lines below to that file
    ```
    # Bind to only one interface
    bind-interfaces
    # Choose interface for binding
    interface=wlan1
    # Specify range of IP addresses for DHCP leasses
    dhcp-range=10.10.10.1,10.10.10.10
    ```

    nano /etc/hostapd/hostapd.conf

    ```
    # Define interface
    interface=wlan1
    # Select driver
    driver=nl80211
    wme_enabled=1
    ieee80211n=1
    ht_capab=[HT40+][SHORT-GI-40][DSSS_CCK-40]
    # Set access point name
    ssid=Illuminati
    # Set access point harware mode to 802.11g
    hw_mode=g
    # Set WIFI channel (can be easily changed)
    channel=9
    # Enable WPA2 only (1 for WPA, 2 for WPA2, 3 for WPA + WPA2)
    wpa=3
    wpa_passphrase=confirmed1337!
    wpa_key_mgmt=WPA-PSK
    wpa_pairwise=TKIP
    rsn_pairwise=CCMP
    macaddr_acl=0
    auth_algs=1


    ```


    ### Start service immediately:
    systemctl start create_ap

    ### Start on boot:
    systemctl enable create_ap


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
