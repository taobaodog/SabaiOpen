#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
# Creates a json file of wan info and dhcp leases

#receive the action being asked of the script
act=$1

#get dhcp information and build the dhcp table
_get(){
#get wan address and mac
wanip=$(ip route | grep -e "/24 dev eth0" | awk -F: '{print $0}' | awk '{print $5}')
wanmac=$(ifconfig eth0 | grep 'eth0' | awk -F: '{print $0}' | awk '{print $5}')
wanport=$(cat /tmp/wan)
wantime="----"

#begin json table with wan port info
echo -n '{"aaData": [{"static": "WAN PORT", "ip": "'$wanip'", "mac": "'$wanmac'", "name": "WAN PORT", "time": "'$wantime'"}'  > /www/libs/data/dhcp.json

#continue json table with /tmp/dhcp.leases file info
cat /tmp/dhcp.leases | while read -r line ; do
	epochtime=$(echo "$line" | awk '{print $1}')
    dhcptime=$(date -d @"$epochtime")
    mac=$(echo "$line" | awk '{print $2}')
    ipaddr=$(echo "$line" | awk '{print $3}')
    name=$(echo "$line" | awk '{print $4}')
echo -n ', {"static": "off", "ip": "'$ipaddr'", "mac": "'$mac'", "name": "'$name'", "time": "'$dhcptime'"}' >> /www/libs/data/dhcp.json
done

#close up the json format
echo -n ']}' >> /www/libs/data/dhcp.json

#save table as single line json
uci set sabai.dhcp.table="$(cat /www/libs/data/dhcp.json)"
uci commit
}
#end _get

_static_on(){
	uci add dhcp host
	uci set dhcp.@host[-1].ip=$ip;
	uci set dhcp.@host[-1].mac=$mac;
	uci set dhcp.@host[-1].name=$name;
	uci commit;
}

#Save the modified existing DHCP table
_save(){
#convert table to single line json aaData variable
table=$(cat /tmp/table1)
sed 's/\"1\"\:/\"aaData\"\:\[/g' /tmp/table1 > /tmp/table2
sed -E 's/\"([0-9])\"\://g' /tmp/table2 > /tmp/table3
sed 's/\}\}/\}\]\}/g' /tmp/table3 > /tmp/table4
aaData=$(cat /tmp/table4)

#save table as single line json
uci set sabai.dhcp.table="$(cat /tmp/table4)"
uci commit

# beginning

uci get sabai.dhcp.table > /tmp/tmpdhcptable

# delete old dhcp settings
#uci delete dhcp.@host[]
#while [ $? -ne 0 ]; do
#    uci delete dhcp.@host[]
#done

num_items=$(/www/bin/jsawk 'return this.aaData.length' < /tmp/tmpdhcptable);
echo "num items is $num_items" > /tmp/feedback
i=1

while [ $i -le $num_items ]
do	
	echo "processing rule  #$i:"
	static=$(/www/bin/jsawk 'return this.aaData[0].static' < /tmp/tmpdhcptable);
	ip=$(/www/bin/jsawk 'return this.aaData[0].ip' < /tmp/tmpdhcptable);
	mac=$(/www/bin/jsawk 'return this.aaData[0].mac' < /tmp/tmpdhcptable);
	name=$(/www/bin/jsawk 'return this.aaData[0].name' < /tmp/tmpdhcptable);
	leasetime=$(/www/bin/jsawk 'return this.aaData[0].time' < /tmp/tmpdhcptable);
	
	if [ "$static" = "on" ]; then
               _static_on;
            fi

	i=$(( $i + 1 ))
done

#cleanup
#rm /tmp/tmpdhcptable

echo "exiting"
exit 0

uci commit;
/etc/init.d/firewall restart
logger "portforwarding set and firewall restarted"

ls >/dev/null 2>/dev/null 

# Send completion message back to UI
echo "res={ sabai: 1, msg: 'Port forwarding settings applied' };"


# end



#cleanup
rm /tmp/table*

}

ls >/dev/null 2>/dev/null 

case $act in
	get)	_get	;;
	save)	_save	;;
esac