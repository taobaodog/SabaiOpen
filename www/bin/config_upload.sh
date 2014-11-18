#!/bin/ash

#copy the new config instead of old one
# |
# - sabai
# + configs
#   - config.Fri_Oct_31_06:34:01_EDT_2014
#   - config.Tue_Oct_29_03:33:31_EDT_2014
#

#apply settings from new config

#section 'lan'         -> /www/bin/lan.sh             --> network restart
#section 'dhcp'        -> /www/bin/dhcp.sh(aaData)    --> network/firewall restart
#section 'wan'         -> /www/bin/wan.sh             --> network restart
#section 'vpn'         -> /www/bin/ovpn.sh pptp.sh    --> openvpn start/enable; network/firewall restart
#section 'general'     -> none
#section 'dns'         -> /www/bin/wan.sh             --> network restart
#section 'time'        -> /www/bin/time.sh            --> ntpd restart
#section 'firewall'    -> /www/bin/firewall.sh        --> firewall restart
#section 'dmz'         -> /www/bin/dmz.sh             --> firewall restart
#section 'upnp'        -> /www/bin/upnp.sh            --> firewall restart
#section 'pf'          -> /www/bin/portfowarding.sh   --> firewall restart
#section 'wlradio'     -> /www/bin/wl.sh              --> wifi up

SABAI_CONFIG=/etc/config/sabai

wget -P /etc/config ftp://192.168.0.76/some-config
mv /etc/config/some-config /etc/config/sabai-new

CONFIG_SECTIONS=$(cat $SABAI_CONFIG | grep config | awk '{print $3}' | sed ':a;N;$!ba;s/\n/ /g' | tr -d "'")
echo "CONFIG_SECTIONS=$CONFIG_SECTIONS"

for i in $CONFIG_SECTIONS; do
		echo section: $i
		uci show sabai.$i | awk -F. '{$1=""; print $0}' > /tmp/$i.orig
		uci show sabai-new.$i | awk -F. '{$1=""; print $0}' > /tmp/$i.new
		cmp /tmp/$i.orig /tmp/$i.new
		if [ $? != 0 ]; then
			echo "config $i differ"
			case "$i" in
			lan) 
				echo "in lan"
				/www/bin/lan.sh update
			;;
			dhcp) 
				echo "in dhcp"
				/www/bin/lan.sh update
				/www/bin/dhcp.sh update	
			;;
			wan) 
				echo "in wan"
				/www/bin/wan.sh update
				/www/bin/lan.sh update
			;;
			vpn) 
				echo "in vpn"
				proto=$(uci get sabai-new.vpn.proto)
				if [ "$proto" = "pptp" ]; then
					/www/bin/ovpn.sh stop
					/www/bin/pptp.sh start
				else
					/www/bin/pptp.sh stop
					/www/bin/ovpn.sh start
				fi
			;;
			dns) 
				echo "in dns"
				/www/bin/wan.sh update
			;;
			time) 
				echo "in time"
				/www/bin/time.sh update
			;;
			firewall) 
				echo "in firewall"
				#TODO not implemented in firewall.sh
				/www/bin/firewall.sh update
 			;;
			dmz)
				echo "in dmz"
				#TODO not implemented in dmz.sh
				/www/bin/dmz.sh update
			;;
			upnp)
				echo "in upnp"
				/www/bin/upnp.sh update
			;;
			pf)
				echo "in pf"
				/www/bin/portforwarding.sh update
			;;
			wlradio0|wlradio1)
				echo "in wlradio"
				/www/bin/wl.sh update
			;;
			esac
		fi
done

#TODO remove .orig and .new in tmp
if [ ! -e /tmp/.restart_services ]; then
	echo "Nothing to update in config files"
	exit 0
else
	cat /tmp/.restart_services
fi


#TODO restart affected services
for i in $CONFIG_SECTIONS; do
        echo "checking section $i"
        if grep -q $i /tmp/.restart_services; then
                echo "restart $i service to apply new config settings"
                if [ $i = "time" ]; then
                        /etc/init.d/ntpd restart
                else
                        echo "service $i restart"
                        /etc/init.d/$i restart
                fi
        fi
done

rm -f /tmp/.restart_services

#replace configs
if [ ! -d "/etc/config/configs" ]; then
	mkdir /etc/config/configs
fi
mv /etc/config/sabai /etc/config/configs/$(date | tr ' ' '_')
mv /etc/config/sabai-new /etc/config/sabai
