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
echo -n '{"aaData": [{"ip": "'$wanip'", "mac": "'$wanmac'", "name": "'$wanport'", "time": "'$wantime'"}'  > /www/libs/data/dhcp.json

#continue json table with /tmp/dhcp.leases file info
cat /tmp/dhcp.leases | while read -r line ; do
	epochtime=$(echo "$line" | awk '{print $1}')
    dhcptime=$(date -d @"$epochtime")
    mac=$(echo "$line" | awk '{print $2}')
    ipaddr=$(echo "$line" | awk '{print $3}')
    name=$(echo "$line" | awk '{print $4}')
echo -n ', {"ip": "'$ipaddr'", "mac": "'$mac'", "name": "'$name'", "time": "'$dhcptime'"}' >> /www/libs/data/dhcp.json
done

#close up the json format
echo -n ']}' >> /www/libs/data/dhcp.json

#save table as single line json
uci set sabai.dhcp.table="$(cat /www/libs/data/dhcp.json)"
uci commit
}
#end _get

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

#cleanup
rm /tmp/table*

}

ls >/dev/null 2>/dev/null 

case $act in
	get)	_get	;;
	save)	_save	;;
esac