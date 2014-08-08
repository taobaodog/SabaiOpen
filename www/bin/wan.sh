#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

proto=$1

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
	uci set network.wan.proto="$(uci get sabai.wan.proto)";
	uci set network.wan.mtu="$(uci get sabai.wan.mtu)";
	uci set network.wan.mac="$(uci get sabai.wan.mac)";
	uci set network.wan.dns="$(uci get sabai.wan.dns)";
	uci commit
	ifconfig $(uci get network.wan.ifname) up
	/etc/init.d/network restart
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
	uci set network.wan.proto="$(uci get sabai.wan.proto)";
	uci set network.wan.ipaddr="$(uci get sabai.wan.ipaddr)";
	uci set network.wan.netmask="$(uci get sabai.wan.netmask)";
	uci set network.wan.gateway="$(uci get sabai.wan.gateway)";
	uci set network.wan.mtu="$(uci get sabai.wan.mtu)";
	uci set network.wan.mac="$(uci get sabai.wan.mac)";
	uci set network.wan.dns="$(uci get sabai.wan.dns)";
	uci commit;
	ifconfig $(uci get network.wan.ifname) up;
	/etc/init.d/network restart;
}

_lan(){
	interfaces=$(ip link show | grep ": eth" | cut -d ':' -f2 | awk -F: '{print $0}' | awk '{print $1}');
	echo $interfaces > /tmp/ports;
	uci delete network.wan;
	uci set network.lan.ifname="$(cat /tmp/ports)";
	uci commit;
	/etc/init.d/network restart;
}

ls >/dev/null 2>/dev/null 

case $proto in
	dhcp)	_dhcp	;;
	static)	_static	;;
	lan)	_lan	;;
esac