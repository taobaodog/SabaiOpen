#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
if [ $1 != "update" ]; then
	status=$1
	destination=$2
	action="save"
	echo $status "   " $destination > /tmp/dmz
else
	action=$1
	status=$(uci get sabai-new.dmz.status)
	destination=$(uci get sabai-new.dmz.destination)
fi

redirect=$(uci show firewall | grep 'redirect' | grep '=DMZ' | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
if [ $status = "on" ] && [ $destination != "" ]; then
	if [ "$redirect" != "" ]; then
		uci delete firewall.@redirect[$redirect]
	else
		echo -e "\n"
	fi
	uci add firewall redirect
	uci set firewall.@redirect[-1].name='DMZ'
	uci set firewall.@redirect[-1].src='wan'
	uci set firewall.@redirect[-1].proto='tcp udp'
	uci set firewall.@redirect[-1].src_dport='1-65535'
	uci set firewall.@redirect[-1].dest_ip=$destination
else
	uci delete firewall.@redirect[$redirect] 
fi
uci commit firewall
if [ $action = "update" ]; then
	echo "firewall" >> /tmp/.restart_services
else
	/etc/init.d/firewall restart
	logger "dmz setup and firewall restarted"
fi

ls >/dev/null 2>/dev/null 

# Send completion message back to UI
echo "res={ sabai: 1, msg: 'DMZ settings applied' };"
