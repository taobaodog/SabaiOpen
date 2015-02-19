#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology
# iptables rules are stored in /etc/sabai/firewall.settings

#To Do get Enable WAN access working - Test

###################################################
#this script developed to set four variables to be 
#on or off according to user input 
###################################################

###################################
#SCRIPT HELP 
###################################

###############
#Used Variables 
###############
if [ $# -ne 4 ]; then
	action=$1
else
	action=$save
	cat << 'EOF'
   
    this script for setting four parameters
    usage: 
       	 #./firewall.sh $icmp $multicast $cookies $wanroute 
    Parameters: 
    	[icmp]  on/off this to enable/disablke ping           
    	[multicast] on/off this is to enable/disable udp multicast  
    	[cookies] on/off this to enable/disable syn-cookie 
    	[wanroute] this is to enable/disable external access to router  
                                       
	Examples:
		to run use the following 
		#firewall.sh on off on off  
  
	EOF
	exit 
	fi
	
	icmp=$1;
	multicast=$2;
	cookies=$3;
	wanroute=$4;
fi

#wanport=$(uci get network.wan.ifname);

#############################
#Script Function 
#############################

#########################
#set wan response to ping
#########################
if [ "$icmp" = "on" ] 
then
     #turn on icmp response on wan sidea
     #disabling/enabling icmp ping using /etc/sysctl.conf "net.ipv4.icmp_echo_ignore_all" variable
     #checking if strng  is exist 
     cat /etc/sysctl.conf | grep -q "net.ipv4.icmp_echo_ignore_all" 
     if [ $? -eq 0 ] 
     then 
           #string existed just update it to be 0 or 1 inorder to enable/disable icmp ping
           cat /etc/sysctl.conf | grep  "net.ipv4.icmp_echo_ignore_all" | grep -q "0" 
           if [ $? -eq 0 ] 
           then 
               echo "icmp response on"  
           else 
               echo "enabling icmp response ...." 
               sed -i 's/net.ipv4.icmp_echo_ignore_all=1/net.ipv4.icmp_echo_ignore_all=0/'  /etc/sysctl.conf 
           fi 
            
     else 
      #string not found append string to the file 
      echo "net.ipv4.icmp_echo_ignore_all=0" >> /etc/sysctl.conf 
     fi  
      
elif [ "$icmp" = "off" ] 
then 
	echo "you entered icmp off"
	cat /etc/sysctl.conf | grep -q "net.ipv4.icmp_echo_ignore_all"
	if [ $? -eq 0 ]
	then
	cat /etc/sysctl.conf | grep  "net.ipv4.icmp_echo_ignore_all" | grep -q "1"
    	if [ $? -eq 0 ]
		then
			echo "icmp response off"
		else
			echo "disabling icmp response .." 
			sed -i 's/net.ipv4.icmp_echo_ignore_all=0/net.ipv4.icmp_echo_ignore_all=1/'  /etc/sysctl.conf
		fi
	else
		echo "net.ipv4.icmp_echo_ignore_all=1" >> /etc/sysctl.conf
	fi                                                                                                      
else 	
	echo "ERROR invalid icmp only on/off Accepted"
fi
sysctl -newp | grep -q done 


###################################
###set ability to receive multicast
###################################

#here we are going to enable/disable UDP mulitcasting 
# should prevent unnecessary traffic on ports that were not actually subscribing.
#this is done by enable  IGMP snooping 

if [ "$multicast" = "on" ]
then
     
	#turn on multicast 
	echo "UDP  multicast is enabled "
	#1-INSTALL IGMPPROXY
	opkg install igmpproxy

	#2-enableigmpsnooping in /etc/config/network 
	cat /etc/config/network | grep -q igmp_snooping
	if [ $? -eq 0 ]
	then
		sed -i '/igmp_snooping/d' /etc/config/network
		sed -i '/lan/a        option igmp_snooping  1' /etc/config/network
	else
		sed -i '/lan/a        option igmp_snooping  1' /etc/config/network
	fi

	#3-configure firewall to accept igmp 
	cat /etc/config/firewall  | grep -q igmp 
	if [ $? -ne 0 ]
	then 
		echo "config rule
		option src      wan
		option proto    igmp
		option target   ACCEPT

		config rule
			option src      wan
			option proto    udp
			option dest     lan
			option target   ACCEPT
			option family   ipv4" >> /etc/config/firewall 
	else 
		echo -n 
	fi
	
	#4-configure igmpproxy 
	cat /etc/igmpproxy.conf | grep -q wan 
	if [ $? -ne 0 ]
	then 
		echo "phyint wan upstream ratelimit 0 threshold 1
		phyint lan downstream ratelimit 0 threshold 1" >>  /etc/igmpproxy.conf
	else 
		echo -n 
	fi
elif [ "$multicast" = "off" ]
then
	echo "udp multicast  disabled"
	sed -i '/igmp_snooping/d' /etc/config/network
else
	echo "ERROR invalid multicast only on/off Accepted"
fi

################                         
#Set Syn Cookies
################ 
if [ "$cookies" = "on" ]
then
	#turn on Syn cookie 
	echo "Syn-Cookies is on"
	#checking for string in default then delet it after that append it n default part 
	cat /etc/config/firewall | grep -q tcp_syncookies
	if [ $? -eq 0 ] 
	then 
		sed -i '/tcp_syncookies/d' /etc/config/firewall 
		sed -i '/defaults/a        option tcp_syncookies   1' /etc/config/firewall       
	else
		sed -i '/defaults/a        option tcp_syncookies   1' /etc/config/firewall 
	fi 
          
elif [ "$cookies" = "off" ]
then
	echo "Syn-Cookies is off"
	cat /etc/config/firewall | grep -q tcp_syncookies 
	if [ $? -eq 0 ] 
	then 
		sed -i '/tcp_syncookies/d' /etc/config/firewall
		sed -i '/defaults/a        option tcp_syncookies   0' /etc/config/firewall
	else
		sed -i '/defaults/a        option tcp_syncookies   0' /etc/config/firewall   
	fi   
else
	echo "ERROR invalid cookies only on/off Accepted"   
fi

##################
external wan Route
##################

#allow wan route input
if [ "$wanroute" = "on" ]
then
	#turn on multicast
	echo "you enabled external wan route "
elif [ "$wanroute" = "off" ]
then
	echo "you disabled external wanroute"
else
	echo "ERROR invalid wanroute only on/off Accepted"
fi

if [ $action = "update" ]; then
	echo "firewall" >> /tmp/.restart_services
else
	/etc/init.d/firewall restart 
	logger "firewall run and restarted"
	# restart any services like firewall or network that need it.
fi

ls >/dev/null 2>/dev/null 
