#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

act=$1
_u=$2
_p=$3
_s=$4

_stop(){
	uci delete network.vpn
	uci set sabai.vpn.status=none
	uci commit
	/etc/init.d/network restart
}

_start(){
	/etc/init.d/openvpn stop
        uci set network.vpn=interface
        uci set network.vpn.ifname=pptp-vpn
        uci set network.vpn.proto=pptp
        uci set network.vpn.username=$_u
        uci set network.vpn.password=$_p
        uci set network.vpn.server=$_s
        uci set network.vpn.buffering=1
        uci set sabai.vpn.status=pptp
        uci commit
        /etc/init.d/network restart
}

_save(){
		uci set sabai.vpn.username=$_u
		uci set sabai.vpn.password=$_p
		uci set sabai.vpn.server=$_s
        uci commit
}

_clear(){
	/etc/init.d/openvpn stop
		uci delete network.vpn
		uci delete sabai.vpn.username
		uci delete sabai.vpn.password
		uci delete sabai.vpn.server
		uci set sabai.vpn.status=none
        uci commit
        /etc/init.d/network restart
}

ls >/dev/null 2>/dev/null 

case $act in
	start)	_start	;;
	stop)	_stop	;;
	save)	_save	;;
	clear)  _clear  ;;
esac