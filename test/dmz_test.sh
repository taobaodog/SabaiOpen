#!/bin/ash

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
cat /etc/config/firewall | grep -q "redirect"
if [ $? -eq 0 ]; then
	uci delete firewall.@redirect[0]
else
	echo "Script is running ..."	
fi
/www/bin/dmz.sh $status $destination
if [ "$(uci get firewall.@redirect[0])" != ""  ]; then
	echo -e "\033[32m -> -> -> 1.1: Pass <- <- <- \033[00m"
else
	echo -e "\033[31m -> -> -> 1.1: Fail <- <- <- \033[00m"
fi

check=$(cat /tmp/dmz | grep "condition 1")
if [ $? -eq 0 ]; then
	echo -e "\033[32m -> -> -> 1.2: Pass <- <- <- \033[00m"
else                                                
        echo -e "\033[31m -> -> -> 1.2: Fail <- <- <- \033[00m"          
fi
}

second(){
echo "************************** Test case 2 *********************************"
echo -e "-> -> -> \033[32m Input: status=off destination=192.168.199.222 \033[00m"
status="off"                                                                      
destination="192.168.199.222"                                                    
cat /etc/config/firewall | grep -q "redirect"                                    
if [ $? -eq 0 ]; then                                                            
	echo "Script is running ..."
else                                                                             
	uci add firewall redirect     
        uci set firewall.@redirect[0].src='wan'
        uci set firewall.@redirect[0].proto='tcp udp'
        uci set firewall.@redirect[0].src_dport='1-65535'
        uci set firewall.@redirect[0].dest_ip=$destination
fi                                                                               
/www/bin/dmz.sh $status $destination                                             
if [ "$(uci get firewall.@redirect[0])" == ""  ]; then                                                   
        echo -e "\033[32m -> -> -> 1.1: Pass <- <- <- \033[00m"
else                                                        
        echo -e "\033[31m -> -> -> 1.1: Fail <- <- <- \033[00m"
fi                                                          
                                                            
check=$(cat /tmp/dmz | grep "condition 2")                  
if [ $? -eq 0 ]; then                                       
        echo -e "\033[32m -> -> -> 2.2: Pass <- <- <- \033[00m"
else                                                        
        echo -e "\033[31m -> -> -> 2.2: Fail <- <- <- \033[00m"
fi

}

third(){
echo "*************************** Test Case 3 ******************************"     
echo -e "-> -> -> \033[32m Input: status=none destination=none action=update \033[00m" 
/www/bin/dmz.sh update                                             
if [ "$(uci get sabai.dmz.status)" == "on"  ]; then
	if [ "$(uci get firewall.@redirect[0])" != ""  ]; then                                                     
		echo -e "\033[32m -> -> -> 3.1.1: Pass <- <- <- \033[00m"
	else                                                                              
        	echo -e "\033[31m -> -> -> 3.1.1: Fail <- <- <- \033[00m"                   
	fi
else
        if [ "$(uci get firewall.@redirect[0])" == ""  ]; then                                                  
                echo -e "\033[32m -> -> -> 3.1.2: Pass <- <- <- \033[00m"           
        else                                                                      
                echo -e "\033[31m -> -> -> 3.1.2: Fail <- <- <- \033[00m"           
        fi
fi                                                                                
                                                                                  
check=$(cat /tmp/.restart_services | grep "firewall")                                        
if [ $? -eq 0 ]; then                                                             
        echo -e "\033[32m -> -> -> 3.2: Pass <- <- <- \033[00m"                   
else                                                                              
        echo -e "\033[31m -> -> -> 3.2: Fail <- <- <- \033[00m"                   
fi
}

case $act in
	1) first ;;
	2) second ;;
	3) third ;;
	all) first; second; third ;; 
esac

echo "----------------END OF DMZ-TEST----------------"
