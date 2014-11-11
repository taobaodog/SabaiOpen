#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
status=$1
destination=$2
echo $status "   " $destination > /tmp/dmz

if [ $status = "on" ] && [ $destination != "" ]; then
		echo "condition 1" >> /tmp/dmz
      	uci add firewall redirect
      	uci set firewall.@redirect[0].src='wan'
      	uci set firewall.@redirect[0].proto='tcp udp'
      	uci set firewall.@redirect[0].src_dport='1-65535'
      	uci set firewall.@redirect[0].dest_ip=$destination
	else
		uci delete firewall.@redirect[0] 
		echo "condition 2" >> /tmp/dmz
	fi

uci commit firewall;
/etc/init.d/firewall restart
logger "dmz setup and firewall restarted"

ls >/dev/null 2>/dev/null 

# Send completion message back to UI
echo "res={ sabai: 1, msg: 'DMZ settings applied' };"