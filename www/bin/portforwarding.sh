#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
# iptables rules are stored in /etc/sabai/firewall.settings

#Include JSON parser for OpenWrt
. /usr/share/libubox/jshn.sh

_return(){                                                                                                                  
        echo "res={ sabai: $1, msg: '$2' };"                                                                 
        exit 0                                                                                       
}

action=$1

if [ $action = "update" ]; then
        config_file=sabai-new
else
	config_file=sabai
fi

data=$(cat /tmp/tmppftable)
json_load "$data"
json_select 1   
json_select ..    
json_get_keys keys
num_items=$(echo $keys | sed 's/.*\(.\)/\1/')
uci show firewall >> /tmp/test_fw3
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
		VPN) gateway="vpn"  ;;

		*) echo "INVALID GATEWAY: you're not supposed to get here." ;;
	esac
	num=$(uci show firewall | grep 'redirect' | grep '=portforwarding'$j | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1 )
	if [ $pfenable = "on" ]; then
		if [ "$num" != "" ]; then
			uci delete firewall.@redirect[$num]
			uci commit firewall
      		fi
		
		uci add firewall redirect
		uci set firewall.@redirect[-1].name='portforwarding'$j
      		uci set firewall.@redirect[-1].proto=$protocol

		if [ $gateway == "wan" ]; then
      			uci set firewall.@redirect[-1].src='wan'
			uci set firewall.@redirect[-1].src_ip=$src                                                        
			uci set firewall.@redirect[-1].src_dport=$ext                               
			uci set firewall.@redirect[-1].dest_ip=$address                             
			uci set firewall.@redirect[-1].dest_port=$int
			uci set firewall.@redirect[-1].dest='lan'                                           
			uci set firewall.@redirect[-1].target='DNAT'
	      	elif [ $gateway == "lan" ]; then
			pub_ip=$(cat /etc/sabai/stat/ip | cut -d: -f3 | cut -d "," -f1 | tr -d \")
      			uci set firewall.@redirect[-1].src='lan'
			uci set firewall.@redirect[-1].src_ip=$address
			uci set firewall.@redirect[-1].src_dip=$pub_ip                                          
			uci set firewall.@redirect[-1].src_dport=$int
			uci set firewall.@redirect[-1].dest_ip=$src                                                           
			uci set firewall.@redirect[-1].dest_port=$ext
      			uci set firewall.@redirect[-1].dest='wan'
      			uci set firewall.@redirect[-1].target='SNAT'
      		elif [ $gateway == "vpn" ]; then
      			echo "vpn"
			proto=$(uci get sabai.vpn.proto)                  
        		if [ $proto == "ovpn" ]; then                          
       				echo -e "pass"
			else
				if [ ! -e /etc/sabai/openvpn/ovpn.current ]; then                                     
                                _return 0 "VPN tunnel cant be established. Please, download VPN config file."                                                   
                        	fi
				/www/bin/ovpn.sh config
			fi
			/etc/init.d/openvpn start                                                                     
        		/etc/init.d/openvpn enable
			/etc/init.d/firewall restart
			sleep 10
                        uci set firewall.@redirect[${j}].src_ip=$src #Host from LAN accesses VPN  
	                ifconfig tun0 | grep "inet addr" | cut -d: -f2 | cut -d " " -f1 > /tmp/tun_ip 
			uci set firewall.@redirect[-1].src_dip=$(cat /tmp/tun_ip)                   
			uci set firewall.@redirect[-1].src_dport=$ext
			uci set firewall.@redirect[-1].dest_ip=$address                              
			uci set firewall.@redirect[-1].dest_port=$int 
                        uci set firewall.@redirect[-1].src='lan'                                            
                        uci set firewall.@redirect[-1].dest='sabai'                                         
                        uci set firewall.@redirect[-1].target='SNAT'
	      	else
			echo -e "\n"
		fi
	else
		if [ "$num" != "" ]; then 
			uci delete firewall.@redirect[$num] 
		fi
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
	logger "Port forwarding configs were aplied."

	# Send completion message back to UI
	_return 1 "Port forwarding settings applied"
fi

ls >/dev/null 2>/dev/null
exit 0  
