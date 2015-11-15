#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology

act=$1

set_config(){
	if [ "$(uci get sabai-new.firewall.$1)" = "on"  ]; then                 
		uci set sabai-new.firewall.$1="off"                      
	else                                                                      
        	uci set sabai-new.firewall.$1="on"                         
	fi
}

turn_icmp(){
	if [ "$(cat /etc/sysctl.conf | grep -q net.ipv4.icmp_echo_ignore_all)" != "" ] && [ "$1" = "off" ] ; then
		sed -i '' '/net.ipv4.icmp_echo_ignore_all/d' /etc/sysctl.conf                                             
		echo "net.ipv4.icmp_echo_ignore_all=1" >> /etc/sysctl.conf                                               
	elif [ "$(cat /etc/sysctl.conf | grep -q net.ipv4.icmp_echo_ignore_all)" != "" ] && [ "$1" = "on" ] ; then                                                                                                             
		sed -i '' '/net.ipv4.icmp_echo_ignore_all/d' /etc/sysctl.conf
		echo "net.ipv4.icmp_echo_ignore_all=0" >> /etc/sysctl.conf
	elif [ "$(cat /etc/sysctl.conf | grep -q net.ipv4.icmp_echo_ignore_all)" = "" ] && [ "$1" = "off" ] ; then
		echo "net.ipv4.icmp_echo_ignore_all=1" >> /etc/sysctl.conf
	elif [ "$(cat /etc/sysctl.conf | grep -q net.ipv4.icmp_echo_ignore_all)" = "" ]  && [ "$1" = "on" ] ; then
		echo "net.ipv4.icmp_echo_ignore_all=0" >> /etc/sysctl.conf
	else
		echo "Incorrect input test data."
		exit 1
	fi
}

turn_multicast(){
	if [ "$1" = "off" ]; then
		set network.lan.igmp_snooping=0                                                                              
		rule=$(uci show firewall | grep =igmp | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)                             
		[ -n "$rule" ] && uci delete firewall.@rule["$rule"] && uci delete firewall.@rule["$rule"] && uci commit firewall
	else
		set network.lan.igmp_snooping=1
		rule=$(uci show firewall | grep =igmp | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)                         
		if [ "$rule" = "" ]; then                                                                                    
                	uci add firewall rule                                                     
                	uci set firewall.@rule[-1].src=wan                                        
                	uci set firewall.@rule[-1].proto=igmp                                                                
                	uci set firewall.@rule[-1].target=ACCEPT                                                             
                	uci commit firewall                                                       
                	uci add firewall rule                                                     
               		uci set firewall.@rule[-1].src=wan                                                                   
			uci set firewall.@rule[-1].proto="tcpudp"                                                            
			uci set firewall.@rule[-1].dest=lan                                       
			uci set firewall.@rule[-1].target=ACCEPT                                  
			uci set firewall.@rule[-1].family=ipv4                                                               
			uci commit firewall                                                                                  
		else                                                                              
			echo "IGMP was turned on."
		fi
	fi
}

turn_cookies(){
	if [ "$1" = "on" ]; then	
		uci set firewall.@defaults[].tcp_syncookies=1                                                                         
	else
		uci set firewall.@defaults[].tcp_syncookies=0
	fi
	uci commit firewall
}

echo "---------------START OF FIREWALL-TEST-----------------"


update() {	
echo "***Test case 1***"
echo "-> -> -> Expecting "Update" procedure. Only update features."
rm /tmp/.restart_services > /dev/null
#Input test parameters
cp /configs/sabai /etc/config/sabai-new
set_config icmp
set_config multicast
set_config cookies
set_config wanroute
uci commit sabai-new

/www/bin/firewall.sh update > /tmp/.tmptestres
check="$(cat /tmp/.tmptestres | grep invalid)"
if [ "$check" = "" ]; then                             
        echo "-> -> -> 1.1: Pass <- <- <-"              
else                                                    
        echo "-> -> -> 1.1: Failed <- <- <-"            
	echo -e "TEST LOG:\n $check"
	exit 1
fi

check=$(cat /tmp/.restart_services)
if [ "$check" != "" ]; then
	echo "-> -> -> 1.2: Pass <- <- <-"
else
	echo "-> -> -> 1.2: Failed <- <- <-"
	echo -e "TEST LOG:\n $check"
	exit 1
fi

}

config_1() {
echo "***Test case 2***"
echo "-> -> -> All settings are changed to ON."

icmp="on"                           
multicast="on"                                             
cookies="on"                                               
wanroute="on"

#Setting all to off
turn_icmp off
turn_multicast off
turn_cookies off
#wanroute off - no implementation for on/off
uci get firewall.@defaults[].tcp_syncookies
/www/bin/firewall.sh $icmp $multicast $cookies $wanroute
cat /etc/sysctl.conf | grep  "net.ipv4.icmp_echo_ignore_all" | grep -q "0"
if [ $? -eq 0 ]; then
        echo "-> -> -> 2.1: Pass <- <- <-"    
else                                          
        echo "-> -> -> 2.1: Failed <- <- <-"  
	cat /etc/sysctl.conf | grep  "net.ipv4.icmp_echo_ignore_all"
	exit 1
fi 
cat /etc/config/network | grep "option igmp_snooping" | grep -q "1" 
if [ $? -eq 0 ]; then                                                            
        echo "-> -> -> 2.2: Pass <- <- <-"  
else                                        
        echo "-> -> -> 2.2: Failed <- <- <-"                                      
	cat /etc/config/network | grep "option igmp_snooping"
	exit 1
fi
cat /etc/config/firewall  | grep -q igmp
if [ $? -eq 0 ]; then                                                            
        echo "-> -> -> 2.3: Pass <- <- <-"                                       
else                                                                                         
        echo "-> -> -> 2.3: Failed <- <- <-"                                                 
	echo "No igmp setting in firewall."
	exit 1
fi
cat /etc/igmpproxy.conf | grep -q lan
if [ $? -eq 0 ]; then                                                                        
        echo "-> -> -> 2.4: Pass <- <- <-"                                                   
else                                                                             
        echo "-> -> -> 2.4: Failed <- <- <-"             
	echo "Incorrect settings in igmpproxy.conf"
	exit 1
fi
cat /etc/config/firewall | grep "option tcp_syncookies" | grep -q "1"
if [ $? -eq 0 ]; then                                                                        
        echo "-> -> -> 2.5: Pass <- <- <-"                                       
else                                                                             
        echo "-> -> -> 2.5: Failed <- <- <-"                                                 
	echo "Incorrect tcp_syncookies settings in firewall."
	cat /etc/config/firewall | grep "option tcp_syncookies"
	exit 1	
fi  

}

config_2() {
echo "***Test case 3***"                                                  
echo "-> -> -> All settings are changed to Off. "

icmp="off"                                                                 
multicast="off"                                                                   
cookies="off"                                                              
wanroute="off"                                                                    

#Setting all to on                                                                                               
turn_icmp on                                                                                                                    
turn_multicast on                                                                                                               
turn_cookies on                                                                                                  
#wanroute on - no implementation for on/off

/www/bin/firewall.sh $icmp $multicast $cookies $wanroute           

cat /etc/sysctl.conf | grep  "net.ipv4.icmp_echo_ignore_all" | grep -q "1"                   
if [ $? -eq 0 ]; then                                                            
        echo "-> -> -> 3.1: Pass <- <- <-"                                       
else                                                                             
        echo "-> -> -> 3.1: Failed <- <- <-"                                     
	cat /etc/sysctl.conf | grep  "net.ipv4.icmp_echo_ignore_all"                                                             
	echo "Incorrect net.ipv4.icmp_echo_ignore_all setting."
        exit 1	
fi                                                                               
                                                                                  
if [ "$(uci get network.lan.igmp_snooping)" -eq 0 ]; then                                                            
        echo "-> -> -> 3.2: Pass <- <- <-"                                                   
else                                                                             
        echo "-> -> -> 3.2: Failed <- <- <-"                                     
	echo "No igmp setting in firewall."                                                                        
	exit 1	
fi                                                                                           
if [ "$(uci get firewall.@defaults[].tcp_syncookies)" -eq 0 ]; then                                                            
        echo "-> -> -> 3.3: Pass <- <- <-"                                       
else                                                                             
        echo "-> -> -> 3.3: Failed <- <- <-"                                     
	echo "Incorrect tcp_syncookies settings in firewall."                                                                    
	cat /etc/config/firewall | grep "option tcp_syncookies"                                                                  
	exit 1	
fi

}
case $act in
	1)	update ;;
	2)	config_1 ;;
	3)	config_2 ;;
	all)	update; config_1; config_2 ;; 
esac

echo "---------------END OF FIREWALL-TEST-----------------"
