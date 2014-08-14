#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

location=$(uci get sabai.time.location)

# Set time on system
uci set sabai.time.timezone="$(cat /www/libs/timezones.data | grep -w "$location" | awk '{print $2}')"
uci set system.@system[0].timezone="$(uci get sabai.time.timezone)";
uci set system.ntp.server="$(uci get sabai.time.servers)";
uci commit
echo $(uci get sabai.time.timezone) > /etc/TZ
/etc/init.d/ntpd restart

# Send completion message back to UI
echo "res={ sabai: true, msg: 'Time settings applied' }"

ls >/dev/null 2>/dev/null 
