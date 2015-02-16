#!/bin/sh
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

UCI_PATH="-c /configs" 
# this script allows 2 variables to be passed to it, as documented below:
# act variable is the action sent into the script

# to do - change ip route to lan bridged route

act=$1

# the ip address and mask of the device
iproute=$(ip route | grep -e "/24 dev eth0" | awk -F: '{print $0}' | awk '{print $1}')


# the proxy address and mask in the configuration file
proxyroute=$(cat /etc/privoxy/config | grep -e "permit-access" | awk -F: '{print $0}' | awk '{print $2}')



_return(){
   echo "res={ sabai: $1, msg: '$2' };";
   exit 0;
}

_proxystop(){
   uci $UCI_PATH set sabai.proxy.status="Off";
   uci $UCI_PATH commit sabai
   /etc/init.d/privoxy stop;
   _return 1 "Proxy Stopped";
}

_proxystart(){
    # replace the ip address and mask if necessary
    if [ "$iproute" != "$proxyroute" ]; then
	logger "Proxy setup: address not equal" $proxyroute $iproute;
	sed -i "s#$proxyroute#$iproute#" /etc/privoxy/config
    fi
   uci $UCI_PATH set sabai.proxy.status="On";
   uci $UCI_PATH commit sabai;
    /etc/init.d/privoxy start;
    _return 1 "Proxy Started";
}

sudo -n ls >/dev/null 2>/dev/null
[ $? -eq 1 ] && _return 0 "Need Sudo powers."
([ -z "$act" ] ) && _return 0 "Missing arguments: act=$act."

case $act in
   proxystart)  _proxystart  ;;
   proxystop)   _proxystop   ;;
esac

