#!/bin/ash
#Dhcp.sh has problem with jawk
#static_on function doesn't get args
#TODO: add check of new dhcphost settings
 
test=$1

#path to config files
UCI_PATH="-c /configs"

_get(){
	echo "---------------START OF GET-TEST---------------"
	echo "-> -> -> Expecting "GET" procedure and creating /www/libs/data/dhcp.json "
	echo "***Test case 1***"
	rm /www/libs/data/dhcp.json
	/www/bin/dhcp.sh get
	#get wan address and mac                                                                                                                       
	wanip=$(ip route | grep -e "/24 dev eth0" | awk -F: '{print $0}' | awk '{print $5}')                                                           
	wanmac=$(ifconfig eth0 | grep 'eth0' | awk -F: '{print $0}' | awk '{print $5}')     
	wanport=$(uci get network.wan.ifname)                                                                                                          
	wantime="----" 
	table='{"aaData": [{"static": "WAN PORT", "route": "--------", "ip": "'$wanip'", "mac": "'$wanmac'", "name": "WAN PORT", "time": "'$wantime'"}' 
	check=$(cat /tmp/dhcp.leases)
	if [ "$check" != "" ]; then
		check_json=$(uci $UCI_PATH get sabai.dhcp.table)
		res=$table$check"]}"
		if [ "$check_json" == "$res" ]; then
			echo "-> -> -> 1.1: Pass <- <- <-"
		else
			echo $check_json
			echo $table$check']}'
			echo "-> -> -> 1.1: Fail <- <- <-"
		fi
	else
		echo "-> -> -> 0.1: Fail <- <- <-"
	fi		
	echo "---------------END OF GET-TEST-----------------"
}

_save(){
	echo "---------------START OF SAVE-TEST---------------"
	echo "-> -> -> Expecting "SAVE" procedure"
	echo "***Test case 1***"
	rm /tmp/table2
	rm /tmp/table3
	rm /tmp/table4
	rm /tmp/tmpdhcptable
	/www/bin/dhcp.sh save
	if [ -e "/tmp/table2" ]; then
		if [ -e "/tmp/table3" ]; then
			if [ -e "/tmp/table4" ]; then
				if [ -e "/tmp/tmpdhcptable" ]; then
					check=`cat /tmp/tmpdhcptable`
					check_1=`cat /tmp/table4`
					if [ "$check" == "$check_1" ]; then
						echo "-> -> -> 2.1: Pass <- <- <-"
					else
						echo $check
						echo check_1
						echo "-> -> -> 2.1: Fail <- <- <-"		
					fi
				fi
			fi
		fi
	fi
	if [ -e "/tmp/feedback" ]; then
		echo  "-> -> -> 3.1: Pass <- <- <-"
	else
		echo "-> -> -> 3.1: Fail <- <- <-"
	fi


	echo "---------------END OF SAVE-TEST-----------------"
}

case $test in
	get)	_get;;
	save)	_save;;
        all)    _get; _save ;;
esac

