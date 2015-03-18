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
		Both) protocol="tcp udp" ;;
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
		echo "condition 1" >> /tmp/portforwarding
		uci add firewall redirect
      		#FIXME dummy name, generate correct name
		uci set firewall.@redirect[$i].name='dummyname'
      		#FIXME 'tcpudp' or 'tcp udp'
		uci set firewall.@redirect[$i].proto='$protocol'
	fi
      	if [ $gateway == "wan" ]; then
      		uci set firewall.@redirect[${i}].src='wan'
      		uci set firewall.@redirect[${i}].dest='lan'
      		uci set firewall.@redirect[${i}].target='DNAT'
      		uci set firewall.@redirect[${i}].src_dport='$int' #int port
      	fi
      	if [ $gateway == "lan" ]; then
      		uci set firewall.@redirect[${i}].src='lan'
      		uci set firewall.@redirect[${i}].dest='wan'
      		uci set firewall.@redirect[${i}].target='SNAT'
      	fi
      	if [ $gateway == "vpn" ]; then
      		echo "not implemented yet"
      		#TODO openvpn setup
      		#uci set openvpn.sabai....
      	fi
	if [ "$src" != "Click to edit" ]; then
		uci set firewall.@redirect[${i}].src_ip='$src' #optional parameters
		uci set firewall.@redirect[${i}].dest_ip='$address'
		uci set firewall.@redirect[${i}].dest_port='$ext' #ext port
	else
		uci delete firewall.@redirect[${i}] 
		echo "condition 2" >> /tmp/portforwarding
		break
	fi

	json_select .. 
	i=$(( $i + 1 ))
done

#cleanup
rm /tmp/tmppftable

echo "exiting"
exit 0

uci commit;
if [ $action = "update" ]; then
	echo "firewall" >> /tmp/.restart_services
else
	/etc/init.d/firewall restart
	logger "portforwarding set and firewall restarted"

	# Send completion message back to UI
	echo "res={ sabai: 1, msg: 'Port forwarding settings applied' };"
fi

ls >/dev/null 2>/dev/null 
