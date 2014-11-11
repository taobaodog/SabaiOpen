#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

address=$1;
hops=$2;
wait=$3;

rm -rf /www/bin/tmp
mkdir /www/bin/tmp
traceroute $address -m $hops -w $wait> /www/bin/tmp/trace

ls >/dev/null 2>/dev/null 


