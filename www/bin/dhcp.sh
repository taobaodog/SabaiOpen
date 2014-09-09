#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
# Creates a json file of wan info and dhcp leases

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

ls >/dev/null 2>/dev/null 