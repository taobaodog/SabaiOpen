#!/bin/sh
# Sabai Technology - Apache v2 licence
# Copyright 2016 Sabai Technology

UCI_PATH="-c /configs" 
# this script allows 2 variables to be passed to it, as documented below:
# act variable is the action sent into the script

# to do - change ip route to lan bridged route

act=$1

# the ip address of the device
ip=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
ipfix="$ip:8080"

# the ip address and mask of the device
iproute=$(ip route | grep -e "/24 dev eth0" | awk -F: '{print $0}' | awk '{print $1}')
iproutefix="'$iproute'"

# the proxy address and mask in the configuration file
proxyroute=$(cat /etc/config/privoxy | grep -e "permit_access" | awk -F: '{print $0}' | awk '{print $3}')



_return(){
   echo "res={ sabai: $1, msg: '$2' };"
   exit 0
}

_proxystop(){
   uci $UCI_PATH set sabai.proxy.status="Off"
   uci $UCI_PATH commit sabai
   /etc/init.d/privoxy stop
   _return 1 "Proxy Stopped"
}

_proxystart(){
    # replace the ip address and mask if necessary
    if [ "$iproutefix" != "$proxyroute" ]; then
	logger "Proxy setup: address not equal" $proxyroute $iproutefix
	sed -i "s#$proxyroute#$iproutefix#" /etc/config/privoxy
    fi
   uci set privoxy.privoxy.listen_address=$ipfix
   uci commit privoxy
   uci $UCI_PATH set sabai.proxy.status="On"
   uci $UCI_PATH commit sabai
   
   /etc/init.d/privoxy start
   _return 1 "Proxy Started"
}

sudo -n ls >/dev/null 2>/dev/null
[ $? -eq 1 ] && _return 0 "Need Sudo powers."
([ -z "$act" ] ) && _return 0 "Missing arguments: act=$act."

case $act in
   proxystart)  _proxystart  ;;
   proxystop)   _proxystop   ;;
esac
