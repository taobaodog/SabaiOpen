#!/bin/ash

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
	echo "*************************** Test Case 1 ******************************"
	echo -e "-> -> -> \033[32m Input: PPTP. Writing parameters to config sabai. \033[00m"
	uci $UCI_PATH set sabai.vpn.proto=none
	uci $UCI_PATH set sabai.vpn.status=none
	uci $UCI_PATH set sabai.vpn.username=vpn593
	uci $UCI_PATH set sabai.vpn.server=vpn-in22.reliablehosting.com
	uci $UCI_PATH set sabai.vpn.password=3KTh84zEH2
	uci $UCI_PATH commit sabai

	if [ "$(uci get network.vpn)" != "" ]; then
		uci delete network.vpn
		uci commit network
	fi

	if [ "$(uci get firewall.vpn)" != "" ]; then                                                              
                uci delete firewall.vpn                                               
                uci commit firewall                                                           
        fi 

	uci set network.vpn.proto=none
	uci commit network  
	cat /dev/null > /tmp/.restart_services
	
	/www/bin/pptp.sh start $1

	test_eq "$(uci get network.vpn.ifname)" "pptp-vpn" "1.1"
	test_eq "$(uci get network.vpn.proto)" "$(uci get sabai.vpn.proto)" "1.2"
	test_eq "$(uci get network.vpn.username)" "vpn593" "1.3"
	test_eq "$(uci get network.vpn.password)" "3KTh84zEH2" "1.4"
	test_eq "$(uci get network.vpn.server)" "vpn-in22.reliablehosting.com" "1.5"
	test_eq "$(uci get network.vpn.buffering)" "1" "1.6"
	test_eq "$(uci get firewall.vpn.name)" "vpn" "1.7"
	test_eq "$(uci get firewall.vpn.output)" "ACCEPT" "1.8" 
	test_eq "$(uci get firewall.@forwarding[-1].src)" "lan" "1.9" 
	if [ "$1" == "" ]; then
		test_eq "$(cat /tmp/.restart_services)" "" "1.10" 
	fi
	ifconfig > /tmp/ifconfig_check
	echo "Checking pptp connection ..."
	sleep 25
	if [ "$(cat /tmp/ifconfig_check | grep -q pptp-vpn)" == "" ]; then
		test_eq "$(uci get sabai.vpn.status)" "Connected" "1.11"
	else
		test_eq "$(uci get sabai.vpn.status)" "Disconnected" "1.11"
		echo -e "\033[31m *********************************** \033[00m"
		ifconfig pptp-vpn | grep -q not
		echo -e "\033[31m *********************************** \033[00m"
	fi

}

_update() {
	echo "*************************** Test Case 2 including 1 ******************************" 	
	echo -e "-> -> -> \033[32m Input: PPTP. Update procedure. Includes start pptp. \033[00m"
	_start update
	if [ "$(cat /tmp/.restart_services | grep  network)" != "" ]; then		
	        echo -e "\033[32m -> -> -> 2.1: Pass <- <- <- \033[00m"                                            
        else                                                                                                      
                echo -e "\033[31m -> -> -> 2.1: Fail <- <- <- \033[00m"                                            
        fi		
}

_stop() {
	echo "*************************** Test Case 3******************************" 	
	echo -e "-> -> -> \033[32m Input: PPTP. Start->Stop procedure. Includes start and stop pptp. \033[00m"
	_start > /dev/null
	echo -e "-> -> -> \033[32m PPTP started. Stop procedure in progress ... \033[00m" 
	sleep 10
	/www/bin/pptp.sh stop
	test_eq "$(uci get network.vpn)" "" "3.1"
	test_eq "$(uci get firewall.vpn)" "" "3.2"
	test_eq "$(uci get network.vpn.proto)" "none" "3.3"
	test_eq "$(uci get sabai.vpn.status)" "none" "3.4"
	test_eq "$(uci get sabai.vpn.proto)" "none" "3.5"		
		
}

_clear() {
	echo "*************************** Test Case 4******************************"
        echo -e "-> -> -> \033[32m Input: PPTP. Start->Clear procedure. Includes start and clear pptp. \033[00m"
        _start > /dev/null
	echo -e "-> -> -> \033[32m PPTP started. Clear procedure in progress ... \033[00m"
	sleep 10
	/www/bin/pptp.sh clear
	test_eq "$(uci get network.vpn)" "" "4.1"
	test_eq "$(uci get firewall.vpn)" "" "4.2"
	test_eq "$(uci get sabai.vpn.status)" "none" "4.3"
	test_eq "$(uci get sabai.vpn.proto)" "none" "4.4"
	test_eq "$(uci get network.vpn.proto)" "none" "4.5"
		
}
case $action in
        start)  _start  ;;
	update) _update ;;
	stop)	_stop ;;	
	clear)	_clear ;;
esac
