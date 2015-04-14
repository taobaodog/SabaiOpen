#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
UCI_PATH="-c /configs"

action=$1
status=$(uci get sabai.vpn.status)

_return(){
	echo "res={ sabai: $1, msg: '$2' };";
	exit 0;
}

_stop(){
	_clear
	/etc/init.d/firewall restart
	/etc/init.d/network restart
	sleep 5
	_return 1 "OpenVPN stopped."
	logger "Openvpn stopped"
}

_start(){
	uci $UCI_PATH set sabai.vpn.status=Starting
	uci $UCI_PATH set sabai.vpn.proto=ovpn
	if [ ! -e /etc/sabai/openvpn/ovpn.current ]; then
		_return 0 "No file loaded."
	fi
	echo -n
	# stop other vpn's if running
	if [ $status != "none" ]; then
		uci $UCI_PATH commit sabai
		uci delete network.vpn
		uci commit network
		uci delete firewall.vpn
		forward=$(uci show firewall | grep =vpn | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
		uci delete firewall.@forwarding["forward"]
		uci commit firewall		
		
		if [ $action = "update" ]; then
			echo "network" >> /tmp/.restart_services
		else
			/etc/init.d/network restart
		fi

		logger "Vpn stopped and network restarted"
		sleep 5
	fi
	#Removing old configuration if it is.
	forward=$(uci show firewall | grep dest=sabai | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	uci delete firewall.@forwarding["$forward"]
	uci delete firewall.ovpn
	uci commit firewall
	#Configuring openvpn profile.
	uci set openvpn.sabai.log='/www/libs/data/stat/ovpn.log'
	uci set openvpn.sabai.enabled=1
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
	uci set firewall.@forwarding[-1].src=lan
	uci set firewall.@forwarding[-1].dest=sabai
	uci commit firewall
	uci $UCI_PATH set sabai.vpn.status=Started
	uci $UCI_PATH set sabai.vpn.proto=ovpn
	uci $UCI_PATH commit sabai
	/etc/init.d/openvpn start
	/etc/init.d/openvpn enable
	if [ $action = "update" ]; then
		echo "firewall" >> /tmp/.restart_services                                
		echo "network" >> /tmp/.restart_services
	else                                            
		/etc/init.d/firewall restart
		/etc/init.d/network restart           
	fi

	sleep 10

	ifconfig > /tmp/check
	if [ "$(cat /tmp/check | grep tun0)" == "" ]; then
		uci $UCI_PATH set sabai.vpn.status=Disconnected
		uci $UCI_PATH commit sabai
		logger "Openvpn did NOT started."
		_return 1 "OpenVPN did NOT started."
	else
		uci $UCI_PATH set sabai.vpn.status=Connected
		uci $UCI_PATH commit sabai
		logger "Openvpn started."
		_return 1 "OpenVPN started."
	fi
}

_save(){
	_return 1 "OpenVPN settings saved.";
}

_clear(){
	uci delete network.sabai                                                                    
	uci commit network                                                                          
	#Removing configuration of firewall.                                                        
	forward=$(uci show firewall | grep dest=sabai | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	uci delete firewall.@forwarding["$forward"]                                                 
	uci delete firewall.ovpn                                                                    
	uci commit firewall                                                                         
	uci $UCI_PATH set sabai.vpn.status=none                                                     
	uci $UCI_PATH set sabai.vpn.proto=none                                                      
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

ls >/dev/null 2>/dev/null 

case $action in
	start)	_start	;;
	stop)	_stop	;;
	update) _start  ;;
	save)	_save	;;
	clear)  _clear_all  ;;
esac
