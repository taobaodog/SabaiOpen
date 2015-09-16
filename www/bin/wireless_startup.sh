#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

# remove any prior wireless configuration
rm -f /etc/config/wireless

# reset the wireless configuration based on the new card
wifi detect > /etc/config/wireless

# setting wifi configurations
#uci set wireless.@wifi-device[0].disabled=0; uci commit wireless; wifi
# enabling radio0
[ -n "$(uci get wireless.@wifi-device[0].disabled)" ] && uci set wireless.@wifi-device[0].disabled=0

# commit the current sabai wireless settings
# wlradio0
sh /www/bin/wl.sh start 0
logger "Wireless configurations for wlan0 were set."

# wlradio1 - guest ap
uci add wireless wifi-iface
uci commit wireless
sh /www/bin/wl.sh start 1
logger "Wireless configurations for wlan1 were set."

sleep 15

[ -z "$(ifconfig | grep wlan0)" ] && [ "$(uci get sabai.wlradio0.mode)" != "off" ] && logger "ERROR WIFI: wlradio0 configurations were corrupted."
[ -z "$(ifconfig | grep wlan1)" ] && [ "$(uci get sabai.wlradio1.mode)" != "off" ] && logger "ERROR WIFI: wlradio0 configurations were corrupted."
#log the finish
logger "Wireless configuration completed."
