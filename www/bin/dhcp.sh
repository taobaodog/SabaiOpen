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

#get dhcp information and build the dhcp table
_get(){
#get wan address and mac
wanip=$(ip route | grep -e "/24 dev eth0" | awk -F: '{print $0}' | awk '{print $5}')
wanmac=$(ifconfig eth0 | grep 'eth0' | awk -F: '{print $0}' | awk '{print $5}')
wanport=$(uci get network.wan.ifname)
wantime="----"

#begin json table with wan port info
echo -n '{"aaData": [{"static": "WAN PORT", "route": "--------", "ip": "'$wanip'", "mac": "'$wanmac'", "name": "WAN PORT", "time": "'$wantime'"}'> /www/libs/data/dhcp.json
#continue json table with /tmp/dhcp.leases file info
cat /tmp/dhcp.leases | while read -r line ; do
    epochtime=$(echo "$line" | awk '{print $1}')
    dhcptime=$(date -d @"$epochtime")
    mac=$(echo "$line" | awk '{print $2}')
    exists=$(uci show dhcp | grep "$mac" | cut -d "[" -f2 | cut -d "]" -f1)

    if ["$exists" = ""]; then
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
done

#close up the json format
echo -n ']}' >> /www/libs/data/dhcp.json
#save table as single line json
uci $UCI_PATH set sabai.dhcp.table="$(cat /www/libs/data/dhcp.json)"
uci $UCI_PATH commit sabai
} #end _get

_static_on(){
	uci add dhcp host
	uci set dhcp.@host[-1].ip=$ip
	uci set dhcp.@host[-1].mac=$mac
	uci set dhcp.@host[-1].name="$name"
	uci commit dhcp
	uci $UCI_PATH add sabai dhcphost
	uci $UCI_PATH set sabai.@dhcphost[-1].ip=$ip
	uci $UCI_PATH set sabai.@dhcphost[-1].mac=$mac
	uci $UCI_PATH set sabai.@dhcphost[-1].name="$name"
	uci $UCI_PATH set sabai.@dhcphost[-1].route=$route
	uci $UCI_PATH commit sabai
}

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

data=$(cat /tmp/tmpdhcptable)
json_load "$data"
json_select 1
json_select ..
json_get_keys keys
num_items=$(echo $keys | sed 's/.*\(.\)/\1/')
echo $num_items
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
	if [ "$route" = "internet" ] || [ "$route" = "vpn_fallback" ] || [ "$route" = "vpn_only" ] || [ "$static" = "on" ]; then
		_static_on;
	fi
	i=$(( $i + 1 ))
done

#cleanup
rm /tmp/tmpdhcptable

echo "exiting"
exit 0


if [ $action = "update" ]; then
	echo "firewall" >> /tmp/.restart_services
	echo "dnsmasq" >> /tmp/.restart_services
	echo `cat /tmp/.restart_services`
else
	# /www/bin/gw.sh start
	/etc/init.d/dnsmasq restart
	/etc/init.d/firewall restart
	logger "portforwarding set and firewall restarted"

	ls >/dev/null 2>/dev/null 

	# Send completion message back to UI
	echo "res={ sabai: 1, msg: 'Port forwarding settings applied' };"
fi

# end
#cleanup
rm /tmp/table*

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

	# Send completion message back to UI
	echo "res={ sabai: 1, msg: 'Table Fixed' };"

}


ls >/dev/null 2>/dev/null 

case $action in
	json)	_json	;;
	get)	_get	;;
	save)	_save	;;
	update)	_save	;;
esac
