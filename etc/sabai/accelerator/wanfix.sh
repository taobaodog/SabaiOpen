#!/bin/sh
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology

route="$(ip route | grep eth0 | grep '.0/' | awk '{print $1}')"
iptables -I FORWARD -s $route -o tun+ -j ACCEPT
iptables -I FORWARD -s $route -o ppp+ -j ACCEPT
iptables -t nat -I POSTROUTING -o ppp+  -j MASQUERADE
iptables -t nat -I POSTROUTING -o tun+  -j MASQUERADE
