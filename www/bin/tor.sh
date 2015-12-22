#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology
# Creates a json file of wan info and dhcp leases

#turn on tor in specific mode
mode=$1

#path to config files
UCI_PATH="-c /configs"
config_file=sabai


_off(){
	/etc/init.d/tor stop
	uci set wireless.@wifi-iface[0].network="mainAP"
	logger "TOR turned OFF."
}

_ap(){
	wifi down
	uci set wireless.@wifi-iface[0].disabled=0
	uci set wireless.@wifi-iface[0].mode="$(uci get $config_file.tor.mode)"
	uci set wireless.@wifi-iface[0].ssid="$(uci get $config_file.wlradio0.ssid)"
	uci set wireless.@wifi-iface[0].network="tor"
	uci commit wireless
	uci set network.tor.ipaddr="$(uci get $config_file.tor.ipaddr)"
	uci set network.tor.netmask="$(uci get $config_file.tor.netmask)"
	uci commit network
	redirect=$(uci show firewall | grep redirect | grep name=\'Redirect\ Tor\ Traffic\' | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	src_dip=$(uci get $config_file.tor.ipaddr | sed 's/.$//' )
	uci set firewall.@redirect["$redirect"].src_dip='!'$src_dip'0/24'
	uci commit firewall
	# ajusting tor deamon	
	sed -i '/VirtualAddrNetwork/,$d' /etc/tor/torrc	
	echo "VirtualAddrNetwork $(uci get $config_file.tor.network)" >> /etc/tor/torrc
	echo "AutomapHostsOnResolve 1" >> /etc/tor/torrc
	echo "TransPort 9040" >> /etc/tor/torrc
	echo "TransListenAddress $(uci get $config_file.tor.ipaddr)" >> /etc/tor/torrc
	echo "DNSPort 9053" >> /etc/tor/torrc
	echo "DNSListenAddress $(uci get $config_file.tor.ipaddr)" >> /etc/tor/torrc
	
	/etc/init.d/firewall reload
    	/etc/init.d/firewall restart
	/etc/init.d/odhcp restart
	/etc/init.d/dnsmasq restart
	/etc/init.d/tor enable
	wifi up
	logger "TOR turned ON. WIFI AP SSID is $(uci get $config_file.wlradio0.ssid)"
}


case $mode in
	off)	_off	;;
	ap)	_ap	;;
	tun)	_tun	;;
esac
