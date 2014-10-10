#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

act=$1

_stop(){
	uci delete network.vpn
	uci delete firewall.vpn
	uci set sabai.vpn.status=none
	uci commit
	/etc/init.d/network restart
	/etc/init.d/firewall restart
    logger "pptp stopped and firewall restarted"
}

_start(){
	#ensure that openvpn is stopped
		/etc/init.d/openvpn stop
	#get the pptp settings
		user=$(uci get sabai.vpn.username)
		pass=$(uci get sabai.vpn.password)
		server=$(uci get sabai.vpn.server)
	#set the network vpn settings
        uci set network.vpn=interface
        uci set network.vpn.ifname=pptp-vpn
        uci set network.vpn.proto=pptp
        uci set network.vpn.username="$user"
        uci set network.vpn.password="$pass"
        uci set network.vpn.server="$server"
        uci set network.vpn.buffering=1
        uci set sabai.vpn.status=pptp
    #set the firewall
        uci set firewall.vpn=zone
        uci set firewall.vpn.name=vpn
        uci set firewall.vpn.input=ACCEPT
        uci set firewall.vpn.output=ACCEPT
        uci set firewall.vpn.forward=ACCEPT
        uci set firewall.vpn.masq=1
        uci set firewall.@forwarding[-1].src=lan
        uci set firewall.@forwarding[-1].dest=vpn
    #commit all changed services
        uci commit   
    #restart services
        /etc/init.d/network restart
    	/etc/init.d/firewall restart
        logger "pptp run and firewall restarted"
}

_clear(){
		uci delete network.vpn
		uci delete firewall.vpn
		uci delete sabai.vpn.username
		uci delete sabai.vpn.password
		uci delete sabai.vpn.server
		uci set sabai.vpn.status=none
        uci commit
        /etc/init.d/network restart
    	/etc/init.d/firewall restart
        logger "pptp cleared and firewall restarted"
}

ls >/dev/null 2>/dev/null 

case $act in
	start)	_start	;;
	stop)	_stop	;;
	clear)  _clear  ;;
esac