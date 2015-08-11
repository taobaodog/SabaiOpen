#!/bin/ash
#TODO: add check of new dhcphost settings
 
test=$1

#path to config files
UCI_PATH="-c /configs"

_get(){
	echo "---------------START OF GET-TEST---------------"
	echo "-> -> -> Expecting "GET" procedure and creating /www/libs/data/dhcp.json "
	echo "***Test case 1***"
	rm /www/libs/data/dhcp.json
	#Input testdata
	echo -e "1439298369 d8:d3:85:e9:b2:d4 192.168.199.250 taobaodog *\n1439298370 d1:d3:85:e9:b2:d4 192.168.199.240 taobaodog1 *" > /tmp/dhcp.leases
	echo -e "1439298368 d8:d1:85:e9:b2:d4 192.168.199.230 taobaodog2 *\n1439298350 d8:d3:81:e9:b2:d4 192.168.199.220 taobaodog3 *" >> /tmp/dhcp.leases
	echo -n '{"1": {"static": "WAN PORT", "route": "--------", "ip": "kernel", "mac": "00:30:18:AF:3E:A2", "name": "WAN PORT", "time": "----"},'> /tmp/test_tablejs
	echo -n '"2":{"static": "off", "route": "default", "ip": "192.168.199.250", "mac": "d8:d3:85:e9:b2:d4", "name": "taobaodog", "time": "Tue Aug 11 09:06:09 EDT 2015"},' >> /tmp/test_tablejs
	echo -n '"3":{"static": "on", "route": "local", "ip": "192.168.199.240", "mac": "d1:d3:85:e9:b2:d4", "name": "taobaodog1", "time": "Tue Aug 11 09:06:10 EDT 2015"},' >> /tmp/test_tablejs
	echo -n '"4":{"static": "off", "route": "default", "ip": "192.168.199.230", "mac": "d8:d1:85:e9:b2:d4", "name": "taobaodog2", "time": "Tue Aug 11 09:06:08 EDT 2015"},' >> /tmp/test_tablejs
	echo -n '"5":{"static": "on", "route": "default", "ip": "192.168.199.220", "mac": "d8:d3:81:e9:b2:d4", "name": "taobaodog3", "time": "Tue Aug 11 09:05:50 EDT 2015"}}' >> /tmp/test_tablejs	

	#Creating dhcp static test hosts
	host_1=$(uci show dhcp | grep "taobaodog1" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	[ -n "$host_1" ] && uci delete dhcp.@host[$host_1] && uci delete dhcp.@host[$host_1] && uci commit dhcp 
	
	sabai_host_1=$(uci show sabai | grep "taobaodog1" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	echo "1"
	[ -n "$sabai_host_1" ] && uci $UCI_PATH delete sabai.@dhcphost[$sabai_host_1] && uci delete sabai.@dhcphost[$sabai_host_1] && uci $UCI_PATH commit sabai

	uci add dhcp host
	uci set dhcp.@host[-1].ip=192.168.199.240
	uci set dhcp.@host[-1].mac=d1:d3:85:e9:b2:d4
	uci set dhcp.@host[-1].name="taobaodog1"
	uci add dhcp host
        uci set dhcp.@host[-1].ip=192.168.199.220
        uci set dhcp.@host[-1].mac=d8:d3:81:e9:b2:d4
        uci set dhcp.@host[-1].name="taobaodog3"   
        uci commit dhcp
        uci $UCI_PATH add sabai dhcphost                                                                                                       
        uci $UCI_PATH set sabai.@dhcphost[-1].ip=192.168.199.240                                                                                            
        uci $UCI_PATH set sabai.@dhcphost[-1].mac=d1:d3:85:e9:b2:d4                                                                                           
        uci $UCI_PATH set sabai.@dhcphost[-1].name="taobaodog1"                                                                                        
        uci $UCI_PATH set sabai.@dhcphost[-1].route="local"
	uci $UCI_PATH add sabai dhcphost
        uci $UCI_PATH set sabai.@dhcphost[-1].ip=192.168.199.220                                               
        uci $UCI_PATH set sabai.@dhcphost[-1].mac=d1:d3:81:e9:b2:d4
        uci $UCI_PATH set sabai.@dhcphost[-1].name="taobaodog3"
        uci $UCI_PATH set sabai.@dhcphost[-1].route="default"	                                                                                         
        uci $UCI_PATH commit sabai
	
	/www/bin/dhcp.sh get
	res=$(uci $UCI_PATH get sabai.dhcp.tablejs)
	check_json="$(cat /tmp/test_tablejs)"
		if [ "$check_json" == "$res" ]; then
			echo "-> -> -> 1.1: Pass <- <- <-"
		else
			echo -e "INPUT:\n$check_json"
			echo -e "OUTPUT:\n$res"
			echo "-> -> -> 1.1: Fail <- <- <-"
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

