#!/bin/bash

sudo bash -c "
apt-get install rfkill hostapd dnsmasq-base
service hostapd stop
update-rc.d hostapd disable
"
