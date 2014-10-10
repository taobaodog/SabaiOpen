#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
# iptables rules are stored in /etc/sabai/firewall.settings

#TODO remove debug echos
uci get sabai.pf.table > /tmp/tmppftable

num_items=$(/www/bin/jsawk 'return this.aaData.length' < /tmp/tmppftable);
i=1

while [ $i -le $num_items ]
do	
	echo "processing rule  #$i:"
	pfenable=$(/www/bin/jsawk 'return this.aaData[0].status' < /tmp/tmppftable);
	protocol=$(/www/bin/jsawk 'return this.aaData[0].protocol' < /tmp/tmppftable);
	gateway=$(/www/bin/jsawk 'return this.aaData[0].gateway' < /tmp/tmppftable);
	src=$(/www/bin/jsawk 'return this.aaData[0].src' < /tmp/tmppftable);
	ext=$(/www/bin/jsawk 'return this.aaData[0].ext' < /tmp/tmppftable);
	int=$(/www/bin/jsawk 'return this.aaData[0].int' < /tmp/tmppftable);
	address=$(/www/bin/jsawk 'return this.aaData[0].address' < /tmp/tmppftable);
	description=$(/www/bin/jsawk 'return this.aaData[0].description' < /tmp/tmppftable);

	echo "src=$src"
	
	case $protocol in
		Both) protocol="tcp udp" ;;
		UDP) protocol="udp"  ;;
		TCP) protocol="tcp"  ;;

		*) echo "INVALID PROTOCOL: you're not supposed to get here." ;;
	esac	
	echo "protocol=$protocol"

	case $gateway in
		WAN) gateway="wan" ;;
		LAN) gateway="lan"  ;;
		#TODO check if there's such option
		VPN) gateway="vpn"  ;;

		*) echo "INVALID GATEWAY: you're not supposed to get here." ;;
	esac	
	echo "gateway=$gateway"

	if [ $pfenable = "on" ]; then
		echo "condition 1" >> /tmp/portforwarding
      	uci add firewall redirect
      	#FIXME dummy name, generate correct name
      	uci set firewall.@redirect[${i}].name='dummyname'
      	#FIXME 'tcpudp' or 'tcp udp'
      	uci set firewall.@redirect[${i}].proto='$protocol'
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
		fi
		uci set firewall.@redirect[${i}].dest_ip='$address'
		uci set firewall.@redirect[${i}].dest_port='$ext' #ext port
		
	else
		uci delete firewall.@redirect[${i}] 
		echo "condition 2" >> /tmp/portforwarding
		break
	fi
	i=$(( $i + 1 ))
done

#cleanup
rm /tmp/tmppftable

echo "exiting"
exit 0

uci commit;
/etc/init.d/firewall restart

ls >/dev/null 2>/dev/null 

# Send completion message back to UI
echo "res={ sabai: 1, msg: 'Port forwarding settings applied' };"
