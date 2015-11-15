#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology

address=$1;
size=$2;
count=$3;

rm -rf bin/tmp
mkdir bin/tmp
ping $address -c $count -s $size > /www/bin/tmp/ping

ls >/dev/null 2>/dev/null 


