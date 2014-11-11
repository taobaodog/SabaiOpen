#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

#convert table to single line json aaData variable
#calling program has already put table into /tmp/table1
sed 's/\"1\"\:/\"aaData\"\:\[/g' /tmp/table1 > /tmp/table2
sed -E 's/\"([0-9])\"\://g' /tmp/table2 > /tmp/table3
sed 's/\}\}/\}\]\}/g' /tmp/table3 > /tmp/table4
#remove blank field holders from GUI data
sed 's/Click to edit//g' /tmp/table4 > /tmp/table5
aaData=$(cat /tmp/table5)

#save table as single line json
uci set sabai.pf.table="$aaData"
uci commit

#cleanup
rm /tmp/table*

#ensure that messages are not sent to console
ls >/dev/null 2>/dev/null 

# Send completion message back to UI
echo "res={ sabai: 1, msg: 'Table Fixed' };"