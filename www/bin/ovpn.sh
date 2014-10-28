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
	uci set sabai.vpn.status=none
	uci set sabai.vpn.proto=none
	uci commit
	/etc/init.d/openvpn stop
	/etc/init.d/openvpn disable
	sleep 5
	_return 1 "OpenVPN stopped."
    logger "openvpn stopped"
}

_start(){
	uci set sabai.vpn.status=Starting
	uci set sabai.vpn.proto=ovpn
	if [ ! -e /etc/sabai/openvpn/ovpn.current ]; then
		_return 0 "No file loaded."
		fi
		# stop other vpn's if running
	if [ $status != "none" ]; then
		uci delete network.vpn
		uci commit
		/etc/init.d/network restart
		logger "openvpn stopped and network restarted"
		sleep 5
		fi
	uci delete network.openvpn
	uci set openvpn.sabai.log='/www/libs/data/stat/ovpn.log'
	uci set sabai.vpn.status=Started
	uci set openvpn.sabai.enabled=1
	uci set network.openvpn=interface
	uci set network.openvpn.ifname='tun0'
	uci set network.openvpn.proto='ovpn'
	uci commit
	/etc/init.d/openvpn start
	/etc/init.d/openvpn enable
	logger "openvpn started"
	sleep 10
	if [ $(ifconfig tun0 | grep not) != "" ]; then
		uci set sabai.vpn.status=Disconnected
	else
		uci set sabai.vpn.status=Connected
		fi
	uci commit;
	_return 1 "OpenVPN started."
}

_save(){

		_return 1 "OpenVPN settings saved.";
}

_clear(){
		uci set openvpn.sabai.enabled=0
		uci set openvpn.sabai.filename="none"
		uci set sabai.vpn.status=none
		uci set sabai.vpn.proto=none
		uci set network.vpn.proto=none
        uci commit
		/etc/init.d/openvpn stop
		/etc/init.d/openvpn disable
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