#!/bin/bash

if [[ $# == 2 ]]; then
	LAN=$1
	WIFI=$2
else
	echo -e "Usage:\t$0 LAN_interface WIFI_interface, for example:\n\t$0 eth0 wlan0"
	exit 0
fi

HOST_IP=192.168.153.1
DHCP_RANGE=192.168.153.2,192.168.153.15
DNSMASQ_PID=/tmp/dnsmasq.pid
DNSMASQ_CONF=$(mktemp /tmp/dnsmasq.conf-XXXXXXXXXX)
HOSTAPD_CONF=$(mktemp /tmp/hostapd.conf-XXXXXXXXXX)

cat > $DNSMASQ_CONF << EOF
bind-interfaces
except-interface=lo
interface=$WIFI
dhcp-range=$DHCP_RANGE
EOF

cat > $HOSTAPD_CONF << EOF
# Define interface
interface=$WIFI
# Select driver
driver=nl80211
# Set access point name
ssid=laptop-wifi
# Set access point harware mode to 802.11g
hw_mode=g
# Set WIFI channel (can be changed)
channel=6
# Enable WPA2 only (1 for WPA, 2 for WPA2, 3 for WPA + WPA2)
wpa=2
wpa_passphrase=wifipass
EOF

sudo bash << EOF
# Start
rfkill unblock wifi
ifconfig $WIFI $HOST_IP
dnsmasq --conf-file=$DNSMASQ_CONF --pid-file=$DNSMASQ_PID
sysctl net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o $LAN -j MASQUERADE
hostapd $HOSTAPD_CONF

# Stop
iptables -D POSTROUTING -t nat -o $LAN -j MASQUERADE
sysctl net.ipv4.ip_forward=0
kill \$(cat $DNSMASQ_PID)
rm $DNSMASQ_PID
EOF

# Cleanup
rm $DNSMASQ_CONF
rm $HOSTAPD_CONF
