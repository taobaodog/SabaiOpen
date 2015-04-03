#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
UCI_PATH="-c /configs"

act=$1
config_act=$2

if [ $config_act = "update" ]; then
	config_file=sabai-new
else
	config_gile=sabai
fi

_stop(){
    uci delete network.vpn
    uci delete firewall.vpn
    uci set network.vpn.proto=none
    uci commit
    uci $UCI_PATH set sabai.vpn.status=none
    uci $UCI_PATH set sabai.vpn.proto=none
    uci $UCI_PATH commit sabai
    if [ $config_act = "update" ]; then
        echo "network" >> /tmp/.restart_services   
        echo "firewall" >> /tmp/.restart_services
    else
	/etc/init.d/network restart
	/etc/init.d/firewall restart
    fi
    logger "pptp stopped and firewall restarted"
}

_start(){
    #ensure that openvpn is stopped
        /etc/init.d/openvpn stop
        /etc/init.d/openvpn disable
    #get the pptp settings
        user=$(uci get sabai.vpn.username)
        pass=$(uci get sabai.vpn.password)
        server=$(uci get sabai.vpn.server)
    #set the network vpn settings
        uci set network.vpn=interface
        uci set network.vpn.ifname=pptp-vpn
        uci set network.vpn.proto="pptp"
        uci set network.vpn.username="$user"
        uci set network.vpn.password="$pass"
        uci set network.vpn.server="$server"
        uci set network.vpn.buffering=1
    #set the firewall
        uci set firewall.vpn=zone
        uci set firewall.vpn.name=vpn
        uci set firewall.vpn.input=ACCEPT
        uci set firewall.vpn.output=ACCEPT
        uci set firewall.vpn.forward=ACCEPT
        uci set firewall.vpn.masq=1
        uci set firewall.@forwarding[-1].src=lan
        uci set firewall.@forwarding[-1].dest=vpn
    #commit all changed services
        uci commit   
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
		/etc/init.d/network restart             
        	/etc/init.d/firewall restart            
	fi  
	
    logger "pptp run and firewall restarted"
    sleep 20 
    if [ $(ifconfig pptp-vpn | grep not) != "" ]; then
        uci set sabai.vpn.status=Disconnected
    else
        uci set sabai.vpn.status=Connected
        fi
    uci $UCI_PATH commit sabai
}

_clear(){
        uci delete network.vpn
        uci delete firewall.vpn
	uci set network.vpn.proto=none
        uci commit
        uci $UCI_PATH delete sabai.vpn.username          
        uci $UCI_PATH delete sabai.vpn.password          
        uci $UCI_PATH delete sabai.vpn.server
        uci $UCI_PATH set sabai.vpn.status=none
        uci $UCI_PATH set sabai.vpn.proto=none
	uci $UCI_PATH commit sabai
        /etc/init.d/network restart
        /etc/init.d/firewall restart
        logger "pptp cleared and firewall restarted"
}

ls >/dev/null 2>/dev/null 

case $act in
    start)  _start  ;;
    stop)   _stop   ;;
    clear)  _clear  ;;
esac
