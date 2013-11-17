## Dependencies

* bash (to run this script)
* util-linux (for getopt)
* hostapd
* dnsmasq
* iptables
* iproute2
* haveged (optional)

## Examples

### No passphrase (open network):

    ./create_ap wlan0 eth0 MyAccessPoint

OR

    echo -e "MyAccessPoint\n" | ./create_ap wlan0 eth0

### WPA + WPA2 passphrase:

    ./create_ap wlan0 eth0 MyAccessPoint MyPassPhrase

OR

    echo -e "MyAccessPoint\nMyPassPhrase" | ./create_ap wlan0 eth0

### AP without Internet sharing:

    ./create_ap -n wlan0 MyAccessPoint MyPassPhrase

OR

    echo -e "MyAccessPoint\nMyPassPhrase" | ./create_ap -n wlan0
