#!/bin/bash
# Reads for User Input
echo "What Name Do You Want The WiFi To Have?:"
read ssid
echo "What PSK/Password Should It Have?:"
read key
echo "What Channel?: (To Avoid Congestion, Use A Channel Not Popular In The Area, ie: 3,5,7,9)"
read channel
# Launch Time
sudo create_ap -w 2 -c $channel $wifdev eth0 $ssid $key
