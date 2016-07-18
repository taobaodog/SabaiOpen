#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2016 Sabai Technology
# iptables rules are stored in /etc/sabai/firewall.settings

val=$1
state=$2

_ping(){
	local state=$1

	local field=$(uci show firewall | grep -e "name='Disable ping from WAN'" | cut -d "[" -f2 | cut -d "]" -f1)

	if [ -n "$field" ]; then
		uci delete firewall.@rule[$field]
	fi

	if [ "$state" == "disabled" ]; then
		uci add firewall rule > /dev/null
		uci set firewall.@rule[-1].name='Disable ping from WAN'
		uci set firewall.@rule[-1].src='wan'
		uci set firewall.@rule[-1].proto='icmp'
		uci set firewall.@rule[-1].icmp_type='8'
		uci set firewall.@rule[-1].target='DROP'
	fi

	uci commit firewall
	logger "Ping from WAN is $state. Restarting firewall"
	/etc/init.d/firewall restart 2>1 > /dev/null
}

_multicast(){
	local state=$1

	for field in $(uci show firewall | grep -e "name='Enable UDP multicast (IGMP)'" | cut -d "[" -f2 | cut -d "]" -f1 | sort -r)
	do
		uci delete firewall.@rule[$field]
	done
	uci commit firewall

	if [ "$state" == "enabled" ]; then
		uci set network.lan.igmp_snooping=1
		uci commit network

		uci add firewall rule > /dev/null
		uci set firewall.@rule[-1].name='Enable UDP multicast (IGMP)'
		uci set firewall.@rule[-1].src='wan'
		uci set firewall.@rule[-1].proto='igmp'
		uci set firewall.@rule[-1].target='ACCEPT'
		uci commit firewall

		uci add firewall rule > /dev/null
		uci set firewall.@rule[-1].name='Enable UDP multicast (IGMP)'
		uci set firewall.@rule[-1].src='wan'
		uci set firewall.@rule[-1].proto='udp'
		uci set firewall.@rule[-1].dest='lan'
		uci set firewall.@rule[-1].target=ACCEPT
		uci set firewall.@rule[-1].family=ipv4
		uci commit firewall

	else
		uci set network.lan.igmp_snooping=0
		uci commit network
	fi

	logger "UDP multicast (IGMP) is $state. Reloading network and restarting firewall"
	/etc/init.d/network reload 2>1 > /dev/null
	/etc/init.d/firewall restart 2>1 > /dev/null
}

_cookies(){
	local state=$1

	if [ "$state" == "enabled" ]; then
		uci set firewall.@defaults[0].tcp_syncookies=1
	else
		uci set firewall.@defaults[0].tcp_syncookies=0
	fi
	uci commit firewall

	logger "SYN cookies are $state. Restarting firewall"
	/etc/init.d/firewall restart 2>1 > /dev/null
}

_wan_access(){
	local state=$1
	local ip_lan="$(ifconfig -a br-lan | grep -F "inet addr" | awk '{print $2}' | tr -d 'addr:')"

	if [ "$state" == "enabled" ]; then
		uci set uhttpd.main.listen_http=80
		uci set uhttpd.main.listen_https=443
		uci delete dropbear.@dropbear[0].Interface
	else
		uci set uhttpd.main.listen_http=$ip_lan':80'
		uci set uhttpd.main.listen_https=$ip_lan':443'
		uci set dropbear.@dropbear[0].Interface='lan'
	fi
	uci commit

	logger "WAN access is $state. Restarting uhttpd and dropbear"
	/etc/init.d/uhttpd restart
	/etc/init.d/dropbear restart
}

case $val in
	ping)		_ping $state	   ;;
	multicast)   _multicast $state  ;;
	syn_cookies) _cookies $state	;;
	wan_access)  _wan_access $state ;;
esac
