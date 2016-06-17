#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2016 Sabai Technology
# Creates a json file of wan info and dhcp leases

#turn on tor in specific mode
mode=$1

#path to config files
UCI_PATH=""
config_file=sabai
proto=$(uci get sabai.vpn.proto)
mode_curr=$(uci get sabai.tor.mode)
tor_stat="$(netstat -lnt | awk '$6 == "LISTEN" && $4 ~ ".9040"')"

_return(){
	echo "res={ sabai: $1, msg: '$2' };"
	exit 0;
}

_off(){
	if [ ! "$tor_stat" ]; then
		logger "NO TOR is running."
		_return 0 "NO TOR is running."
	fi


	/etc/init.d/tor stop
	
	if [ "$(uci get sabai.tor.mode)" = "ap" ]; then
		wifi down
		uci set wireless.@wifi-iface[0].network="mainAP"
		/etc/init.d/odhcp restart
		/etc/init.d/dnsmasq restart
		wifi up
	else
		iptables -t nat -F
	fi

	uci delete privoxy.privoxy.forward_socks5t
	uci delete privoxy.privoxy.forward_socks5
	uci delete privoxy.privoxy.forward_socks4
	uci delete privoxy.privoxy.forward_socks4a
	uci delete privoxy.privoxy.forward
	uci commit privoxy
	/etc/init.d/privoxy restart

	uci $UCI_PATH set sabai.tor.mode="off"
	uci $UCI_PATH set sabai.vpn.proto="none"
	uci $UCI_PATH set sabai.vpn.status="none"
	uci $UCI_PATH commit sabai
	cp -r /etc/config/sabai /configs/
	# must be after sabai changing 
	/etc/init.d/firewall restart

	logger "TOR turned OFF."
	_return 0 "TOR turned OFF."
}

_ap(){
	_check

	wifi down
	uci $UCI_PATH set sabai.tor.mode=$mode
	uci $UCI_PATH set sabai.vpn.proto="tor"
	uci $UCI_PATH set sabai.vpn.status="Anonymity"
	uci $UCI_PATH commit sabai
	cp -r /etc/config/sabai /configs/
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
	_return 0 "TOR turned ON. WIFI AP SSID is $(uci get $config_file.wlradio0.ssid)"
}

_tun() {
	_check

	uci $UCI_PATH set sabai.tor.mode=$mode
	uci $UCI_PATH set sabai.vpn.proto="tor"
	uci $UCI_PATH set sabai.vpn.status="Anonymity"
	uci $UCI_PATH commit sabai
	cp -r /etc/config/sabai /configs/

	/etc/init.d/tor stop

	#cat /dev/null  > /etc/tor/torrc
	echo "# SABAI TOR CONFIG" > /etc/tor/torrc
	echo "SocksPort 9050" >> /etc/tor/torrc
	echo "SocksPort $(uci get network.wan.ipaddr):9050" >> /etc/tor/torrc
	socks_network=$(uci get network.wan.ipaddr | sed 's/.$//')"0/24"
	echo "SocksPolicy accept $socks_network" >> /etc/tor/torrc
	echo "SocksPolicy accept 127.0.0.1" >> /etc/tor/torrc
	echo "SocksPolicy reject *" >> /etc/tor/torrc

	echo -e "\n" >> /etc/tor/torrc
	echo "RunAsDaemon 1" >> /etc/tor/torrc
	echo "DataDirectory /var/lib/tor" >> /etc/tor/torrc

	echo -e "\n" >> /etc/tor/torrc
	echo "CircuitBuildTimeout 30" >> /etc/tor/torrc
	echo "KeepAlivePeriod 60" >> /etc/tor/torrc
	echo "NewCircuitPeriod 15" >> /etc/tor/torrc
	echo "NumEntryGuards 8" >> /etc/tor/torrc
	echo "ConstrainedSockets 1" >> /etc/tor/torrc
	echo "ConstrainedSockSize 8192" >> /etc/tor/torrc
	echo "AvoidDiskWrites 1" >> /etc/tor/torrc

	echo -e "\n" >> /etc/tor/torrc
	echo "User tor" >> /etc/tor/torrc

	echo -e "\n" >> /etc/tor/torrc
	echo "VirtualAddrNetwork $(uci get $config_file.tor.network)/10" >> /etc/tor/torrc
        echo "AutomapHostsOnResolve 1" >> /etc/tor/torrc
        echo "TransPort 9040" >> /etc/tor/torrc
        echo "TransListenAddress $(uci get network.wan.ipaddr)" >> /etc/tor/torrc
        echo "DNSPort 53" >> /etc/tor/torrc
        echo "DNSListenAddress $(uci get network.wan.ipaddr)" >> /etc/tor/torrc

	# Tor's TransPort
	_trans_port="9040"

	# Privoxy port
	_privox_port="8080"

	# Tor's ProxyPort
        _tor_proxy_port="9050"

	# your internal interface
	_int_if="eth0"
	#iptables -t nat -F

	iptables -t nat -A OUTPUT -d "$(uci get $config_file.wan.ipaddr)" -j RETURN
	iptables -t nat -A OUTPUT -d 127.0.0.0/8 -j RETURN
	iptables -t nat -A PREROUTING -i eth0 -d "$(uci get $config_file.wan.ipaddr)" -j RETURN
	iptables -A OUTPUT -d "$(uci get $config_file.wan.ipaddr)" -j ACCEPT
	iptables -A OUTPUT -d 127.0.0.0/8 -j ACCEPT

	iptables -t nat -A PREROUTING -i $_int_if -p udp --dport 53 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -i $_int_if -p tcp --syn -j REDIRECT --to-ports $_trans_port
	
	_forward_socks="/	127.0.0.1:9050	."
	uci set privoxy.privoxy.listen_address="$(uci get $config_file.wan.ipaddr):$_privox_port $(uci get network.loopback.ipaddr):$_privox_port"
	uci set privoxy.privoxy.permit_access="$socks_network"
	uci set privoxy.privoxy.forward_socks5t="$_forward_socks"
	uci set privoxy.privoxy.forward_socks5="$_forward_socks"
	uci set privoxy.privoxy.forward_socks4="$_forward_socks"
	uci set privoxy.privoxy.forward_socks4a="$_forward_socks"
	uci add_list privoxy.privoxy.forward="192.168.*.*/	."
	uci add_list privoxy.privoxy.forward="10.*.*.*/	." 
	uci add_list privoxy.privoxy.forward="127.*.*.*/	."
	uci add_list privoxy.privoxy.forward="localhost/     ."
	uci commit privoxy
	
	/etc/init.d/tor start
	/etc/init.d/privoxy restart
	logger "TOR tunnel started."
	logger "ALL traffic will be anonymized."
	_return 0 "Tor tunnel started."
}

_check() {
	ifconfig > /tmp/check
	if [ "$(cat /tmp/check | grep pptp)" ]; then
		/www/bin/pptp.sh stop
	elif [ "$(cat /tmp/check | grep tun)" ]; then
		/www/bin/ovpn.sh stop
	elif [ "$tor_stat" ] && [ $mode = "ap" ]; then
		_check_tor
	elif [ "$tor_stat" ] && [ $mode = "tun" ]; then
		_check_tor
	else
		logger "No VPN is running."
	fi
}

_check_tor() {
	if [ "$tor_stat" ]; then
		_return 0 "TOR is running."
	else
		logger "TOR will be restarted in another mode."
	fi
}

case $mode in
	off)	_off	;;
	ap)	_ap	;;
	tun)	_tun	;;
	stat)	_check_tor ;;
esac
