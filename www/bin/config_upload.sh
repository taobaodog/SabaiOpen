#!/bin/ash

# Script is used for restoring procedure.
# |
# /etc/config/sabai is a link to /configs/sabai 
# /configs - mounting point for /dev/sda6
# all configurations are located on /dev/sda6
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
RESTORED_CONFIG=$1
cp $RESTORED_CONFIG /etc/config/sabai-new

#presence check of ovpn configuration
addr_prefix="/configs/backup_"
conf_name=${RESTORED_CONFIG#$addr_prefix}
ovpn_filename="/configs/ovpn_backup/ovpn.filename_$conf_name"
ovpn_config="/configs/ovpn_backup/ovpn.config_$conf_name"
ovpn_msg="/configs/ovpn_backup/ovpn.msg_$conf_name"

CONFIG_SECTIONS=$(cat $SABAI_CONFIG | grep config | awk '{print $3}' | sed ':a;N;$!ba;s/\n/ /g' | tr -d "'")
echo "CONFIG_SECTIONS=$CONFIG_SECTIONS"

for i in $CONFIG_SECTIONS; do
		echo section: $i 
		uci show sabai.$i | awk -F. '{$1=""; print $0}' > /tmp/$i.orig
		uci show sabai-new.$i | awk -F. '{$1=""; print $0}' > /tmp/$i.new
		cmp /tmp/$i.orig /tmp/$i.new
		if [ "$i" = "vpn" ] && [ $? = 0 ]; then
			cmp /etc/sabai/openvpn/ovpn.current $ovpn_config
		fi
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
				old_proto=$(uci get sabai.vpn.proto)
				proto=$(uci get sabai-new.vpn.proto)
				if [ "$old_proto" = "pptp"] && [ "$proto" = "pptp" ]; then
					#stop all vpn connections
					/www/bin/pptp.sh stop update
					#start pptp 
					/www/bin/pptp.sh start update
				elif [ "$old_proto" = "pptp"] && [ "$proto" = "ovpn" ]; then
					cp $ovpn_filename /etc/sabai/openvpn/ovpn.filename
					cp $ovpn_config /etc/sabai/openvpn/ovpn.current
					cp $ovpn_msg /etc/sabai/openvpn/ovpn
					/www/bin/ovpn.sh start
				elif [ "$old_proto" = "ovpn"] && [ "$proto" = "ovpn" ]; then
					#stop all vpn connections         
					/www/bin/ovpn.sh stop
					cp $ovpn_filename /etc/sabai/openvpn/ovpn.filename                  
					cp $ovpn_config /etc/sabai/openvpn/ovpn.current   
					cp $ovpn_msg /etc/sabai/openvpn/ovpn
					/www/bin/ovpn.sh start
				elif [ "$old_proto" = "ovpn"] && [ "$proto" = "pptp" ]; then
					/www/bin/ovpn.sh stop
					/www/bin/ovpn.sh start update
				else
					/www/bin/ovpn.sh stop
					cp $ovpn_filename /etc/sabai/openvpn/ovpn.filename
					cp $ovpn_config /etc/sabai/openvpn/ovpn.current
					cp $ovpn_msg /etc/sabai/openvpn/ovpn 
					/www/bin/pptp.sh stop update
				fi
				echo "vpn" >> /tmp/.etc_service
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
				/www/bin/firewall.sh update
 			;;
			dmz)
				echo "in dmz"
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
			loopback)
				echo "loopback" >> /tmp/.etc_services
			;;
			general)
				echo "general" >> /tmp/.etc_service
			;;
			dmz)
				echo "dmz" >> /tmp/.etc_service
			;;
			proxy)
				echo "proxy" >> /tmp/.etc_service
			;;
			dhcphost)
				echo "dhcphost" >> /tmp/.etc_service
			;;
			esac
		fi
	rm /tmp/$i.orig /tmp/$i.new 
done

if [ ! -e /tmp/.restart_services ] && [ ! -e /tmp/.etc_service ]; then
	echo "Nothing to update in config files" 
	exit 0
elif [ ! -e /tmp/.restart_services ] && [ -e /tmp/.etc_service ]; then
	echo "Copying new config . . ."
else
	SERVICES=`sort -u /tmp/.restart_services`
	echo "SERVICES TO RESTART : $SERVICES"
fi


#restart affected services
for i in $SERVICES; do
        echo "checking section $i"
        echo "restart $i service to apply new config settings"
        if [ $i = "time" ]; then
	        /etc/init.d/ntpd restart
	elif [ $i = "network" ]; then
                /etc/init.d/$i restart
		ifup wan
		ifup wan
        else
        	echo "service $i restart"
		/etc/init.d/$i restart
        fi
done

rm -f /tmp/.restart_services

mv /etc/config/sabai-new /configs/sabai
