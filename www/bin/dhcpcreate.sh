#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
# Creates a json object creating dhcp table data

#convert table to single line json aaData variable
table=$(cat /tmp/table1)
sed 's/\"1\"\:/\"aaData\"\:\[/g' /tmp/table1 > /tmp/table2
sed -E 's/\"([0-9])\"\://g' /tmp/table2 > /tmp/table3
sed 's/\}\}/\}\]\}/g' /tmp/table3 > /tmp/table4
aaData=$(cat /tmp/table4)

#save table as single line json
uci set sabai.dhcp.table="$(cat /tmp/table4)"
uci commit