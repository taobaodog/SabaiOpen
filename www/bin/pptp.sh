#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology
UCI_PATH="-c /configs"

act=$1
config_act=$2

if [ $config_act = "update" ]; then
	config_file="sabai-new"
else
	config_file="sabai"
fi

_stop(){
	uci delete network.vpn
	uci set network.vpn.proto=none
	uci commit network
	uci delete firewall.vpn
	forward=$(uci show firewall | grep forwarding | grep dest=vpn | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)                           
        if [ "$forward" != "" ]; then                                                                                                          
                uci delete firewall.@forwarding["$forward"]                                                                                    
        else                                                                                                                                   
                echo -e "\n"                                                                                                                     
        fi                                                                                                                                     
	uci commit firewall	
	uci $UCI_PATH set sabai.vpn.status=none
	uci $UCI_PATH set sabai.vpn.proto=none
	uci $UCI_PATH commit sabai
	if [ $config_act = "update" ]; then
		echo "network" >> /tmp/.restart_services   
		echo "firewall" >> /tmp/.restart_services
	else
		/etc/init.d/firewall restart
		sleep 5
		/etc/init.d/network restart
	fi
   	logger "pptp is stopped and firewall restarted."
}

_start(){
	status=$(uci get sabai.vpn.status)
	if [ $status != "none" ]; then
	#ensure that openvpn is stopped
		/etc/init.d/openvpn stop
		/etc/init.d/openvpn disable
	#ensure that openvpn settings removed
		uci delete network.sabai
		uci delete firewall.ovpn
		forward=$(uci show firewall | grep forwarding | grep dest=sabai | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
		if [ "$forward" != ""  ]; then
			uci delete firewall.@forwarding["$forward"]
		else
			echo -e "\n"
		fi
	fi
	#get the pptp settings
        user=$(uci get $config_file.vpn.username)
        pass=$(uci get $config_file.vpn.password)
	server=$(uci get $config_file.vpn.server)
    #set the network vpn settings
        uci set network.vpn=interface
        uci set network.vpn.ifname=pptp-vpn
        uci set network.vpn.proto=pptp
        uci set network.vpn.username="$user"
        uci set network.vpn.password="$pass"
        uci set network.vpn.server="$server"
        uci set network.vpn.buffering=1
	uci commit network
    #set the firewall
        uci set firewall.vpn=zone
        uci set firewall.vpn.name=vpn
        uci set firewall.vpn.input=ACCEPT
        uci set firewall.vpn.output=ACCEPT
        uci set firewall.vpn.forward=ACCEPT
	uci set firewall.vpn.network=vpn
        uci set firewall.vpn.masq=1
	uci add firewall forwarding 
        uci set firewall.@forwarding[-1].src=lan
        uci set firewall.@forwarding[-1].dest=vpn
    #commit all changed services
        uci commit firewall   
    #set sabai vpn settings
        uci $UCI_PATH set sabai.vpn.proto=pptp
        uci $UCI_PATH set sabai.vpn.status=Starting
        uci $UCI_PATH set sabai.vpn.status=pptp
	uci $UCI_PATH commit sabai
    #restart services
	if [ $config_act = "update" ]; then         
		echo "network" >> /tmp/.restart_services
        	echo "firewall" >> /tmp/.restart_services
	else                                         
        	/etc/init.d/firewall restart
		sleep 5            
		/etc/init.d/network restart
	fi  
	
	sleep 20 
	ifconfig > /tmp/check
	if [ "$(cat /tmp/check | grep tun0)" != "" ]; then
        	uci set sabai.vpn.status=Disconnected
		logger "pptp is disconnected."
	else
        	uci set sabai.vpn.status=Connected
		#adjusting ip rules
		/www/bin/gw.sh vpn_gw
		logger "pptp is connected."
        fi
	uci $UCI_PATH commit sabai
}

_clear(){
        uci delete network.vpn
        uci delete firewall.vpn
	uci set network.vpn.proto=none
        uci commit network
	uci delete firewall.vpn
	forward=$(uci show firewall | grep forwarding | grep dest=vpn | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	if [ "$forward" != "" ]; then                                                                                                          
                uci delete firewall.@forwarding["$forward"]                                                                                    
        else                                                                                                                                   
                echo -e "\n"                                                                                                                     
        fi
	uci commit firewall
        uci $UCI_PATH delete sabai.vpn.username          
        uci $UCI_PATH delete sabai.vpn.password          
        uci $UCI_PATH delete sabai.vpn.server
        uci $UCI_PATH set sabai.vpn.status=none
        uci $UCI_PATH set sabai.vpn.proto=none
	uci $UCI_PATH commit sabai
        /etc/init.d/firewall restart
        logger "pptp cleared and firewall restarted."
}

ls >/dev/null 2>/dev/null 

case $act in
    start)  _start  ;;
    stop)   _stop   ;;
    clear)  _clear  ;;
esac
