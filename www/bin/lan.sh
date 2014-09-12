#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

proto=$1
uci set network.lan.ipaddr=$(uci get sabai.lan.ipaddr);
uci set network.lan.netmask=$(uci get sabai.lan.netmask);
uci set dhcp.lan.leasetime=$(uci get sabai.dhcp.leasetime);
uci set dhcp.lan.start=$(uci get sabai.dhcp.start);
uci set dhcp.lan.limit=$(uci get sabai.dhcp.limit);
uci commit sabai;
/etc/init.d/network restart

# Send completion message back to UI
echo "res={ sabai: true, msg: 'LAN settings applied' }";

ls >/dev/null 2>/dev/null 

