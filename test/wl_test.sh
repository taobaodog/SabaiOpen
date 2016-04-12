#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2016 Sabai Technology

act=$1

#path to config files
UCI_PATH="-c /configs"

echo "---------------------- WL TESTING ------------------------"
echo -e "\n"

base_test() {                                                                       
check="$(uci get sabai.wlradio0.ssid)"                                       
if [ "$check" == "$(uci get wireless.@wifi-iface[0].ssid)" ]; then                  
        echo "-> -> -> 0.1: Pass <- <- <-"                                          
else                                                                                
        echo $check                                                                 
        echo "-> -> -> 0.1: Failed <- <- <-"                                        
fi                                                                                  

if [ "$(uci get sabai.wlradio0.encryption)" == "wep" ]; then                                                                                     
	if [ "wep" == "$(uci get wireless.@wifi-iface[0].encryption)" ]; then            
        	echo "-> -> -> 0.2: Pass <- <- <-"                                          
	else                                                                                
        	echo $check                                                                                                            
        	echo "-> -> -> 0.2: Failed <- <- <-"                                        
	fi
else    
	wpa_encryption=$(uci get sabai.wlradio0.wpa_encryption)                                                                        
	encryption=$(uci get sabai.wlradio0.encryption)                                                                                                
	check=$(echo "$encryption+$wpa_encryption")   
        if [ "$check" == "$(uci get wireless.@wifi-iface[0].encryption)" ]; then        
                echo "-> -> -> 0.2: Pass <- <- <-"                                                                             
        else                                                                                                                   
                echo $check                                                                                                                    
                echo "-> -> -> 0.2: Failed <- <- <-"                                 
        fi                                                                                                                                
fi
} 


test1() {
echo "*************************** Test Case 1 ******************************"
echo "-> -> -> Expecting "Save" procedure and wlradio0.mode=off"
uci $UCI_PATH set sabai.wlradio0.mode=off
uci $UCI_PATH commit sabai
/www/bin/wl.sh
check=$(uci get wireless.@wifi-iface[0].mode)
if [ "$check" == "" ]; then
	echo "-> -> -> 1.1: Pass <- <- <-"
else
	echo $check
	echo "-> -> -> 1.1: Failed <- <- <-"
fi
}


test2() {
echo "*************************** Test Case 2 ******************************"
echo "-> -> -> Expecting "Save" procedure and wlradio0.mode=on:"
uci $UCI_PATH set sabai.wlradio0.mode=on
uci $UCI_PATH commit sabai
/www/bin/wl.sh
check=$(uci get wireless.@wifi-iface[0].mode)
if [ "$check" != "" ]; then
	echo "-> -> -> 2.1: Pass <- <- <-"
else
        echo $check
        echo "-> -> -> 2.1 Failed <- <- <-"
fi
}

test3() {
echo "*************************** Test Case 3 ******************************"
echo "-> -> -> WEP input arg test: Expecting "Save" procedure and wlradio0.mode=on:"
uci $UCI_PATH set sabai.wlradio0.mode=on                                     
uci $UCI_PATH set sabai.wlradio0.encryption=wep
uci $UCI_PATH commit sabai
/www/bin/wl.sh
wepkey=$(uci get sabai.wlradio0.wepkeys)
check=$(echo $wepkey |awk -F: '{print $0}' | awk '{print $1}')
if [ "$(uci get wireless.@wifi-iface[0].key1)" == "$check" ]; then
	echo "KEY1 PASS"
else
	echo "KEY1 FAILED"
	echo $check "!=" $(uci get wireless.@wifi-iface[0].key1)
fi

check=$(echo $wepkey |awk -F: '{print $0}' | awk '{print $2}')
if [ "$(uci get wireless.@wifi-iface[0].key2)" == "$check" ]; then                   
        echo "KEY2 PASS"                                                            
else                                                                                 
        echo "KEY2 FAILED"                                                           
	echo $check "!=" $(uci get wireless.@wifi-iface[0].key2)
fi

check=$(echo $wepkey |awk -F: '{print $0}' | awk '{print $3}')                      
if [ "$(uci get wireless.@wifi-iface[0].key3)" == "$check" ]; then                   
        echo "KEY3 PASS"                                                            
else                                                                                 
        echo "KEY3 FAILED"                                                           
	echo $check "!=" $(uci get wireless.@wifi-iface[0].key3)
fi 

check=$(echo $wepkey |awk -F: '{print $0}' | awk '{print $4}')                      
if [ "$(uci get wireless.@wifi-iface[0].key4)" == "$check" ]; then                    
        echo "KEY4 PASS"                                                            
else                                                                                
        echo "KEY4 FAILED"                                                           
	echo $check "!=" $(uci get wireless.@wifi-iface[0].key4)
fi

check=4
if [ "$(uci get wireless.@wifi-iface[0].key)" == "4" ]; then                   
        echo "KEY PASS"                                                            
else                                                                                 
        echo "KEY FAILED"                                                           
	echo $check "!=" $(uci get wireless.@wifi-iface[0].key)
fi 
}

test4() {
echo "*************************** Test Case 4 ******************************"
echo "-> -> -> PSK input arg test: Expecting "Save" procedure and wlradio0.mode=on:"
uci $UCI_PATH set sabai.wlradio0.mode=on                                     
uci $UCI_PATH set sabai.wlradio0.encryption=psk
uci $UCI_PATH commit sabai                                                   
/www/bin/wl.sh 
key=$(uci get sabai.wlradio0.wpa_psk)
if [ "$(uci get wireless.@wifi-iface[0].key)" == "$key" ]; then 
	echo "-> -> -> 4.1 Pass <- <- <-"
else
	echo $check                                                          
        echo "-> -> -> 4.1 Failed <- <- <-"                                      
fi       

}

test5() {                                                                           
echo "*************************** Test Case 5 ******************************"       
echo "-> -> -> PSK2 input arg test: Expecting "Save" procedure and wlradio0.mode=on:"
uci $UCI_PATH set sabai.wlradio0.mode=on                                            
uci $UCI_PATH set sabai.wlradio0.encryption=psk2                              
uci $UCI_PATH commit sabai                                                          
/www/bin/wl.sh                                                                   
                                                                                    
key=$(uci get sabai.wlradio0.wpa_psk)                                                                                          
if [ "$(uci get wireless.@wifi-iface[0].key)" == "$key" ]; then                                                                
        echo "-> -> -> 5.1 Pass <- <- <-"                                                                                      
else                                                                                                                           
        echo $check                                                                                                            
        echo "-> -> -> 5.1 Failed <- <- <-"                                                                                    
fi  
} 

case $act in
	1) test1; base_test ;;
	2) test2; base_test ;;
	3) test3; base_test ;;
	4) test4; base_test ;;
	5) test5; base_test ;;
	all) test1; base_test; test2; base_test; test3; base_test; test4; base_test; test5; base_test ;; 
esac

echo "---------------------- WL TESTING END ------------------------"
