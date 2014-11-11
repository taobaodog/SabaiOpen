#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

table=$(cat /tmp/table)
sed 's/\"1\"\:/\"aaData\"\:\[/g' /tmp/table > /tmp/aatable
sed -E 's/\"([0-9])\"\://g' /tmp/aatable > /tmp/denumtable
sed 's/\}\}/\}\]\}/g' /tmp/denumtable > /tmp/fixedtable
aaData=$(cat /tmp/fixedtable)
cp /tmp/fixedtable /www/libs/ptrs/port_forwarding.json
uci set sabai.pf.table=$(cat /tmp/fixedtable)
uci commit

ls >/dev/null 2>/dev/null 

# Send completion message back to UI
echo "res={ sabai: 1, msg: 'Table Fixed' };"