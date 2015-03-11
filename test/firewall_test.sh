#!/bin/ash

act=$1
echo "---------------START OF FIREWALL-TEST-----------------"


update() {	
echo "***Test case 1***"
echo "-> -> -> Expecting "Update" procedure"
rm /tmp/.restart_services > /dev/null
/www/bin/firewall.sh update > /tmp/.tmptestres
check=$(cat /tmp/.tmptestres | grep invalid)
if [ "$check" != "" ]; then                             
        echo "-> -> -> 1.1: Pass <- <- <-"              
else                                                    
        echo "-> -> -> 1.1: Failed <- <- <-"            
fi

check=$(cat /tmp/.restart_services)
if [ "$check" != "" ]; then
	echo "-> -> -> 1.2: Pass <- <- <-"
else
	echo "-> -> -> 1.2: Failed <- <- <-"
fi

}

config_1() {
echo "***Test case 2***"
echo "-> -> -> All settings are changed to ON."
icmp="on"                           
multicast="on"                                             
cookies="on"                                               
wanroute="on"
echo "Please wait ... "
/www/bin/firewall.sh off off off off > /dev/null
/www/bin/firewall.sh $icmp $multicast $cookies $wanroute
cat /etc/sysctl.conf | grep  "net.ipv4.icmp_echo_ignore_all" | grep -q "0"
if [ $? -eq 0 ]; then
        echo "-> -> -> 2.1: Pass <- <- <-"    
else                                          
        echo "-> -> -> 2.1: Failed <- <- <-"  
fi 

cat /etc/config/network | grep "option igmp_snooping" | grep -q "1" 
if [ $? -eq 0 ]; then                                                            
        echo "-> -> -> 2.2: Pass <- <- <-"  
else                                        
        echo "-> -> -> 2.2: Failed <- <- <-"                                      
fi
cat /etc/config/firewall  | grep -q igmp
if [ $? -eq 0 ]; then                                                            
        echo "-> -> -> 2.3: Pass <- <- <-"                                       
else                                                                                         
        echo "-> -> -> 2.3: Failed <- <- <-"                                                 
fi
cat /etc/igmpproxy.conf | grep -q wan
if [ $? -eq 0 ]; then                                                                        
        echo "-> -> -> 2.4: Pass <- <- <-"                                                   
else                                                                             
        echo "-> -> -> 2.4: Failed <- <- <-"             
fi 
cat /etc/config/firewall | grep "option tcp_syncookies" | grep -q "1"
if [ $? -eq 0 ]; then                                                                        
        echo "-> -> -> 2.5: Pass <- <- <-"                                       
else                                                                             
        echo "-> -> -> 2.5: Failed <- <- <-"                                                 
fi  

}

config_2() {
echo "***Test case 3***"                                                  
echo "-> -> -> All settings are changed to Off. "
icmp="off"                                                                 
multicast="off"                                                                   
cookies="off"                                                              
wanroute="off"                                                                    
echo "Please wait ... "                                                           
/www/bin/firewall.sh on on on on > /dev/null                                             
/www/bin/firewall.sh $icmp $multicast $cookies $wanroute           
cat /etc/sysctl.conf | grep  "net.ipv4.icmp_echo_ignore_all" | grep -q "1"                   
if [ $? -eq 0 ]; then                                                            
        echo "-> -> -> 3.1: Pass <- <- <-"                                       
else                                                                             
        echo "-> -> -> 3.1: Failed <- <- <-"                                     
fi                                                                               
                                                                                  
cat /etc/config/network | grep "option igmp_snooping"                          
if [ $? -eq 1 ]; then                                                            
        echo "-> -> -> 3.2: Pass <- <- <-"                                                   
else                                                                             
        echo "-> -> -> 3.2: Failed <- <- <-"                                     
fi                                                                                           
cat /etc/config/firewall | grep "option tcp_syncookies" | grep -q "0"
if [ $? -eq 0 ]; then                                                            
        echo "-> -> -> 3.3: Pass <- <- <-"                                       
else                                                                             
        echo "-> -> -> 3.3: Failed <- <- <-"                                     
fi
}
case $act in
	1)	update ;;
	2)	config_1 ;;
	3)	config_2 ;;
	all)	update; config_1; config_2 ;; 
esac

echo "---------------END OF FIREWALL-TEST-----------------"
