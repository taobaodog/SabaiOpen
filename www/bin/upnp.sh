#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2014 Sabai Technology
#this script developed to set three variables to be 
#on or off according to user input 
#As well as specify the start and end of the internal and external ports

#Used Variables 

enable=$(uci get sabai.upnp.enable);
natpmp=$(uci get sabai.upnp.natpmp);
clean=$(uci get sabai.upnp.clean);
secure=$(uci get sabai.upnp.secure);
intmin=$(uci get sabai.upnp.intmin);
intmax=$(uci get sabai.upnp.intmax);
intrange="$intmin-$intmax"
extmin=$(uci get sabai.upnp.extmin);
extmax=$(uci get sabai.upnp.extmax);
extrange="$extmin-$extmax"


#Script Function 
if [ "$enable" = "on" ]; then
  	uci set upnpd.config.enable_upnp=1
  	uci set upnpd.@perm_rule[0].int_ports=$intrange
	uci set upnpd.@perm_rule[0].ext_ports=$extrange
else
  	uci set upnpd.enable_upnp=0
fi

if [ "$natpmp" = "on" ]; then
  	uci set upnpd.config.enable_natpmp=1
  else
  	uci delete upnpd.config.enable_natpmp
fi
 
if [ "$clean" = "on" ]; then
  	uci set upnpd.config.clean_ruleset_interval=600
  else
  	uci delete upnpd.config.clean_ruleset_interval
fi


if [ "$secure" = "on" ]; then
  	uci set upnpd.config.secure_mode=1
else
	uci delete upnpd.config.secure_mode
fi



uci commit
/etc/init.d/firewall restart
logger "upnp script run and firewall restarted"


ls >/dev/null 2>/dev/null 
