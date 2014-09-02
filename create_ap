#!/bin/bash

# general dependencies:
#    bash (to run this script)
#    util-linux (for getopt)
#    hostapd
#    iproute2
#    iw
#    iwconfig (you only need this if 'iw' can not recognize your adapter)
#    haveged (optional)

# dependencies for 'nat' or 'none' Internet sharing method
#    dnsmasq
#    iptables

# dependencies for 'bridge' Internet sharing method
#    bridge-utils

usage() {
    echo "Usage: $(basename $0) [options] <wifi-interface> [<interface-with-internet>] [<access-point-name> [<passphrase>]]"
    echo
    echo "Options:"
    echo "  -h, --help          Show this help"
    echo "  -c <channel>        Channel number (default: 1)"
    echo "  -w <WPA version>    Use 1 for WPA, use 2 for WPA2, use 1+2 for both (default: 1+2)"
    echo "  -n                  Disable Internet sharing (if you use this, don't pass"
    echo "                      the <interface-with-internet> argument)"
    echo "  -m <method>         Method for Internet sharing."
    echo "                      Use: 'nat' for NAT (default)"
    echo "                           'bridge' for bridging"
    echo "                           'none' for no Internet sharing (equivalent to -n)"
    echo "  --hidden            Make the Access Point hidden (do not broadcast the SSID)"
    echo "  --ieee80211n        Enable IEEE 802.11n (HT)"
    echo "  --ht_capab <HT>     HT capabilities (default: [HT40+])"
    echo "  --driver            Choose your WiFi adapter driver (default: nl80211)"
    echo "  --no-virt           Do not create virtual interface"
    echo
    echo "Non-Bridging Options:"
    echo "  -g <gateway>        IPv4 Gateway for the Access Point (default: 192.168.12.1)"
    echo "  -d                  DNS server will take into account /etc/hosts"
    echo
    echo "Useful informations:"
    echo "  * If you're not using the --no-virt option, then you can create an AP with the same"
    echo "    interface you are getting your Internet connection."
    echo "  * You can pass your SSID and password through pipe or through arguments (see examples)."
    echo
    echo "Examples:"
    echo "  $(basename $0) wlan0 eth0 MyAccessPoint MyPassPhrase"
    echo "  echo -e 'MyAccessPoint\nMyPassPhrase' | $(basename $0) wlan0 eth0"
    echo "  $(basename $0) wlan0 eth0 MyAccessPoint"
    echo "  echo 'MyAccessPoint' | $(basename $0) wlan0 eth0"
    echo "  $(basename $0) wlan0 wlan0 MyAccessPoint MyPassPhrase"
    echo "  $(basename $0) -n wlan0 MyAccessPoint MyPassPhrase"
    echo "  $(basename $0) -m bridge wlan0 eth0 MyAccessPoint MyPassPhrase"
    echo "  $(basename $0) --driver rtl871xdrv wlan0 eth0 MyAccessPoint MyPassPhrase"
}

# it takes 2 arguments
# returns:
#  0 if v1 (1st argument) and v2 (2nd argument) are the same
#  1 if v1 is less than v2
#  2 if v1 is greater than v2
version_cmp() {
    [[ ! $1 =~ ^[0-9]+(\.[0-9]+)*$ ]] && die "Wrong version format!"
    [[ ! $2 =~ ^[0-9]+(\.[0-9]+)*$ ]] && die "Wrong version format!"

    V1=( $(echo $1 | tr '.' ' ') )
    V2=( $(echo $2 | tr '.' ' ') )
    VN=${#V1[@]}
    [[ $VN -lt ${#V2[@]} ]] && VN=${#V2[@]}

    for ((x = 0; x < $VN; x++)); do
        [[ ${V1[x]} -lt ${V2[x]} ]] && return 1
        [[ ${V1[x]} -gt ${V2[x]} ]] && return 2
    done

    return 0
}

USE_IWCONFIG=0

is_wifi_interface() {
    which iw > /dev/null 2>&1 && iw dev $1 info > /dev/null 2>&1 && return 0
    if which iwconfig > /dev/null 2>&1 && iwconfig $1 > /dev/null 2>&1; then
        USE_IWCONFIG=1
        return 0
    fi
    return 1
}

get_phy_device() {
    for x in /sys/class/ieee80211/*; do
        [[ ! -d "$x" ]] && continue
        if [[ "${x##*/}" = "$1" ]]; then
            echo $1
            return 0
        elif [[ -e "$x/device/net/$1" ]]; then
            echo ${x##*/}
            return 0
        elif [[ -e "$x/device/net:$1" ]]; then
            echo ${x##*/}
            return 0
        fi
    done
    echo "Failed to get phy interface" >&2
    return 1
}

get_adapter_info() {
    PHY=$(get_phy_device "$1")
    [[ $? -ne 0 ]] && return 1
    iw phy $PHY info
}

can_have_sta_and_ap() {
    # iwconfig does not provide this information, assume false
    [[ $USE_IWCONFIG -eq 1 ]] && return 1
    get_adapter_info "$1" | grep -E '{.* managed.* AP.*}' > /dev/null 2>&1 && return 0
    get_adapter_info "$1" | grep -E '{.* AP.* managed.*}' > /dev/null 2>&1 && return 0
    return 1
}

can_have_ap() {
    # iwconfig does not provide this information, assume true
    [[ $USE_IWCONFIG -eq 1 ]] && return 0
    get_adapter_info "$1" | grep -E '\* AP$' > /dev/null 2>&1 && return 0
    return 1
}

can_transmit_to_channel() {
    IFACE=$1
    CHANNEL=$2

    if [[ $USE_IWCONFIG -eq 0 ]]; then
        CHANNEL_INFO=$(get_adapter_info ${IFACE} | grep "MHz \[${CHANNEL}\]")
        [[ -z "${CHANNEL_INFO}" ]] && return 1
        [[ "${CHANNEL_INFO}" == *no\ IR* ]] && return 1
        [[ "${CHANNEL_INFO}" == *disabled* ]] && return 1
        return 0
    else
        CHANNEL=$(printf '%02d' ${CHANNEL})
        CHANNEL_INFO=$(iwlist ${IFACE} channel | grep "Channel ${CHANNEL} :")
        [[ -z "${CHANNEL_INFO}" ]] && return 1
        return 0
    fi
}

is_wifi_connected() {
    if [[ $USE_IWCONFIG -eq 0 ]]; then
        iw dev "$1" link 2>&1 | grep -E '^Connected to' > /dev/null 2>&1 && return 0
    else
        iwconfig "$1" 2>&1 | grep -E 'Access Point: [0-9a-fA-F]{2}:' > /dev/null 2>&1 && return 0
    fi
    return 1
}

get_macaddr() {
    ip link show "$1" | grep ether | grep -Eo '([0-9a-f]{2}:){5}[0-9a-f]{2}[[:space:]]' | tr -d '[[:space:]]'
}

get_avail_bridge() {
    for i in {0..100}; do
        curr_bridge=$(brctl show | grep "br$i" | cut -s -f1)
        if [[ -z $curr_bridge ]]; then
            echo "br$i"
            return
        fi
    done
}

get_new_macaddr() {
    OLDMAC=$(get_macaddr "$1")
    for i in {20..255}; do
        NEWMAC="${OLDMAC%:*}:$(printf %02x $i)"
        (ip link | grep "ether ${NEWMAC}" > /dev/null 2>&1) || break
    done
    echo $NEWMAC
}

ADDED_UNMANAGED=0
NETWORKMANAGER_CONF=/etc/NetworkManager/NetworkManager.conf
NM_OLDER_VERSION=1

networkmanager_exists() {
    which nmcli > /dev/null 2>&1 || return 1
    NM_VER=$(nmcli -v | grep -m1 -oE '[0-9]+(\.[0-9]+)*\.[0-9]+')
    version_cmp $NM_VER 0.9.10
    if [[ $? -eq 1 ]]; then
        NM_OLDER_VERSION=1
    else
        NM_OLDER_VERSION=0
    fi
    return 0
}

networkmanager_is_running() {
    networkmanager_exists || return 1
    if [[ $NM_OLDER_VERSION -eq 1 ]]; then
        NMCLI_OUT=$(nmcli -t -f RUNNING nm)
    else
        NMCLI_OUT=$(nmcli -t -f RUNNING g)
    fi
    [[ "$NMCLI_OUT" == "running" ]]
}

networkmanager_iface_is_unmanaged() {
    nmcli -t -f DEVICE,STATE d | grep -E "^$1:unmanaged$" > /dev/null 2>&1
}

ADDED_UNMANAGED=

networkmanager_add_unmanaged() {
    networkmanager_exists || return 1

    [[ -d ${NETWORKMANAGER_CONF%/*} ]] || mkdir -p ${NETWORKMANAGER_CONF%/*}
    [[ -f ${NETWORKMANAGER_CONF} ]] || touch ${NETWORKMANAGER_CONF}

    if [[ $NM_OLDER_VERSION -eq 1 ]]; then
        if [[ -z "$2" ]]; then
            MAC=$(get_macaddr "$1")
        else
            MAC="$2"
        fi
        [[ -z "$MAC" ]] && return 1
    fi

    UNMANAGED=$(grep -m1 -Eo '^unmanaged-devices=[[:alnum:]:;,-]*' /etc/NetworkManager/NetworkManager.conf | sed 's/unmanaged-devices=//' | tr ';,' ' ')
    WAS_EMPTY=0
    [[ -z "$UNMANAGED" ]] && WAS_EMPTY=1

    for x in $UNMANAGED; do
        [[ $x == "mac:${MAC}" ]] && return 2
        [[ $NM_OLDER_VERSION -eq 0 && $x == "interface-name:${1}" ]] && return 2
    done

    if [[ $NM_OLDER_VERSION -eq 1 ]]; then
        UNMANAGED="${UNMANAGED} mac:${MAC}"
    else
        UNMANAGED="${UNMANAGED} interface-name:${1}"
    fi

    UNMANAGED=$(echo $UNMANAGED | sed -e 's/^ //')
    UNMANAGED="${UNMANAGED// /;}"
    UNMANAGED="unmanaged-devices=${UNMANAGED}"

    if ! grep -E '^\[keyfile\]' ${NETWORKMANAGER_CONF} > /dev/null 2>&1; then
        echo -e "\n\n[keyfile]\n${UNMANAGED}" >> ${NETWORKMANAGER_CONF}
    elif [[ $WAS_EMPTY -eq 1 ]]; then
        sed -e "s/^\(\[keyfile\].*\)$/\1\n${UNMANAGED}/" -i ${NETWORKMANAGER_CONF}
    else
        sed -e "s/^unmanaged-devices=.*/${UNMANAGED}/" -i ${NETWORKMANAGER_CONF}
    fi

    ADDED_UNMANAGED="${ADDED_UNMANAGED} ${1} "

    return 0
}

networkmanager_rm_unmanaged() {
    networkmanager_exists || return 1
    [[ ! -f ${NETWORKMANAGER_CONF} ]] && return 1

    if [[ $NM_OLDER_VERSION -eq 1 ]]; then
        if [[ -z "$2" ]]; then
            MAC=$(get_macaddr "$1")
        else
            MAC="$2"
        fi
        [[ -z "$MAC" ]] && return 1
    fi

    UNMANAGED=$(grep -m1 -Eo '^unmanaged-devices=[[:alnum:]:;,-]*' /etc/NetworkManager/NetworkManager.conf | sed 's/unmanaged-devices=//' | tr ';,' ' ')

    [[ -z "$UNMANAGED" ]] && return 1

    [[ -n "$MAC" ]] && UNMANAGED=$(echo $UNMANAGED | sed -e "s/mac:${MAC}\( \|$\)//g")
    UNMANAGED=$(echo $UNMANAGED | sed -e "s/interface-name:${1}\( \|$\)//g")
    UNMANAGED=$(echo $UNMANAGED | sed -e 's/ $//')

    if [[ -z "$UNMANAGED" ]]; then
        sed -e "/^unmanaged-devices=.*/d" -i ${NETWORKMANAGER_CONF}
    else
        UNMANAGED="${UNMANAGED// /;}"
        UNMANAGED="unmanaged-devices=${UNMANAGED}"
        sed -e "s/^unmanaged-devices=.*/${UNMANAGED}/" -i ${NETWORKMANAGER_CONF}
    fi

    ADDED_UNMANAGED="${ADDED_UNMANAGED/ ${1} /}"

    return 0
}

networkmanager_rm_unmanaged_if_needed() {
    [[ $ADDED_UNMANAGED =~ .*\ ${1}\ .* ]] && networkmanager_rm_unmanaged ${1}
}

networkmanager_wait_until_unmanaged() {
    networkmanager_is_running || return 1
    while ! networkmanager_iface_is_unmanaged "$1"; do
        sleep 1
    done
    sleep 2
    return 0
}


CHANNEL=1
GATEWAY=192.168.12.1
WPA_VERSION=1+2
ETC_HOSTS=0
HIDDEN=0
SHARE_METHOD=nat
IEEE80211N=0
HT_CAPAB='[HT40+]'
DRIVER=nl80211
NO_VIRT=0

CONFDIR=
WIFI_IFACE=
VWIFI_IFACE=
INTERNET_IFACE=
BRIDGE_IFACE=
OLD_IP_FORWARD=
OLD_BRIDGE_IPTABLES=
OLD_MACADDR=

cleanup() {
    trap "" SIGINT

    echo
    echo "Doing cleanup..."

    # exiting
    for x in $CONFDIR/*.pid; do
        # even if the $CONFDIR is empty, the for loop will assign
        # a value in $x. so we need to check if the value is a file
        [[ -f $x ]] && kill -9 $(cat $x)
    done
    rm -rf $CONFDIR

    if [[ "$SHARE_METHOD" != "none" ]]; then
        if [[ "$SHARE_METHOD" == "nat" ]]; then
            iptables -t nat -D POSTROUTING -o ${INTERNET_IFACE} -j MASQUERADE > /dev/null 2>&1
            iptables -D FORWARD -i ${WIFI_IFACE} -s ${GATEWAY%.*}.0/24 -j ACCEPT > /dev/null 2>&1
            iptables -D FORWARD -i ${INTERNET_IFACE} -d ${GATEWAY%.*}.0/24 -j ACCEPT > /dev/null 2>&1
            [[ -n $OLD_IP_FORWARD ]] && echo $OLD_IP_FORWARD > /proc/sys/net/ipv4/ip_forward
        elif [[ "$SHARE_METHOD" == "bridge" ]]; then
            ip link set down $BRIDGE_IFACE
            brctl delbr $BRIDGE_IFACE
            [[ -n $OLD_BRIDGE_IPTABLES ]] && echo $OLD_BRIDGE_IPTABLES > /proc/sys/net/bridge/bridge-nf-call-iptables
        fi
    fi

    if [[ "$SHARE_METHOD" != "bridge" ]]; then
        iptables -D INPUT -p tcp -m tcp --dport 53 -j ACCEPT > /dev/null 2>&1
        iptables -D INPUT -p udp -m udp --dport 53 -j ACCEPT > /dev/null 2>&1
        iptables -D INPUT -p udp -m udp --dport 67 -j ACCEPT > /dev/null 2>&1
    fi

    if [[ $NO_VIRT -eq 0 ]]; then
        if [[ -n $VWIFI_IFACE ]]; then
            ip link set down dev ${VWIFI_IFACE}
            ip addr flush ${VWIFI_IFACE}
            networkmanager_rm_unmanaged_if_needed ${VWIFI_IFACE} ${OLD_MACADDR}
            iw dev ${VWIFI_IFACE} del
        fi
    else
        ip link set down dev ${WIFI_IFACE}
        ip addr flush ${WIFI_IFACE}
        networkmanager_rm_unmanaged_if_needed ${WIFI_IFACE}
    fi
}

die() {
    [[ -n "$1" ]] && echo -e "\nERROR: $1\n" >&2
    cleanup
    exit 1
}

clean_exit() {
    cleanup
    exit 0
}

# if the user press ctrl+c then execute die()
trap "die" SIGINT

ARGS=$(getopt -o hc:w:g:dnm: -l "help","hidden","ieee80211n","ht_capab:","driver:","no-virt" -n $(basename $0) -- "$@")
[[ $? -ne 0 ]] && exit 1
eval set -- "$ARGS"

while :; do
    case "$1" in
        -h|--help)
            usage >&2
            exit 1
            ;;
        --hidden)
            shift
            HIDDEN=1
            ;;
        -c)
            shift
            CHANNEL="$1"
            shift
            ;;
        -w)
            shift
            WPA_VERSION="$1"
            shift
            ;;
        -g)
            shift
            GATEWAY="$1"
            shift
            ;;
        -d)
            shift
            ETC_HOSTS=1
            ;;
        -n)
            shift
            SHARE_METHOD=none
            ;;
        -m)
            shift
            SHARE_METHOD="$1"
            shift
            ;;
        --ieee80211n)
            shift
            IEEE80211N=1
            ;;
        --ht_capab)
            shift
            HT_CAPAB="$1"
            shift
            ;;
        --driver)
            shift
            DRIVER="$1"
            shift
            ;;
        --no-virt)
            shift
            NO_VIRT=1
            ;;
        --)
            shift
            break
            ;;
    esac
done

if [[ $# -lt 1 ]]; then
    usage >&2
    exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
    echo "You must run it as root." >&2
    exit 1
fi

WIFI_IFACE=$1

if ! is_wifi_interface ${WIFI_IFACE}; then
    echo "ERROR: '${WIFI_IFACE}' is not a WiFi interface" >&2
    exit 1
fi

if ! can_have_ap ${WIFI_IFACE}; then
    echo "ERROR: Your adapter does not support AP (master) mode" >&2
    exit 1
fi

if ! can_have_sta_and_ap ${WIFI_IFACE}; then
    if is_wifi_connected ${WIFI_IFACE}; then
        echo "ERROR: Your adapter can not be connected to an AP and at the same time transmit as an AP" >&2
        exit 1
    elif [[ $NO_VIRT -eq 0 ]]; then
        echo "WARN: Your adapter does not fully support AP virtual interface, enabling --no-virt" >&2
        NO_VIRT=1
    fi
fi

if [[ "$SHARE_METHOD" != "nat" && "$SHARE_METHOD" != "bridge" && "$SHARE_METHOD" != "none" ]]; then
    echo "ERROR: Wrong Internet sharing method" >&2
    echo
    usage >&2
    exit 1
fi

if [[ "$SHARE_METHOD" == "bridge" ]]; then
    OLD_BRIDGE_IPTABLES=$(cat /proc/sys/net/bridge/bridge-nf-call-iptables)
    BRIDGE_IFACE=$(get_avail_bridge)
    if [[ -z $BRIDGE_IFACE ]]; then
        echo "ERROR: No availabe bridges < br100" >&2
        exit 1
    fi
elif [[ "$SHARE_METHOD" == "nat" ]]; then
    OLD_IP_FORWARD=$(cat /proc/sys/net/ipv4/ip_forward)
fi

if [[ "$SHARE_METHOD" != "none" ]]; then
    MIN_REQUIRED_ARGS=2
else
    MIN_REQUIRED_ARGS=1
fi

if [[ $# -gt $MIN_REQUIRED_ARGS ]]; then
    if [[ "$SHARE_METHOD" != "none" ]]; then
        if [[ $# -ne 3 && $# -ne 4 ]]; then
            usage >&2
            exit 1
        fi
        INTERNET_IFACE=$2
        SSID=$3
        PASSPHRASE=$4
    else
        if [[ $# -ne 2 && $# -ne 3 ]]; then
            usage >&2
            exit 1
        fi
        SSID=$2
        PASSPHRASE=$3
    fi
else
    if [[ "$SHARE_METHOD" != "none" ]]; then
        if [[ $# -ne 2 ]]; then
            usage >&2
            exit 1
        fi
        INTERNET_IFACE=$2
    fi
    if tty -s; then
        read -p "SSID: " SSID
        while :; do
            read -p "Passphrase: " -s PASSPHRASE
            echo
            read -p "Retype passphrase: " -s PASSPHRASE2
            echo
            if [[ "$PASSPHRASE" != "$PASSPHRASE2" ]]; then
                echo "Passphrases do not match."
            else
                break
            fi
        done
    else
        read SSID
        read PASSPHRASE
    fi
fi

if [[ $NO_VIRT -eq 1 && "$WIFI_IFACE" == "$INTERNET_IFACE" ]]; then
    echo -n "ERROR: You can not share your connection from the same" >&2
    echo " interface if you are using --no-virt option." >&2
    exit 1
fi

CONFDIR=$(mktemp -d /tmp/create_ap.${WIFI_IFACE}.conf.XXXXXXXX)
echo "Config dir: $CONFDIR"

if [[ $NO_VIRT -eq 0 ]]; then
    VWIFI_IFACE=${WIFI_IFACE}ap

    # in NetworkManager 0.9.10 and above we can set the interface as unmanaged without
    # the need of MAC address, so we set it before we create the virtual interface.
    if networkmanager_is_running && [[ $NM_OLDER_VERSION -eq 0 ]]; then
        echo -n "Network Manager found, set $1 as unmanaged device... "
        networkmanager_add_unmanaged ${VWIFI_IFACE}
        # do not call networkmanager_wait_until_unmanaged because interface does not
        # exist yet
        echo "DONE"
    fi

    WIFI_IFACE_CHANNEL=$(iw dev ${WIFI_IFACE} info | grep channel | awk '{print $2}')

    if [[ -n $WIFI_IFACE_CHANNEL && $WIFI_IFACE_CHANNEL -ne $CHANNEL ]]; then
        echo "hostapd will fail to use channel $CHANNEL because $WIFI_IFACE is already set to channel $WIFI_IFACE_CHANNEL, fallback to channel $WIFI_IFACE_CHANNEL."
        CHANNEL=$WIFI_IFACE_CHANNEL
    fi

    VIRTDIEMSG="Maybe your WiFi adapter does not fully support virtual interfaces.
       Try again with --no-virt."
    echo -n "Creating a virtual WiFi interface... "
    iw dev ${VWIFI_IFACE} del > /dev/null 2>&1
    if iw dev ${WIFI_IFACE} interface add ${VWIFI_IFACE} type __ap; then
        # now we can call networkmanager_wait_until_unmanaged
        networkmanager_is_running && [[ $NM_OLDER_VERSION -eq 0 ]] && networkmanager_wait_until_unmanaged ${VWIFI_IFACE}
        echo "${VWIFI_IFACE} created."
    else
        VWIFI_IFACE=
        die "$VIRTDIEMSG"
    fi
    OLD_MACADDR=$(get_macaddr ${VWIFI_IFACE})
    [[ ${OLD_MACADDR} == $(get_macaddr ${WIFI_IFACE}) ]] && NEW_MACADDR=$(get_new_macaddr ${VWIFI_IFACE})
    WIFI_IFACE=${VWIFI_IFACE}
fi

can_transmit_to_channel ${WIFI_IFACE} ${CHANNEL} || die "Your adapter can not transmit to channel ${CHANNEL}."

if networkmanager_is_running && ! networkmanager_iface_is_unmanaged ${WIFI_IFACE}; then
    echo -n "Network Manager found, set $1 as unmanaged device... "
    networkmanager_add_unmanaged ${WIFI_IFACE}
    networkmanager_wait_until_unmanaged ${WIFI_IFACE}
    echo "DONE"
fi

[[ $HIDDEN -eq 1 ]] && echo "Access Point's SSID is hidden!"

# hostapd config
cat << EOF > $CONFDIR/hostapd.conf
ssid=${SSID}
interface=${WIFI_IFACE}
driver=${DRIVER}
hw_mode=g
channel=${CHANNEL}

ctrl_interface=$CONFDIR/hostapd_ctrl
ctrl_interface_group=0
ignore_broadcast_ssid=$HIDDEN
EOF

if [[ $IEEE80211N -eq 1 ]]; then
    cat << EOF >> $CONFDIR/hostapd.conf
ieee80211n=1
wmm_enabled=1
ht_capab=${HT_CAPAB}
EOF
fi

if [[ -n "$PASSPHRASE" ]]; then
    [[ "$WPA_VERSION" == "1+2" || "$WPA_VERSION" == "2+1" ]] && WPA_VERSION=3
    cat << EOF >> $CONFDIR/hostapd.conf
wpa=${WPA_VERSION}
wpa_passphrase=$PASSPHRASE
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=CCMP
EOF
fi

if [[ "$SHARE_METHOD" == "bridge" ]]; then
    echo "bridge=${BRIDGE_IFACE}" >> $CONFDIR/hostapd.conf
else
    # dnsmasq config (dhcp + dns)
    DNSMASQ_VER=$(dnsmasq -v | grep -m1 -oE '[0-9]+(\.[0-9]+)*\.[0-9]+')
    version_cmp $DNSMASQ_VER 2.63
    if [[ $? -eq 1 ]]; then
        DNSMASQ_BIND=bind-interfaces
    else
        DNSMASQ_BIND=bind-dynamic
    fi
    cat << EOF > $CONFDIR/dnsmasq.conf
interface=${WIFI_IFACE}
${DNSMASQ_BIND}
dhcp-range=${GATEWAY%.*}.1,${GATEWAY%.*}.254,255.255.255.0,24h
dhcp-option=option:router,${GATEWAY}
EOF
    [[ $ETC_HOSTS -eq 0 ]] && echo no-hosts >> $CONFDIR/dnsmasq.conf
fi

# initialize WiFi interface
if [[ $NO_VIRT -eq 0 && -n "$NEW_MACADDR" ]]; then
    ip link set dev ${WIFI_IFACE} address ${NEW_MACADDR} || die "$VIRTDIEMSG"
fi
ip link set down dev ${WIFI_IFACE} || die "$VIRTDIEMSG"
ip addr flush ${WIFI_IFACE} || die "$VIRTDIEMSG"
if [[ "$SHARE_METHOD" != "bridge" ]]; then
    ip link set up dev ${WIFI_IFACE} || die "$VIRTDIEMSG"
    ip addr add ${GATEWAY}/24 broadcast ${GATEWAY%.*}.255 dev ${WIFI_IFACE} || die "$VIRTDIEMSG"
fi

# enable Internet sharing
if [[ "$SHARE_METHOD" != "none" ]]; then
    echo "Sharing Internet using method: $SHARE_METHOD"
    if [[ "$SHARE_METHOD" == "nat" ]]; then
        iptables -t nat -I POSTROUTING -o ${INTERNET_IFACE} -j MASQUERADE || die
        iptables -I FORWARD -i ${WIFI_IFACE} -s ${GATEWAY%.*}.0/24 -j ACCEPT || die
        iptables -I FORWARD -i ${INTERNET_IFACE} -d ${GATEWAY%.*}.0/24 -j ACCEPT || die
        echo 1 > /proc/sys/net/ipv4/ip_forward || die
    elif [[ "$SHARE_METHOD" == "bridge" ]]; then
        # disable iptables rules for bridged interfaces
        echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables || die
        # create and initialize bridged interface
        brctl addbr ${BRIDGE_IFACE} || die
        brctl addif ${BRIDGE_IFACE} ${INTERNET_IFACE} || die
        ip link set dev ${BRIDGE_IFACE} up || die
    fi
else
    echo "No Internet sharing"
fi

# boost low-entropy
if [[ $(cat /proc/sys/kernel/random/entropy_avail) -lt 1000 ]]; then
    which haveged > /dev/null 2>&1 && {
        haveged -w 1024 -p $CONFDIR/haveged.pid
    }
fi

# start dns + dhcp server
if [[ "$SHARE_METHOD" != "bridge" ]]; then
    iptables -I INPUT -p tcp -m tcp --dport 53 -j ACCEPT || die
    iptables -I INPUT -p udp -m udp --dport 53 -j ACCEPT || die
    iptables -I INPUT -p udp -m udp --dport 67 -j ACCEPT || die
    dnsmasq -C $CONFDIR/dnsmasq.conf -x $CONFDIR/dnsmasq.pid || die
fi

# start access point
echo "hostapd command-line interface: hostapd_cli -p $CONFDIR/hostapd_ctrl"

# from now on we exit with 0 on SIGINT
trap "clean_exit" SIGINT

if ! hostapd $CONFDIR/hostapd.conf; then
    echo -e "\nError: Failed to run hostapd, maybe a program is interfering." >&2
    if networkmanager_is_running; then
        echo "If an error like 'n80211: Could not configure driver mode' was thrown" >&2
        echo "try running the following before starting create_ap:" >&2
        if [[ $NM_OLDER_VERSION -eq 1 ]]; then
            echo "    nmcli nm wifi off" >&2
        else
            echo "    nmcli r wifi off" >&2
        fi
        echo "    rfkill unblock wlan" >&2
    fi
    die
fi

clean_exit
