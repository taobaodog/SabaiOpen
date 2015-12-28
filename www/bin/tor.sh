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

	if [ "$(uci get sabai.tor.mode)" = "ap" ]; then
		wifi down
		uci set wireless.@wifi-iface[0].network="mainAP"
		/etc/init.d/odhcp restart
        	/etc/init.d/dnsmasq restart
		wifi up
	else
		/etc/init.d/tor stop
	        /etc/init.d/firewall restart
	fi

	uci $UCI_PATH set sabai.tor.mode="off"
	uci $UCI_PATH commit sabai
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

_tun() {
	/etc/init.d/tor stop
	sed -i '/VirtualAddrNetwork/,$d' /etc/tor/torrc
	echo "VirtualAddrNetwork $(uci get $config_file.tor.network)/10" >> /etc/tor/torrc
	echo "AutomapHostsOnResolve 1" >> /etc/tor/torrc
	echo "TransPort 9040" >> /etc/tor/torrc
	echo "TransListenAddress $(uci get network.wan.ipaddr)" >> /etc/tor/torrc
        echo "DNSPort 53" >> /etc/tor/torrc
        echo "DNSListenAddress $(uci get network.wan.ipaddr)" >> /etc/tor/torrc

	# Tor's TransPort
	_trans_port="9040"

	# your internal interface
	_int_if="eth0"
	iptables -F
	iptables -t nat -F

	iptables -t nat -A OUTPUT -d "$(uci get $config_file.wan.ipaddr)" -j RETURN
	iptables -t nat -A PREROUTING -i eth0 -d "$(uci get $config_file.wan.ipaddr)" -j RETURN
	iptables -A OUTPUT -d "$(uci get $config_file.wan.ipaddr)" -j ACCEPT
	iptables -A OUTPUT -d 127.0.0.0/8 -j ACCEPT

	iptables -t nat -A PREROUTING -i $_int_if -p udp --dport 53 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -i $_int_if -p tcp --syn -j REDIRECT --to-ports $_trans_port
	/etc/init.d/tor start
	logger "TOR turned on as a tunnel."
	logger "ALL traffic will be anonymized."
}

case $mode in
	off)	_off	;;
	ap)	_ap	;;
	tun)	_tun	;;
esac
