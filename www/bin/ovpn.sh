#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology
UCI_PATH="-c /configs"

action=$1
status=$(uci get sabai.vpn.status)
proto=$(uci get sabai.vpn.proto)
device=$(uci get system.@system[0].hostname)

_return(){
	echo "res={ sabai: $1, msg: '$2' };";
	exit 0;
}

_stop(){
	if [ $proto = "none" ] || [ $proto = "pptp" ] || [ $proto = "tor" ]; then
		logger "No OpenVPN is running."
		_return 0 "No OpenVPN is running."
	fi

	_clear
#	/etc/init.d/firewall restart
	sleep 5
	logger "Openvpn stopped"
	_return 1 "OpenVPN stopped."
}

_start(){
        if [ $proto == "ovpn" ]; then
		logger "Ovpn has been already running."
                _return 0 "Ovpn has been already running."
        fi

        if [ ! -e /etc/sabai/openvpn/ovpn.current ]; then
                _return 0 "No file loaded."
        fi
	
	_config
	/etc/init.d/openvpn start
	/etc/init.d/openvpn enable

	sleep 10

	ifconfig > /tmp/check
	if [ "$(cat /tmp/check | grep tun0)" == "" ]; then
		uci $UCI_PATH set sabai.vpn.status=Disconnected
		uci $UCI_PATH commit sabai
		logger "OpenVPN did not start. Please check your configuration."
		_return 1 "OpenVPN did not start. Please check your configuration."
	else
		uci $UCI_PATH set sabai.vpn.status=Connected
		uci $UCI_PATH commit sabai
		#adjusting ip rules
		[ "$device" = "SabaiOpen" ] && /www/bin/gw.sh vpn_gw
		logger "Openvpn started."
		_return 1 "OpenVPN started."
	fi
}

_save(){
	_return 1 "OpenVPN settings saved.";
}

_config(){
        # stop other vpn's if running
        if [ $proto = "pptp" ]; then
		/www/bin/pptp.sh stop
		uci $UCI_PATH set sabai.vpn.status=Starting
		uci $UCI_PATH set sabai.vpn.proto=ovpn
		uci $UCI_PATH commit sabai
                uci delete network.vpn
                uci commit network
                uci delete firewall.vpn
                forward=$(uci show firewall | grep =vpn | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)                                         
                uci delete firewall.@forwarding["$forward"] 
                uci commit firewall                             
                /etc/init.d/network restart                                                                           
                logger "Vpn stopped and network restarted"                                                                                     
                sleep 5                                                                                                                        
		elif [ $proto = "tor" ]; then
			/www/bin/tor.sh off
		else
			logger "No VPN is running."
		fi

	#Removing old configuration if it is.                                                                                                  
        forward=$(uci show firewall | grep forwarding | grep dest=\'sabai\' | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)                         
        if [ "$forwarding" != "" ]; then                        
                uci delete firewall.@forwarding["$forward"]                                                           
        else                                                                                                                                   
		echo -e "\n"                                                                                                                                               
        fi                                                      
        uci delete firewall.ovpn                                                                                                               
        uci commit firewall                                                                                                                    
        #Configuring openvpn profile.                                                                                 
        uci set openvpn.sabai.log='/var/log/ovpn.log'                                                                               
        uci set openvpn.sabai.enabled=1                                                                                                        
	uci set openvpn.sabai.filename="$(cat /etc/sabai/openvpn/ovpn.filename)"
        uci commit openvpn                                                                                                                     
        #Configuring network interface                                                                                
        uci set network.sabai=interface                                                                                                        
        uci set network.sabai.ifname='tun0'                                                                                                    
        uci set network.sabai.proto='none'                                                                                                     
        uci commit network                                                                                            
        #Firewall settings                                                                                                                     
        uci set firewall.ovpn=zone                                                                                                             
        uci set firewall.ovpn.name=sabai                                                                                                       
        uci set firewall.ovpn.input=ACCEPT                                                                            
        uci set firewall.ovpn.output=ACCEPT                                                                                                    
        uci set firewall.ovpn.forward=ACCEPT                                                                                                   
        uci set firewall.ovpn.network=sabai                                                                                                    
        uci set firewall.ovpn.masq=1
	uci add firewall forwarding                                                                                                            
        [ "$device" = "SabaiOpen" ] && uci set firewall.@forwarding[-1].src=lan || uci set firewall.@forwarding[-1].src=wan
        uci set firewall.@forwarding[-1].dest=sabai                                                                                            
        uci commit firewall                                                                                           
        uci $UCI_PATH set sabai.vpn.status=Started                                                                                             
        uci $UCI_PATH set sabai.vpn.proto=ovpn                                                                                                 
        uci $UCI_PATH commit sabai

	# check if log file is set
	if [ ! $(cat /etc/sabai/openvpn/ovpn.current | grep log) ]; then
		echo "log-append '$(uci get openvpn.sabai.log)'" >> /etc/sabai/openvpn/ovpn.current 
		(cat /etc/sabai/openvpn/ovpn.current | grep verb) || echo "verb 3" >> /etc/sabai/openvpn/ovpn.current
	fi
}


_clear(){
	uci delete network.sabai                                                                    
	uci commit network                                                                          
	#Removing configuration of firewall.                                                        
	forward=$(uci show firewall | grep forwarding | grep dest=\'sabai\' | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	if [ "$forward" != "" ]; then                                                                                             
                uci delete firewall.@forwarding["$forward"]
        else                                       
                echo -e /n                                                                                            
        fi 
	uci delete firewall.ovpn                                                                    
	uci commit firewall                                                                         
	uci $UCI_PATH set sabai.vpn.proto=none                                                     
	uci $UCI_PATH set sabai.vpn.status=none
	uci $UCI_PATH commit sabai                                                                  
	/etc/init.d/openvpn stop                                                                    
	/etc/init.d/openvpn disable
}

_clear_all(){
	uci set openvpn.sabai.enabled=0
	uci set openvpn.sabai.filename=none
	uci commit openvpn
	_clear
	rm /etc/sabai/openvpn/ovpn.current
	rm /etc/sabai/openvpn/ovpn
	rm /etc/sabai/openvpn/auth-pass
	sleep 5
	logger "OpenVPN settings cleared."
	_return 1 "OpenVPN settings cleared.";
}

_stat(){
	ifconfig > /tmp/check
	if [ "$(cat /tmp/check | grep tun0)" = "" ]; then
		uci $UCI_PATH set sabai.vpn.status=Disconnected
		logger "OpenVPN did not start. Please check your configuration."
		_return 1 "OpenVPN did not start. Please check your configuration."
	else
		uci $UCI_PATH set sabai.vpn.status=Connected
		logger "Openvpn started."
		_return 1 "OpenVPN started."
	fi
	uci $UCI_PATH commit sabai
}

_log() {
	sed -n '1{h;T;};G;h;$p;' /var/log/ovpn.log > /var/log/ovpn_web.log
}

ls >/dev/null 2>/dev/null 

case $action in
	start)	_start	;;
	stop)	_stop	;;
	update) _start  ;;
	save)	_save	;;
	clear)  _clear_all  ;;
	config) _config	;;
	check) 	_stat	;;
	log)	_log	;;
esac
