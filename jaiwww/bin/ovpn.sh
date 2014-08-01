#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

act=$1
status=$(uci get sabai.vpn.status)

_return(){
	echo "res={ sabai: $1, msg: '$2' };";
	exit 0;
}

_stop(){
	/etc/init.d/openvpn stop
	uci set sabai.vpn.status=none
	uci commit sabai
	sleep 5
	_return 1 "OpenVPN stopped."
}

_start(){
	if [ ! -e /etc/sabai/openvpn/ovpn.current ]; then
		_return 0 "No file loaded."
		fi
		# stop other vpn's if running
	if [ $status != "none" ]; then
		uci delete network.vpn
		uci set sabai.vpn.status=none
		uci commit
		/etc/init.d/network restart
		sleep 5
		fi
	uci set sabai.vpn.status=ovpn
	uci set openvpn.sabai.enabled=1
	uci commit sabai
	/etc/init.d/openvpn start
	sleep 10
	_return 1 "OpenVPN started."
}

_save(){

		_return 1 "OpenVPN settings saved.";
}

_clear(){
		uci set openvpn.sabai.enabled=0
		uci set openvpn.sabai.filename="none"
		uci set sabai.vpn.status=none
        uci commit
		/etc/init.d/openvpn stop
		echo "" > /etc/sabai/openvpn/open.current
		echo "" > /etc/sabai/openvpn/ovpn
		echo "" > /etc/sabai/openvpn/auth-pass
		sleep 5
		_return 1 "OpenVPN settings cleared.";
}

ls >/dev/null 2>/dev/null 

case $act in
	start)	_start	;;
	stop)	_stop	;;
	save)	_save	;;
	clear)  _clear  ;;
esac
