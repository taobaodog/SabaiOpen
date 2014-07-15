#!/bin/ash
act=$1
vpn_command=$1
sys='/www/bin/sys/ovpn'
pidf='/www/stat/ovpn.pid'

_return(){
	echo "res={ sabai: $1, msg: '$2' };";
	exit 0;
}

_erase(){
	rm /www/usr/ovpn*
	/etc/init.d/openvpn stop
	/etc/init.d/openvpn disable
}

_stop(){
	/etc/init.d/openvpn stop
	rm /www/stat/ovpn.connected
	[ "$act" == "stop" ] && _return 1 "OpenVPN stopped."
}

_start(){
	_stop;
	[ ! -e /www/usr/ovpn.current ] && _return 0 "No file loaded."
	uci delete network.vpn
	uci commit
	/etc/init.d/network restart
	rm /www/stat/pptp.connected
	sleep 5
	/etc/init.d/openvpn start
	/etc/init.d/openvpn enable
	touch /www/stat/ovpn.connected
	sleep 10
        [ "$act" == "start" ] && _return 1 "OpenVPN started."
}

ls >/dev/null 2>/dev/null
[ $? -eq 1 ] && _return 0 "Need Sudo powers."
([ -z "$act" ] ) && _return 0 "Missing arguments: act=$act."

echo "$# $*" > /tmp/ovpn.txt

case $act in
	start)	_start	;;
	stop)	_stop	;;
	erase)	_erase	;;
esac

