#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
# iptables rules are stored in /etc/sabai/firewall.settings

#Include JSON parser for OpenWrt
. /usr/share/libubox/jshn.sh

#TODO remove debug echos

action=$1

if [ $action = "update" ]; then
        config_file=sabai-new
else
	config_file=sabai
fi

uci get $config_file.pf.tablejs > /tmp/tmppftable
data=$(cat /tmp/tmppftable)
json_load "$data"
json_select 1   
json_select ..    
json_get_keys keys
num_items=$(echo $keys | sed 's/.*\(.\)/\1/')

i=1
j=0
while [ $i -le $num_items ]; do
	echo "processing rule  #$i:"
	json_select $i
        json_get_var pfenable status
        json_get_var protocol protocol
        json_get_var gateway gateway
        json_get_var src src        
        json_get_var ext ext        
        json_get_var int int        
        json_get_var address address
        json_get_var description description

	case $protocol in
		Both) protocol="tcpudp" ;;
		UDP) protocol="udp"  ;;
		TCP) protocol="tcp"  ;;

		*) echo "INVALID PROTOCOL: you're not supposed to get here." ;;
	esac	

	case $gateway in
		WAN) gateway="wan" ;;
		LAN) gateway="lan"  ;;
		#TODO check if there's such option
		VPN) gateway="vpn"  ;;

		*) echo "INVALID GATEWAY: you're not supposed to get here." ;;
	esac	

	if [ $pfenable = "on" ]; then
		check=$(uci show firewall | grep 'redirect' | grep '=portforwarding'$j)
		echo $check
		if [ "$check" != "" ]; then
			uci delete firewall.@redirect[${j}]
      		fi
		uci add firewall redirect
		uci set firewall.@redirect[${j}].name='portforwarding'$j
      		uci set firewall.@redirect[${j}].proto=$protocol
	
		if [ $gateway == "wan" ]; then
      			uci set firewall.@redirect[${j}].src='wan'
      			uci set firewall.@redirect[${j}].dest='lan'
      			uci set firewall.@redirect[${j}].target='DNAT'
      			uci set firewall.@redirect[${j}].src_dport=$int #int port
      	elif [ $gateway == "lan" ]; then
      			uci set firewall.@redirect[${j}].src='lan'
      			uci set firewall.@redirect[${j}].dest='wan'
      			uci set firewall.@redirect[${j}].target='SNAT'
      	elif [ $gateway == "vpn" ]; then
      			echo "not implemented yet"
      			#TODO openvpn setup
      			#uci set openvpn.sabai....
      	else
			echo -e \n
		fi
	
		if [ "$src" != "Click to edit" ]; then
			uci set firewall.@redirect[${j}].src_ip=$src #optional parameters
			uci set firewall.@redirect[${j}].dest_ip=$address
			uci set firewall.@redirect[${j}].dest_port=$ext #ext port
		fi
	else
		uci delete firewall.@redirect[${j}] 
		echo "condition 2" >> /tmp/portforwarding
	fi

	json_select .. 
	i=$(( $i + 1 ))
	j=$(( $j + 1 ))
	uci commit firewall
done

#cleanup
rm /tmp/tmppftable

uci commit
if [ $action = "update" ]; then
	echo "firewall" >> /tmp/.restart_services
else
	/etc/init.d/firewall restart
	logger "portforwarding set and firewall restarted"

	# Send completion message back to UI
	echo "res={ sabai: 1, msg: 'Port forwarding settings applied' };"
fi

ls >/dev/null 2>/dev/null
exit 0  
