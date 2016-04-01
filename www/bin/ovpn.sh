#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology
UCI_PATH="-c /configs"

action=$1
status=$(uci get sabai.vpn.status)
proto=$(uci get sabai.vpn.proto)
device=$(uci get system.@system[0].hostname)
start_time="$(date '+%H:%M')"
_return(){
	echo "res={ sabai: $1, msg: '$2' };";
	exit 0;
}

_stop(){
	ifconfig > /tmp/check
	if [ ! "$(cat /tmp/check | grep tun0)" ]; then
		logger "No OpenVPN is running."
		_return 0 "No OpenVPN is running."
	fi

	_clear
	/etc/init.d/firewall restart
	#prevent ovpn start during the boot
        uci set openvpn.sabai.enabled='0'
        uci commit openvpn
	logger "Openvpn stopped"
	_return 1 "OpenVPN stopped."
}

_start(){
	ifconfig > /tmp/check
	if [ "$(cat /tmp/check | grep tun0)" ]; then
		logger "OpenVPN is already running."
                _return 0 "OpenVPN is already running."
        fi

        if [ ! -e /etc/sabai/openvpn/ovpn.current ]; then
                _return 0 "No file is loaded."
        fi
	
	_config
	/etc/init.d/openvpn start
	/etc/init.d/openvpn enable

	sleep 10

	_stat
}

_save(){
	_return 1 "OpenVPN settings saved.";
}

_config(){
	ifconfig > /tmp/check

        # stop other vpn's if running
        if [ "$(cat /tmp/check | grep pptp)" ]; then
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
	elif [ "$(netstat -lnt | awk '$6 == "LISTEN" && $4 ~ ".9040"')" ]; then
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
	[ -e /var/log/ovpn.log ] || touch /var/log/ovpn.log
	if [ ! "$(cat /etc/sabai/openvpn/ovpn.current | grep log-)" ]; then
		echo -e "\n log-append '$(uci get openvpn.sabai.log)'" >> /etc/sabai/openvpn/ovpn.current 
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
	uci $UCI_PATH set sabai.vpn.dns='0'
	uci $UCI_PATH commit sabai                                                                  
	uci delete dhcp.@dnsmasq[0].server
	uci commit dhcp
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
	if [ ! "$(cat /tmp/check | grep tun0)" ]; then
		uci $UCI_PATH set sabai.vpn.status=Disconnected
		uci $UCI_PATH commit sabai
		logger "OpenVPN did not start. Please check your configuration."
		_return 1 "OpenVPN did not start. Please check your configuration."
	else
		uci $UCI_PATH set sabai.vpn.status=Connected
		uci $UCI_PATH commit sabai

		[ "$device" = "SabaiOpen" ] && /www/bin/gw.sh vpn_gw
		
		logger "Openvpn started."
		_return 1 "OpenVPN started."
	fi
}

_dns_fix(){
	log_line_1="$(awk '/OpenVPN 2.3.6/{ print NR; }' /var/log/ovpn.log | tail -1)"
	log_line_2="$(awk '/Sequence Completed/{ print NR; }' /var/log/ovpn.log | tail -1)"

	check="$(cat /var/log/ovpn.log | awk '{if((NR>'$log_line_1')&&(NR<'$log_line_2')) print}' | grep DNS)"

	if [ "$check" ]; then
		tun_dns_1="$(cat /var/log/ovpn.log | grep "dhcp-option DNS" | tail -1 | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | grep -v 10. | awk 'FNR == 1 {print}')"
		tun_dns_2="$(cat /var/log/ovpn.log | grep "dhcp-option DNS" | tail -1 | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | grep -v 10. | awk 'FNR == 2 {print}')"

		if [ "$tun_dns_1" !=  "$tun_dns_2" ]; then
			iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j DNAT --to "$tun_dns_2"
			uci add_list dhcp.@dnsmasq[0].server="$tun_dns_2"
		fi
		iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j DNAT --to "$tun_dns_1"
		uci add_list dhcp.@dnsmaddsq[0].server="$tun_dns_1"
		uci commit dhcp
		uci $UCI_PATH set sabai.vpn.dns='1'
	else
		uci $UCI_PATH set sabai.vpn.dns='0'
	fi
	uci $UCI_PATH commit sabai
	logger "DNS for VPN was set."
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
	clear)  _clear_all;;
	config) _config	;;
	check) 	_stat	;;
	dns)	_dns_fix;;
	log)	_log	;;
esac
