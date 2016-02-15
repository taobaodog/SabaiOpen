#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology

_dhcp(){
	uci set network.wan=interface
	interfaces=$(ip link show | grep ": eth" | cut -d ':' -f2 | awk -F: '{print $0}' | awk '{print $1}');
	for x in $interfaces; do
		echo $x > /tmp/wan;
		echo $interfaces > /tmp/ports;
		sed -i "s/$x //g" /tmp/ports;
		uci set network.wan.ifname="$(cat /tmp/wan)";
		uci set network.lan.ifname="$(cat /tmp/ports)";
		break;
	done
	uci set network.wan.proto="$(uci get $config_file.wan.proto)";
	uci set network.wan.mtu="$(uci get $config_file.wan.mtu)";
	uci set network.wan.macaddr="$(uci get $config_file.wan.mac)";
	uci set network.wan.dns="$(uci get $config_file.wan.dns)";
	uci commit
	ifconfig $(uci get network.wan.ifname) up
	if [ $action = "update" ]; then
		echo "network" >> /tmp/.restart_services
	else
		/etc/init.d/network restart
	fi
}

_static(){
	interfaces=$(ip link show | grep ": eth" | cut -d ':' -f2 | awk -F: '{print $0}' | awk '{print $1}');
	for x in $interfaces; do
		echo $x > /tmp/wan;
		echo $interfaces > /tmp/ports;
		sed -i "s/$x //g" /tmp/ports;
		uci set network.wan.ifname="$(cat /tmp/wan)";
		uci set network.lan.ifname="$(cat /tmp/ports)";
		break;
	done
	uci set network.wan.proto="$(uci get $config_file.wan.proto)";
	uci set network.wan.ipaddr="$(uci get $config_file.wan.ipaddr)";
	uci set network.wan.netmask="$(uci get $config_file.wan.netmask)";
	uci set network.wan.gateway="$(uci get $config_file.wan.gateway)";
	uci set network.wan.mtu="$(uci get $config_file.wan.mtu)";
	uci set network.wan.mac="$(uci get $config_file.wan.mac)";
	uci set network.wan.dns="$(uci get $config_file.wan.dns)";
	uci commit;
	ifconfig $(uci get network.wan.ifname) up;
	if [ $action = "update" ]; then
		echo "network" >> /tmp/.restart_services
	else
		/etc/init.d/network restart
	fi
}

_lan(){
	interfaces=$(ip link show | grep ": eth" | cut -d ':' -f2 | awk -F: '{print $0}' | awk '{print $1}');
	echo $interfaces > /tmp/ports;
	uci delete network.wan;
	uci set network.lan.ifname="$(cat /tmp/ports)";
	uci commit;
	if [ $action = "update" ]; then
		echo "network" >> /tmp/.restart_services
	else
		/etc/init.d/network restart
	fi
}

ls >/dev/null 2>/dev/null 
logger "wan script run and firewall restarted"


if [ "$1" = "update" ]; then
	config_file=sabai-new
	action=$1
	proto=$(uci get $config_file.wan.proto)
else
	proto=$1
	action="save"
	config_file=sabai
fi

case $proto in
	dhcp)	_dhcp	;;
	static)	_static	;;
	lan)	_lan	;;
esac
