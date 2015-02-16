#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
UCI_PATH="-c /configs"

# send messages to log file but clear log file on each new setup of gw.sh
rm /var/log/sabaigw.log; exec 2>&1; exec 1>/var/log/sabaigw.log;

#find our local network, minus last octet.  For example 192.168.199.1 becomes 192.168.199
lan_prefix="$(uci get network.lan.ipaddr | cut -d '.' -f1,2,3)"; 
#get the current server address for sabaitechnology.biz for address services
sabaibiz="$(nslookup sabaitechnology.biz | grep Address: | cut -d':' -f2 | awk '{print $1}' | awk '{print $1}' | tail -n 1)";

#clear the old ip routes
_fin(){ ip route flush cache; }

#flush the tables on stopping gateways
_stop(){
 for i in 1 2 3 4; do ip route flush table $i; done
 ip rule | grep "$lan_prefix" | cut -d':' -f2 | while read old_rule; do ip rule del $old_rule; done
 _fin
}

_start(){
 _stop
 for i in 1 2 3 4; do ip route add "$lan_prefix.0/24" dev br-lan table $i; done
 wan_gateway="$(uci get network.wan.gateway)"; wan_iface="$(uci get network.wan.ifname)";
 ([ -z "$wan_gateway" ] || [ "$wan_gateway" == "0.0.0.0" ]) && wan_gateway="$(uci get network.wan.gateway)"
 [ -n "$wan_iface" ] && ([ -n "$wan_gateway" ] && [ "$wan_gateway" != "0.0.0.0" ]) && ip route add default via $wan_gateway dev $wan_iface table 1
 #ensure that accelerator IP is set
 if [ $(uci get sabai.general.ac_ip) = "" ]; then
  uci $UCI_PATH set sabai.general.ac_ip=2
  uci $UCI_PATH commit sabai
fi
 # add route to the accelerator
 ip route add default via "$lan_prefix.$(uci get sabai.general.ac_ip)" dev br-lan table 3

 if [ $(ifconfig | grep tun0) != "" ]; then
  vpn_device="tun0";
  vpn_gateway="$(ifconfig tun0 | grep P-t-P: | awk '{print $3}' | sed 's/P-t-P://g')";
  ip route add $vpn_gateway dev $vpn_device
  ip route | grep $vpn_device | while read vpn_rt; do ip route add $vpn_rt table 2; done
  ip route del $vpn_gateway dev $vpn_device
  route add $sabaibiz dev $vpn_device
 fi

 if [ $(ifconfig | grep tun0) != "" ] || [ $(ifconfig | grep pptp-vpn) != "" ] ; then
  vpn_device="$(nvram get vpn_device)";
  vpn_gateway="$(nvram get vpn_gateway)";
  ip route add $vpn_gateway dev $vpn_device
  ip route | grep $vpn_device | while read vpn_rt; do ip route add $vpn_rt table 2; done
  ip route del $vpn_gateway dev $vpn_device
  route add $sabaibiz dev $vpn_device
 fi
 ip rule | grep "$lan_prefix" | cut -d':' -f2 | while read old_rule; do ip rule del $old_rule; done
 [ ! $default -eq 0 ] && ip rule add from "$lan_prefix.1/24" table $default

 #assign statics to ip rules
  for j in $(uci show sabai | grep =dhcphost | cut -d "[" -f2 | cut -d "]" -f1); do
    if [ $(uci get sabai.@dhcphost["$j"].route) = "internet" ];then
      iptab=$(uci get sabai.@dhcphost["$j"].ip)
      ip rule add from "$iptab" table 1
    fi
    if [ $(uci get sabai.@dhcphost["$j"].route) = "vpn_fallback" ];then
      iptab=$(uci get sabai.@dhcphost["$j"].ip)
      ip rule add from "$iptab" table 2
    fi
    if [ $(uci get sabai.@dhcphost["$j"].route) = "vpn_only" ];then
      iptab=$(uci get sabai.@dhcphost["$j"].ip)
      ip rule add from "$iptab" table 3
    fi
    if [ $(uci get sabai.@dhcphost["$j"].route) = "accelerator" ];then
      iptab=$(uci get sabai.@dhcphost["$j"].ip)
      ip rule add from "$iptab" table 4
    fi
  done
 _fin
}
_ds(){ /etc/init.d/dnsmasq restart; _start; }

case $1 in
	stop)	_stop	;;
	start)	_start	;;
	ds)	_ds	;;
esac
