#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology
UCI_PATH="-c /configs"

# send messages to log file but clear log file on each new setup of gw.sh
#rm /var/log/sabaigw.log; exec 2>&1; exec 1>/var/log/sabaigw.log;

#find our local network, minus last octet.  For example 192.168.199.1 becomes 192.168.199
lan_prefix="$(uci get network.lan.ipaddr | cut -d '.' -f1,2,3)"; 

#TODO: Unused functionality for now.
#get the current server address for sabaitechnology.biz for address services
#sabaibiz="$(nslookup sabaitechnology.biz | grep "Address 1:" | cut -d':' -f2 | awk '{print $1}' | awk '{print $1}' | tail -n 1)";

_check_static(){
	[ -n "$(uci show sabai | grep $1)" ] && sed -i "8i\/usr/sbin/ip rule add from "$1" table $2" /etc/rc.local
}

#configure vpn route table
_vpn_config(){
  	ip route add $2 dev $1
	ip route | grep $1 | while read vpn_rt; do ip route add $vpn_rt table vpn; done
	ip route del $2 dev $1
}

_vpn_start(){
	if [ "$(ifconfig | grep tun0)" != "" ]; then
		vpn_device="tun0"
		vpn_gateway="$(ifconfig tun0 | grep P-t-P: | awk '{print $3}' | sed 's/P-t-P://g')"
                _vpn_config $vpn_device $vpn_gateway
	elif [ "$(ifconfig | grep pptp-vpn)" != "" ]; then
		vpn_device="pptp-vpn";
		vpn_gateway="$(ifconfig pptp-vpn | grep P-t-P: | awk '{print $3}' | sed 's/P-t-P://g')";
		_vpn_config $vpn_device $vpn_gateway
        else
                logger "NO VPN route table was added."
	fi
}

#clear the old ip routes
_fin(){ ip route flush cache; }

#flush the tables on stopping gateways
_stop(){
	start_line=8
	for i in wan acc vpn; do ip route flush table $i; done
	ip rule | grep "$lan_prefix" | cut -d':' -f2 | while read old_rule; do ip rule del $old_rule; done
	ip_rules="$(grep -n -m 1 "exit 0" /etc/rc.local |sed  's/\([0-9]*\).*/\1/')"
	echo $ip_rules
	[ -n "$ip_rules" ] && [ "$ip_rules" -gt "$start_line" ] && sed -i ""$start_line","$(( ip_rules - 1 ))"d" /etc/rc.local
	_fin
}

_start(){
	#clear old settings
	[ -z "$1" ] && _stop
	#add routing tables
	for i in wan acc vpn; do ip route add "$lan_prefix.0/24" dev br-lan table $i; done
	wan_gateway="$(uci get network.wan.gateway)"; wan_iface="$(uci get network.wan.ifname)";
	#adding wan route to 1 table
	[ -n "$wan_iface" ] && ([ -n "$wan_gateway" ] && [ "$wan_gateway" != "0.0.0.0" ]) && ip route add default via $wan_gateway dev $wan_iface table wan 
	#ensure that accelerator IP is set
	if [ "$(uci get sabai.general.ac_ip)" = "" ]; then
		uci $UCI_PATH set sabai.general.ac_ip=2
		uci $UCI_PATH commit sabai
	fi
	# adding route to the accelerator to 2 table 
	
	ip route add default via "$lan_prefix.$(uci get sabai.general.ac_ip)" dev br-lan table acc
	# adding VPN route to table 3
	_vpn_start
}

_ip_rules(){
	#setting priority 
	val_prio=2
        #assign statics to ip rules                                                                                                            
	case $1 in
		local)
			ip rule add prio $val_prio from "$2" table wan 
			_check_static $2 wan
		;;
		vpn_fallback)
			ip rule add prio $val_prio from "$2" table vpn
			_check_static $2 vpn
			logger "$2 is connected to vpn_fallback option."
		;;
		vpn_only)
			ip rule add prio $val_prio from "$2" table vpn
			_check_static $2 vpn
		;;
		accelerator)
			ip rule add prio $val_prio from "$2" table acc
			_check_static $2 acc
		;;
        esac

	_fin

}

_ds(){ /etc/init.d/dnsmasq restart; _start; }

case $1 in
	stop)	_stop		;;
	start)	_start $2	;;
	ds)	_ds		;;
	vpn_gw)	_vpn_start	;;
	iprules) _ip_rules $2 $3 ;;
esac
