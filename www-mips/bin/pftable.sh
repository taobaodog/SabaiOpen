#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2016 Sabai Technology
UCI_PATH="-c /etc/config"

#convert table to single line json aaData variable
#calling program has already put table into /tmp/table1
#remove blank field holders from GUI data  
sed 's/Click to edit//g' /tmp/table1 > /tmp/table2
sed 's/\"1\"\:/\"aaData\"\:\[/g' /tmp/table2 > /tmp/table3
sed -E 's/\"([0-9])\"\://g' /tmp/table3 > /tmp/table4
sed 's/\}\}/\}\]\}/g' /tmp/table4 > /tmp/table5

aaData=$(cat /tmp/table5)
jsData=$(cat /tmp/table2)
#save table as single line json
uci $UCI_PATH set sabai.pf.tablejs="$jsData"
uci $UCI_PATH set sabai.pf.table="$aaData"
uci $UCI_PATH commit sabai

#cleanup
rm /tmp/table*

#ensure that messages are not sent to console
ls >/dev/null 2>/dev/null 

# Send completion message back to UI
echo "res={ sabai: 1, msg: 'Table Fixed' };"
