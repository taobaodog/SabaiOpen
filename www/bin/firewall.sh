#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
# iptables rules are stored in /etc/sabai/firewall.settings

icmp=$1;
multicast=$2;
cookies=$3;
wanroute=$4;
wanport=$(uci get network.wan.ifname);

#set wan response to ping
if [ $icmp = "on" ]; then
	#turn on icmp response on wan side
else
	#turn off icmp response on wan side
fi

#set ability to receive multicast
if [ $multicast = "on" ]; then
	#turn on multicast
else
	# turn off multicast
fi

#set syn cookie preference
if [ $cookies = "on" ]; then
	#allow syn cookies
else
	#turn off syn cookies
fi

#allow WAN route input
if [ $wanroute = "on" ]; then
	#turn on ability for wan input 
else
	#ensure wan input is turned off
fi

uci commit;
# restart any services like firewall or network that need it.


ls >/dev/null 2>/dev/null 