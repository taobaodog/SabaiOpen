#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
UCI_PATH="-c /configs"

action=$1
status=$(uci get sabai.vpn.status)

_return(){
	echo "res={ sabai: $1, msg: '$2' };";
	exit 0;
}

_stop(){
	uci delete network.openvpn
	uci commit network
	forward=$(uci show firewall | grep =sabai | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	uci delete firewall.@forwarding["$forward"]
	uci commit firewall
	uci $UCI_PATH set sabai.vpn.status=none
	uci $UCI_PATH set sabai.vpn.proto=none
	uci $UCI_PATH commit sabai
	/etc/init.d/openvpn stop
	/etc/init.d/openvpn disable
	sleep 5
	_return 1 "OpenVPN stopped."
    logger "openvpn stopped"
}

_start(){
	uci $UCI_PATH set sabai.vpn.status=Starting
	uci $UCI_PATH set sabai.vpn.proto=ovpn
	if [ ! -e /etc/sabai/openvpn/ovpn.current ]; then
		_return 0 "No file loaded."
	fi
	# stop other vpn's if running
	if [ $status != "none" ]; then
		uci $UCI_PATH commit sabai
		uci delete network.vpn
		uci commit network
		if [ $action = "update" ]; then
			echo "network" >> /tmp/.restart_services
		else
			/etc/init.d/network restart
		fi

		logger "openvpn stopped and network restarted"
		sleep 5
	fi
	uci delete network.openvpn
	forward=$(uci show firewall | grep =sabai | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	uci delete firewall.@forwarding["$forward"]
	uci set openvpn.sabai.log='/www/libs/data/stat/ovpn.log'
	uci set openvpn.sabai.enabled=1
	uci set network.openvpn=interface
	uci set network.openvpn.ifname='tun0'
	uci set network.openvpn.proto='ovpn'
	uci add firewall forwarding
	uci add firewall@forwarding[-1].src=lan
	uci add firewall@forwarding[-1].dest=sabai
	uci commit
	uci $UCI_PATH set sabai.vpn.status=Started
	uci $UCI_PATH set sabai.vpn.proto=ovpn
	uci $UCI_PATH commit sabai
	/etc/init.d/openvpn start
	/etc/init.d/openvpn enable
	if [ $action = "update" ]; then
		echo "firewall" >> /tmp/.restart_services                                
	else                                            
		/etc/init.d/firewall restart           
	fi
	logger "openvpn started"
	sleep 10
	if [ $(ifconfig tun0 | grep not) != "" ]; then
		uci $UCI_PATH set sabai.vpn.status=Disconnected
		uci $UCI_PATH commit sabai
	else
		uci $UCI_PATH set sabai.vpn.status=Connected
		uci $UCI_PATH commit sabai
	fi
	_return 1 "OpenVPN started."
}

_save(){
	_return 1 "OpenVPN settings saved.";
}

_clear(){
		uci set openvpn.sabai.enabled=0
		uci set openvpn.sabai.filename="none"
		uci set network.vpn.proto=none
		uci commit
		uci $UCI_PATH set sabai.vpn.status=none
		uci $UCI_PATH set sabai.vpn.proto=none
		uci $UCI_PATH commit sabai
		/etc/init.d/openvpn stop
		/etc/init.d/openvpn disable
		echo "" > /etc/sabai/openvpn/ovpn.current
		echo "" > /etc/sabai/openvpn/ovpn
		echo "" > /etc/sabai/openvpn/auth-pass
		sleep 5
		_return 1 "OpenVPN settings cleared.";
}

ls >/dev/null 2>/dev/null 

case $action in
	start)	_start	;;
	stop)	_stop	;;
	update) _start  ;;
	save)	_save	;;
	clear)  _clear  ;;
esac
