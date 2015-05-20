#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
# Creates a json file of wan info and dhcp leases

#Include JSON parser for OpenWrt
. /usr/share/libubox/jshn.sh

#receive the action being asked of the script
action=$1

#path to config files
UCI_PATH="-c /configs"

#Set config for static attribute
_static_on(){                                                                                                                                  
        uci add dhcp host                                                                                                                      
        uci set dhcp.@host[-1].ip=$1                                                                                                           
        uci set dhcp.@host[-1].mac=$2                                                                                                          
        uci set dhcp.@host[-1].name="$3"                                                                                                       
        uci commit dhcp                                                                                                                        
	uci $UCI_PATH add sabai dhcphost                                                        
	uci $UCI_PATH set sabai.@dhcphost[-1].ip=$1                                                                                            
	uci $UCI_PATH set sabai.@dhcphost[-1].mac=$2                                                                                           
	uci $UCI_PATH set sabai.@dhcphost[-1].name="$3"                             
	uci $UCI_PATH set sabai.@dhcphost[-1].route=$4                                          
	uci $UCI_PATH commit sabai 
}

_vpn_on(){
	if [ "$(uci get sabai.vpn.status)" != none ]; then                              
		/www/bin/gw.sh iprules $route $ip                                                                                      
		logger "$1 has vpn route."                                                                                            
	else                                                                            
		logger "VPN is off. $1 has default route."                                                                            
	fi
}

#get dhcp information and build the dhcp table
_get(){
#get wan address and mac
wanip=$(ip route | grep -e "/24 dev eth0" | awk -F: '{print $0}' | awk '{print $5}')
wanmac=$(ifconfig eth0 | grep 'eth0' | awk -F: '{print $0}' | awk '{print $5}')
wanport=$(uci get network.wan.ifname)
wantime="----"

#begin json table with wan port info
echo -n '{"aaData": [{"static": "WAN PORT", "route": "--------", "ip": "'$wanip'", "mac": "'$wanmac'", "name": "WAN PORT", "time": "'$wantime'"}'> /www/libs/data/dhcp.json
echo -n '{"1": {"static": "WAN PORT", "route": "--------", "ip": "'$wanip'", "mac": "'$wanmac'", "name": "WAN PORT", "time": "'$wantime'"}' > /tmp/dhcptable

#continue json table with /tmp/dhcp.leases file info
line_num=1
cat /tmp/dhcp.leases | while read -r line ; do
	line_num=$(( $line_num + 1 ))
	epochtime=$(echo "$line" | awk '{print $1}')
	dhcptime=$(date -d @"$epochtime")
	mac=$(echo "$line" | awk '{print $2}')
	exists=$(uci show dhcp | grep "$mac" | cut -d "[" -f2 | cut -d "]" -f1)
	#static attribute check
	if [ "$exists" = "" ]; then
		ipaddr=$(echo "$line" | awk '{print $3}')
		name=$(echo "$line" | awk '{print $4}')
		static="off"
		route="default"
	else
		ipaddr=$(uci get dhcp.@host["$exists"].ip)
		name=$(uci get dhcp.@host["$exists"].name)
		route=$(uci get sabai.@dhcphost["$exists"].route)
		static="on"
	fi

	echo -n ', {"static": "'$static'", "route": "'$route'", "ip": "'$ipaddr'", "mac": "'$mac'", "name": "'$name'", "time": "'$dhcptime'"}' >> /www/libs/data/dhcp.json
	echo -n ',"'$line_num'":{"static": "'$static'", "route": "'$route'", "ip": "'$ipaddr'", "mac": "'$mac'", "name": "'$name'", "time": "'$dhcptime'"}' >> /tmp/dhcptable
done

#close up the json format
echo -n ']}' >> /www/libs/data/dhcp.json
echo -n '}' >> /tmp/dhcptable

#save table as single line json
uci $UCI_PATH set sabai.dhcp.table="$(cat /www/libs/data/dhcp.json)"
uci $UCI_PATH set sabai.dhcp.tablejs="$(cat /tmp/dhcptable)"
uci $UCI_PATH commit sabai

#clear tmp files
rm /tmp/dhcptable
} #end _get

#Save the modified existing DHCP table
_save(){
if [ $action = "update" ]; then
	uci get sabai-new.dhcp.tablejs > /tmp/tmpdhcptable
else
	uci get sabai.dhcp.tablejs > /tmp/tmpdhcptable
fi

#delete old dhcp settings
hosts=$(uci show dhcp | grep =host | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
while [ $hosts -ge 0 ]
do	
	echo "deleting rule  #$i:"
	uci delete dhcp.@host["$hosts"]
	uci commit dhcp
	hosts=$(( $hosts - 1 ))
done
#delete old sabai dhcp settings
hosts=$(uci $UCI_PATH show sabai | grep =dhcphost | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
while [ $hosts -ge 0 ]
do	
	echo "deleting rule  #$i:"
	uci $UCI_PATH delete sabai.@dhcphost["$hosts"]
	uci $UCI_PATH commit sabai
	hosts=$(( $hosts - 1 ))
done

#adding iprouting tables
/www/bin/gw.sh start

#parsing data from WEB UI
data=$(cat /tmp/tmpdhcptable)
json_load "$data"
json_select 1 
json_select ..
json_get_keys keys
num_items=$(echo $keys | sed 's/.*\(.\)/\1/')
i=1
while [ $i -le $num_items ]
do	
	echo "processing rule  #$i:"
	json_select $i                           
        json_get_var static static
	json_get_var route route
	json_get_var ip ip
	json_get_var mac mac
	json_get_var name name
	json_get_var leasetime leasetime

	#clear firewall rules
	rule_name=$(uci show firewall | grep "$ip" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	[ -n "$rule_name" ] && uci delete firewall.@rule[$rule_name] && uci commit firewall

        if [ "$static" = "on" ]; then                                                                                                          
                _static_on $ip $mac $name $route                                                                                               
                logger "$ip set to Static IP."                                      
        else                                                                                    
                logger "$ip is not Static."                                                                                                    
        fi
	#defining route
	if [ "$route" = "vpn_fallback" ]; then 
		_vpn_on $ip
	elif [ "$route" = "vpn_only" ]; then
		_vpn_on $ip
		uci add firewall rule
		uci set firewall.@rule[-1].src=lan
		uci set firewall.@rule[-1].dest=wan
		uci set firewall.@rule[-1].src_ip=$ip
		uci set firewall.@rule[-1].target=REJECT
		uci commit firewall
		logger "Only VPN traffic for $ip allowed."
	elif ([ "$route" = "accelerator" ] || [ "$route" = "internet" ]); then
		/www/bin/gw.sh iprules $route $ip
		logger "$ip has $route route."
	else
		#default
		logger "$ip has $route route."
	fi
	json_select ..
	i=$(( $i + 1 ))
done

if [ $action = "update" ]; then
	echo "firewall" >> /tmp/.restart_services
	echo "dnsmasq" >> /tmp/.restart_services
else
	/etc/init.d/firewall restart
	logger "dhcp settings applied and firewall restarted"

	ls >/dev/null 2>/dev/null 

	# Send completion message back to UI
	echo "res={ sabai: 1, msg: 'DHCP settings applied' }"
fi

#cleanup
rm /tmp/table*
rm /tmp/tmpdhcptable
}

# Creates a json object creating dhcp table data
_json() {
	sed 's/\"1\"\:/\"aaData\"\:\[/g' /tmp/table1 > /tmp/table2
	sed -E 's/\"([0-9])\"\://g' /tmp/table2 > /tmp/table3
	sed 's/\}\}/\}\]\}/g' /tmp/table3 > /tmp/table4
	aaData=$(cat /tmp/table4)
	jsData=$(cat /tmp/table1)

	#save table as single line json
	uci $UCI_PATH set sabai.dhcp.tablejs="$jsData"
	uci $UCI_PATH set sabai.dhcp.table="$aaData"
	uci $UCI_PATH commit sabai
}


ls >/dev/null 2>/dev/null 

case $action in
	json)	_json	;;
	get)	_get	;;
	save)	_save	;;
	update)	_save	;;
esac
