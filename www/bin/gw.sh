#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
UCI_PATH="-c /configs"

# send messages to log file but clear log file on each new setup of gw.sh
#rm /var/log/sabaigw.log; exec 2>&1; exec 1>/var/log/sabaigw.log;

#find our local network, minus last octet.  For example 192.168.199.1 becomes 192.168.199
lan_prefix="$(uci get network.lan.ipaddr | cut -d '.' -f1,2,3)"; 

#get the current server address for sabaitechnology.biz for address services
sabaibiz="$(nslookup sabaitechnology.biz | grep "Address 1:" | cut -d':' -f2 | awk '{print $1}' | awk '{print $1}' | tail -n 1)";

#clear the old ip routes
_fin(){ ip route flush cache; }

#flush the tables on stopping gateways
_stop(){
	for i in 1 2 3 4; do ip route flush table $i; done
	ip rule | grep "$lan_prefix" | cut -d':' -f2 | while read old_rule; do ip rule del $old_rule; done
	_fin
}

_start(){
	#clear old settings
	_stop
	#add routing tables
	for i in 1 2 3 4; do ip route add "$lan_prefix.0/24" dev br-lan table $i; done
	wan_gateway="$(uci get network.wan.gateway)"; wan_iface="$(uci get network.wan.ifname)";
	#([ -z "$wan_gateway" ] || [ "$wan_gateway" == "0.0.0.0" ]) && wan_gateway="$(uci get network.wan.gateway)"

	#adding wan route to 1 table
	[ -n "$wan_iface" ] && ([ -n "$wan_gateway" ] && [ "$wan_gateway" != "0.0.0.0" ]) && ip route add default via $wan_gateway dev $wan_iface table 1

	#ensure that accelerator IP is set
	if [ "$(uci get sabai.general.ac_ip)" = "" ]; then
		uci $UCI_PATH set sabai.general.ac_ip=2
		uci $UCI_PATH commit sabai
	fi
	# adding route to the accelerator to 2 table 
 	ip route add default via "$lan_prefix.$(uci get sabai.general.ac_ip)" dev br-lan table 4 
	if [ "$(ifconfig | grep tun0)" != "" ]; then
  		vpn_device="tun0"
  		vpn_gateway="$(ifconfig tun0 | grep P-t-P: | awk '{print $3}' | sed 's/P-t-P://g')"
  		ip route add $vpn_gateway dev $vpn_device
		ip route | grep $vpn_device | while read vpn_rt; do ip route add $vpn_rt table 2; done
		ip route del $vpn_gateway dev $vpn_device
		ip route add $sabaibiz dev $vpn_device
	elif [ "$(ifconfig | grep pptp-vpn)" != "" ]; then
		vpn_device="pptp-vpn";                                                                    
                vpn_gateway="$(ifconfig pptp-vpn | grep P-t-P: | awk '{print $3}' | sed 's/P-t-P://g')";                                       
                ip route add $vpn_gateway dev $vpn_device                                                                                      
                ip route | grep $vpn_device | while read vpn_rt; do ip route add $vpn_rt table 2; done             
                ip route del $vpn_gateway dev $vpn_device                                             
                ip route add $sabaibiz dev $vpn_device
	else
		logger "no vpn route table was added."
	fi

	#adding vpn-only route table
#	[ "$(ifconfig | grep tun0)" != "" ] && (vpn_device="tun0"; vpn_gateway="$(ifconfig tun0 | grep P-t-P: | awk '{print $3}' | sed 's/P-t-P://g')") 
#	[ "$vpn_device" = "tun0" ] && [ -n "$vpn_gateway" ] && ip route add $vpn_gateway dev $vpn_device && ip route add default via $vpn_gateway dev $vpn_device table 3 
#	[ "$(ifconfig | grep pptp-vpn)" != "" ]	&& (vpn_device="pptp-vpn"; vpn_gateway="$(ifconfig pptp-vpn | grep P-t-P: | awk '{print $3}' | sed 's/P-t-P://g')";)
#	[ "$vpn_device" = "pptp-vpn" ] && [ -n "$vpn_gateway" ] && ip route add default via $sabaibiz dev $vpn_device table 3
	
#	ip rule | grep "$lan_prefix" | cut -d':' -f2 | while read old_rule; do ip rule del $old_rule; done
#	[ ! "$default" -eq 0 ] && ip rule add from "$lan_prefix.1/24" table $default
#	echo $default
}

_ip_rules(){
        #assign statics to ip rules                                                                                                            
	echo "iprules"
	case $1 in
		internet)
			ip rule add from "$2" table 1
		;;
		vpn_fallback)
			ip rule add from "$2" table 2
			logger "VPN connection is up. $2 is connected to vpn_fallback option."
		;;
		vpn_only)
			echo "3"; ip rule add from "$2" table 3
		;;
		accelerator)
			echo "4"; ip rule add from "$2" table 4
		;;
        esac

	_fin

}

_ds(){ /etc/init.d/dnsmasq restart; _start; }

case $1 in
	stop)	_stop	;;
	start)	_start	;;
	ds)	_ds	;;
	iprules) _ip_rules $2 $3 ;;
esac
