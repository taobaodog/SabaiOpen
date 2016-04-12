#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2016 Sabai Technology

action=$1

UCI_PATH="-c /configs"
cat /dev/null > /tmp/.restart_services

test_eq() {
	if [ "$1" == "$2" ]; then                   
                echo -e "\033[32m -> -> -> $3: Pass <- <- <- \033[00m"        
        else                                                                         
                echo -e "\033[31m -> -> -> $3: Fail <- <- <- \033[00m"              
        fi 
}

_start() {
	echo "---------------START OF START-TEST---------------"
	echo "*************************** Test Case 1 ******************************"
	echo -e "-> -> -> \033[32m Input: Ovpn config file present. Proto and status are none \033[00m"
	uci $UCI_PATH set sabai.vpn.proto=none
	uci $UCI_PATH set sabai.vpn.status=none
	uci $UCI_PATH commit sabai
	/www/bin/ovpn.sh start

	test_eq "$(uci get openvpn.sabai.log)" "/www/libs/data/stat/ovpn.log" "1.1"
        test_eq "$(uci get openvpn.sabai.enabled)" "1" "1.2"
	test_eq "$(uci get network.openvpn.ifname)" "tun0" "1.3"
	test_eq "$(uci get network.openvpn.proto)" "ovpn" "1.4"
	test_eq "$(uci get firewall.@forwarding[-1].src)" "lan" "1.5"
	test_eq "$(uci get firewall.@forwarding[-1].dest)" "sabai" "1.6"
	test_eq "$(uci get sabai.vpn.status)" "Disconnected" "1.7"
	test_eq "$(uci get sabai.vpn.proto)" "ovpn" "1.8"
	echo -e "\033[31m *********************************** \033[00m"
	ifconfig tun0 | grep -q not
	echo -e "\033[31m *********************************** \033[00m"

        echo "*************************** Test Case 2 ******************************"                  
        echo -e "-> -> -> \033[32m Input: Ovpn config file present. Proto - pptp and status - connected \033[00m"
	uci $UCI_PATH set sabai.vpn.proto=pptp
        uci $UCI_PATH set sabai.vpn.status=Connected
        uci $UCI_PATH commit sabai
	#set the network vpn settings               
        uci set network.vpn=interface     
        uci set network.vpn.ifname=pptp-vpn     
        uci set network.vpn.proto="pptp"       
        uci set network.vpn.username="vpn593"    
        uci set network.vpn.password="3KTh84zEH2"
        uci set network.vpn.server="vpn-in22.reliablehosting.com"    
        uci set network.vpn.buffering=1 
        uci commit network
	uci set firewall.vpn=zone                       
        uci set firewall.vpn.name=vpn                   
        uci set firewall.vpn.input=ACCEPT                
        uci set firewall.vpn.output=ACCEPT               
        uci set firewall.vpn.forward=ACCEPT             
        uci set firewall.vpn.masq=1                     
        uci set firewall.@forwarding[-1].src=lan         
        uci set firewall.@forwarding[-1].dest=vpn  
	uci commit firewall 
	/www/bin/ovpn.sh start

	test_eq "$(uci get openvpn.sabai.log)" "/www/libs/data/stat/ovpn.log" "2.1"                                    
        test_eq "$(uci get openvpn.sabai.enabled)" "1" "2.2"                                                          
        test_eq "$(uci get network.openvpn.ifname)" "tun0" "2.3"                                            
        test_eq "$(uci get network.openvpn.proto)" "ovpn" "2.4"                                                       
        test_eq "$(uci get firewall.@forwarding[-1].src)" "lan" "2.5"                     
        test_eq "$(uci get firewall.@forwarding[-1].dest)" "sabai" "2.6"                                              
        test_eq "$(uci get sabai.vpn.status)" "Disconnected" "2.7"                                                
        test_eq "$(uci get sabai.vpn.proto)" "ovpn" "2.8"                                 
        echo -e "\033[31m *********************************** \033[00m"                                          
        ifconfig tun0 | grep -q not                                                                              
        echo -e "\033[31m *********************************** \033[00m" 
	
	echo "---------------END OF START-TEST-----------------"
}

_update() {
	echo "*************************** Test Case 3 *****************************"                  
        echo -e "-> -> -> \033[32m Input: Ovpn config file present. Update procedure \033[00m"
	rm /tmp/.restart_services > /dev/null
	/www/bin/ovpn.sh update
	test_eq "$(uci get openvpn.sabai.log)" "/www/libs/data/stat/ovpn.log" "3.1"                    
        test_eq "$(uci get openvpn.sabai.enabled)" "1" "3.2"                                                     
        test_eq "$(uci get network.openvpn.ifname)" "tun0" "3.3"                                       
        test_eq "$(uci get network.openvpn.proto)" "ovpn" "3.4"                                                  
        test_eq "$(uci get firewall.@forwarding[-1].src)" "lan" "3.5"                
        test_eq "$(uci get firewall.@forwarding[-1].dest)" "sabai" "3.6"                                         
        test_eq "$(uci get sabai.vpn.status)" "Disconnected" "3.7"                                     
        test_eq "$(uci get sabai.vpn.proto)" "ovpn" "3.8"
	if [ "$(cat /tmp/.restart_services | grep -q firewall)" != "" ]; then                                                         
	        echo -e "\033[32m -> -> -> 3.9: Pass <- <- <- \033[00m"                                 
        else                                                                                                     
                echo -e "\033[31m -> -> -> 3.9: Fail <- <- <- \033[00m"                                           
        fi        

	echo -e "\033[31m *********************************** \033[00m"              
        ifconfig tun0 | grep -q not                                                                              
        echo -e "\033[31m *********************************** \033[00m" 		
}

_stop() {
        echo "*************************** Test Case 4 *****************************"                             
        echo -e "-> -> -> \033[32m Input: Stop procedure \033[00m"
	uci $UCI_PATH set sabai.vpn.proto=ovpn                          
        uci $UCI_PATH set sabai.vpn.status=Connected            
        uci $UCI_PATH commit sabai                                      
	/www/bin/ovpn.sh stop 
	test_eq "$(uci get sabai.vpn.status)" "none" "4.1"                            
	test_eq "$(uci get sabai.vpn.proto)" "none" "4.2"
	test_eq "$(uci get firewall.@forwarding[-1].src)" "" "4.3"
	test_eq "$(uci get network.openvpn)" "" "4.4"
}

_clear() {
        echo "*************************** Test Case 5 *****************************" 
        echo -e "-> -> -> \033[32m Input: Clear procedure \033[00m" 
        uci set openvpn.sabai.enabled=1                 
        uci set openvpn.sabai.filename=file                                             
        uci set network.vpn.proto=pptp                                                 
        uci commit                                                                      
        uci $UCI_PATH set sabai.vpn.status=Connected         
        uci $UCI_PATH set sabai.vpn.proto=ovpn                                          
        uci $UCI_PATH commit sabai
	/www/bin/ovpn.sh clear
	test_eq "$(uci get sabai.vpn.status)" "none" "5.1"                                                       
        test_eq "$(uci get sabai.vpn.proto)" "none" "5.2"                                     
        test_eq "$(uci get network.vpn.proto)" "none" "5.3"
        test_eq "$(uci get openvpn.sabai.enabled)" "0" "5.4"                                                     
        test_eq "$(uci get network.openvpn.ifname)" "tun0" "5.5"
	test_eq "$(cat /etc/sabai/openvpn/ovpn.current)" "" "5.6"
	test_eq "$(cat /etc/sabai/openvpn/ovpn)" "" "5.7"
	test_eq "$(cat /etc/sabai/openvpn/auth-pass)" "" "5.8"
}


case $action in
        start)  _start  ;;
        stop)   _stop   ;;
        update) _start  ;;
        save)   _save   ;;
        clear)  _clear  ;;
esac
