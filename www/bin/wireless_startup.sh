#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

#remove any prior wireless configuration
rm -f /etc/config/wireless
#reset the wireless configuration based on the new card
wifi detect > /etc/config/wireless
#turn wireless on
uci set wireless.@wifi-device[0].disabled=0; uci commit wireless; wifi
#commit the current sabai wireless settings
sh /www/bin/wl.sh
#log the finish
logger "wireless set"