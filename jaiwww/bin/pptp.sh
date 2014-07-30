#!/bin/ash
act=$1
_u=$2
_p=$3
_s=$4
vpn_command="$1 $2 $3 $4"
pidf="/var/run/ppp7.pid"
opts="/www/usr/pptp.options"

_return(){
	echo "res={ sabai: $1, msg: '$2' };";
	exit 0;
}

_badarg(){ _return 0 "Missing arguments: act=$act, user=$_u, pass=$_p, server=$_s."; }

_setup(){
	echo -e "pty \"pptp $_s --nolaunchpppd\"\nname $_u\npassword $_p
unit 7\nlock\nrefuse-pap\nrefuse-eap\nrefuse-chap\nrefuse-mschap\nnobsdcomp\nnopcomp\nnoaccomp\nnovj\nnodeflate\nrequire-mppe-128\nrequire-mschap-v2\npersist\nmaxfail 0\ndefaultroute\nusepeerdns\nnoauth\ndefault-asyncmap\nlcp-echo-interval 15\nlcp-echo-failure 6\nlcp-echo-adaptive\nholdoff 20\nmtu 1400
ip-up-script /var/www/vpn/pptp.up\nip-down-script /var/www/vpn/pptp.dn" > $opts
}

_stop(){
	uci delete network.vpn
	uci commit
	/etc/init.d/network restart
	rm /www/stat/pptp.connected
	[ "$act" == "stop" ] && _return 1 "PPTP stopped."
}

_start(){
	_stop;
	([ -z "$_u" ] || [ -z "$_p" ] || [ -z "$_s" ] ) && _badarg
	_setup;
	/etc/init.d/openvpn stop
	rm /www/stat/ovpn.connected
        uci set network.vpn=interface
        uci set network.vpn.ifname=pptp-vpn
        uci set network.vpn.proto=pptp
        uci set network.vpn.username=$_u
        uci set network.vpn.password=$_p
        uci set network.vpn.server=$_s
        uci set network.vpn.buffering=1
        uci commit
        /etc/init.d/network restart
        touch /www/stat/pptp.connected
#	while [ ! -e /www/stat/pptp.connected ] && [ $timeout -gt 0 ]; do (( timeout-- )); sleep 1; done
	_return 1 "PPTP started.";
}

ls >/dev/null 2>/dev/null || _return 0 "Need Sudo powers."

case $act in
	start)	_start	;;
	stop)	_stop	;;
	*)	_badarg	;;
esac
