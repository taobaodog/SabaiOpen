#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology

act=$1

#path to config files                                                        
UCI_PATH="-c /configs" 

echo "---------------------- PROXY TESTING ------------------------"
echo -e "\n"
test1() {
echo "*************************** Test Case 1 ******************************"
echo "-> -> -> Start arg test:"
uci $UCI_PATH set sabai.proxy.status="none"
uci $UCI_PATH commit sabai
/www/bin/proxy.sh proxystart
if [ "$(uci get sabai.proxy.status)" == "On" ]; then
	echo "-> -> -> 1.1: Pass <- <- <-"
else
	uci show sabai.proxy.status
	echo "-> -> -> 1.1: Failed <- <- <-"
fi

proxyroute=$(cat /etc/privoxy/config | grep -e "permit-access" | awk -F: '{print $0}' | awk '{print $2}')
check=$(cat /etc/privoxy/config | grep "$proxyroute")
if [ "$check" != "" ]; then
	echo "-> -> -> 1.2: Pass <- <- <-"                                                                                                     
else                                                                                                                                           
	echo $check
	echo "-> -> -> 1.2: Failed <- <- <-"                                                                                                   
fi 
}

test2() {
echo "************************** Test Case 2 ******************************"    
echo "-> -> -> Stop arg test:"                                         
uci $UCI_PATH set sabai.proxy.status="none"                                                            
uci $UCI_PATH commit sabai
/www/bin/proxy.sh proxystop
if [ "$(uci get sabai.proxy.status)" == "Off" ]; then
        echo "-> -> -> 2.1: Pass <- <- <-"                                   
else                                                                         
	uci show sabai.proxy.status
        echo "-> -> -> 2.1: Failed <- <- <-"                                 
fi 

}


case $act in                                                                         
        1) test1 ;;                                               
        2) test2 ;;                                                      
        all) test1; test2 ;;
esac
echo -e "\n"              
echo "---------------------- PROXY TESTING END ------------------------" 
