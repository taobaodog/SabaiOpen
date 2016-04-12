#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2016 Sabai Technology

#cat /dev/null > /tmp/dmz

#path to config files
UCI_PATH="-c /configs"

echo "---------------START OF DMZ-TEST---------------"
echo -e "\n"

act=$1

first(){
echo "*************************** Test Case 1 ******************************"
echo -e "-> -> -> \033[32m Input: status=on destination=192.168.199.221 \033[00m"
status="on"
destination="192.168.199.221"
indx_redirect=$(uci show firewall | grep -q "DMZ" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
if [ "$indx_redirect" != "" ]; then
	uci delete firewall.@redirect["$indx_redirect"]
else
	echo "Script is running ..."	
fi

/www/bin/dmz.sh $status $destination
indx_redirect=$(uci show firewall | grep -q "DMZ" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
if [ "$(uci get firewall.@redirect["$indx_redirect"])" != ""  ]; then
	echo -e "\033[32m -> -> -> 1.1: Pass <- <- <- \033[00m"
else
	echo -e "\033[31m -> -> -> 1.1: Fail. Firewall rule was not added. <- <- <- \033[00m"
	exit 1
fi
}

second(){
echo "************************** Test case 2 *********************************"
echo -e "-> -> -> \033[32m Input: status=off destination=192.168.199.222 \033[00m"
status="off"                                                                      
destination="192.168.199.222"                                                    
indx_redirect=$(uci show firewall | grep -q "DMZ" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
if [ "$indx_redirect" != "" ]; then                                                            
	uci add firewall redirect     
        uci set firewall.@redirect[-1].src='wan'
        uci set firewall.@redirect[-1].proto='tcp udp'
        uci set firewall.@redirect[-1].src_dport='1-65535'
        uci set firewall.@redirect[-1].dest_ip=$destination
else
	echo "Script is running ..."
fi
                                                                               
/www/bin/dmz.sh $status $destination                                             
indx_redirect=$(uci show firewall | grep -q "DMZ" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
if [ "$indx_redirect" == ""  ]; then                                                   
        echo -e "\033[32m -> -> -> 2.1: Pass <- <- <- \033[00m"
else                                                        
        echo -e "\033[31m -> -> -> 2.1: Fail. Firewall rule was not cleared. <- <- <- \033[00m"
	exit 1
fi                                                          
}

third(){
echo "*************************** Test Case 3 ******************************"     
echo -e "-> -> -> \033[32m Input: status=from sabai-new; destination=from sabai-new; action=update \033[00m" 
cp /etc/config/sabai /etc/config/sabai-new
uci set sabai-new.dmz.status="on"
uci set sabai-new.dmz.destination="192.168.199.223"
uci commit sabai-new

echo "A) Status=on Destination=192.168.199.223"
/www/bin/dmz.sh update                                             
indx_redirect=$(uci show firewall | grep -q "DMZ" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
if [ "$(uci get firewall.@redirect[$indx_redirect])" != ""  ]; then                                                     
	echo -e "\033[32m -> -> -> 3.1: Pass <- <- <- \033[00m"
else                                                                              
       	echo -e "\033[31m -> -> -> 3.1: Fail. Firewall rule was not added. <- <- <- \033[00m"                   
	exit 1
fi

sleep 5
echo "B) Status=off Destination=192.168.199.224"
cp /etc/config/sabai /etc/config/sabai-new                                                                  
uci set sabai-new.dmz.status="off"                                                                      
uci set sabai-new.dmz.destination="192.168.199.224"                                                    
uci commit sabai-new
/www/bin/dmz.sh update 
indx_redirect=$(uci show firewall | grep -q "DMZ" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
if [ "$indx_redirect" == ""  ]; then                                                  
	echo -e "\033[32m -> -> -> 3.2: Pass <- <- <- \033[00m"           
else                                                                      
	echo -e "\033[31m -> -> -> 3.2: Fail. Firewall rule was not cleared. <- <- <- \033[00m"           
	exit 1
fi
}

case $act in
	1) first ;;
	2) second ;;
	3) third ;;
	all) first; second; third ;; 
esac

echo "----------------END OF DMZ-TEST----------------"
