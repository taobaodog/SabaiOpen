#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
# to do: Move iptables rules to /etc/sabai/firewall.settings

icmp=$1;
multicast=$2;
cookies=$3;
wanroute=$4;
wan=$(uci get network.wan.ifname);

#set wan response to ping
if [$icmp = "checked" ]; then
	echo "iptables -A input_rule -i $WAN -p icmp -m icmp --icmp-type  echo-request -m limit --limit 10/s -m length --length 1:150 -j ACCEPT" >> /etc/sabai/firewall.settings
else
	grep -v "iptables -D input_rule -i $WAN -p icmp -m icmp --icmp-type  echo-request -m limit --limit 10/s -m length --length 1:150 -j ACCEPT" /etc/sabai/firewall/settings > /tmp/firewall.settings; 
	mv /tmp/firewall.settings /etc/sabai/firewall.settings; 
	rm /tmp/firewall.settings
fi

#set ability to receive multicast
if [ $multicast = "checked" ]; then
	iptables -A INPUT -s 224.0.0.0/4 -j ACCEPT
	iptables -A INPUT -d 224.0.0.0/4 -j ACCEPT
	iptables -A INPUT -s 240.0.0.0/5 -j ACCEPT
	iptables -A INPUT -m pkttype --pkt-type multicast -j ACCEPT
	iptables -A INPUT -m pkttype --pkt-type broadcast -j ACCEPT
else
	iptables -D INPUT -s 224.0.0.0/4 -j ACCEPT
	iptables -D INPUT -d 224.0.0.0/4 -j ACCEPT
	iptables -D INPUT -s 240.0.0.0/5 -j ACCEPT
	iptables -D INPUT -m pkttype --pkt-type multicast -j ACCEPT
	iptables -D INPUT -m pkttype --pkt-type broadcast -j ACCEPT
fi

#set syn cookie preference
if [ $icmp = "checked" ]; then
	iptables -A input_rule -i $WAN -p icmp -m icmp --icmp-type  echo-request -m limit --limit 10/s -m length --length 1:150 -j ACCEPT
else
	iptables -D input_rule -i $WAN -p icmp -m icmp --icmp-type  echo-request -m limit --limit 10/s -m length --length 1:150 -j ACCEPT
fi

#allow WAN route input
if [ $icmp = "checked" ]; then
	iptables -A input_rule -i $WAN -p icmp -m icmp --icmp-type  echo-request -m limit --limit 10/s -m length --length 1:150 -j ACCEPT
else
	iptables -D input_rule -i $WAN -p icmp -m icmp --icmp-type  echo-request -m limit --limit 10/s -m length --length 1:150 -j ACCEPT
fi

uci commit;
/etc/init.d/firewall restart;
/etc/init.d/network restart;

ls >/dev/null 2>/dev/null 