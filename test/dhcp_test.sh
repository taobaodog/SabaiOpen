#!/bin/ash
# Sabai Technology - Apache v2 licence
# Copyright 2015 Sabai Technology
#TODO: add check of new dhcphost settings
 
test=$1

#path to config files
UCI_PATH="-c /configs"

wanmac="$(ifconfig eth0 | grep 'eth0' | awk -F: '{print $0}' | awk '{print $5}')"
echo -e ">>>>>>>>>>>>>>>>>>>>>>>>>DHCP & GW TEST<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n"

_get(){
	echo "---------------START OF GET-TEST---------------"
	echo "-> -> -> Expecting "GET" procedure and creating /www/libs/data/dhcp.json "
	echo "***Test case 1***"
	rm /www/libs/data/dhcp.json
	#Input testdata
	echo -e "1439298369 d8:d3:85:e9:b2:d4 192.168.199.250 taobaodog *\n1439298370 d1:d3:85:e9:b2:d4 192.168.199.240 taobaodog1 *" > /tmp/dhcp.leases
	echo -e "1439298368 d8:d1:85:e9:b2:d4 192.168.199.230 taobaodog2 *\n1439298350 d8:d3:81:e9:b2:d4 192.168.199.220 taobaodog3 *" >> /tmp/dhcp.leases
	echo -n '{"1": {"static": "WAN PORT", "route": "--------", "ip": "kernel", "mac": "'$wanmac'", "name": "WAN PORT", "time": "----"},'> /tmp/test_tablejs
	echo -n '"2":{"static": "off", "route": "default", "ip": "192.168.199.250", "mac": "d8:d3:85:e9:b2:d4", "name": "taobaodog", "time": "Tue Aug 11 09:06:09 EDT 2015"},' >> /tmp/test_tablejs
	echo -n '"3":{"static": "on", "route": "local", "ip": "192.168.199.240", "mac": "d1:d3:85:e9:b2:d4", "name": "taobaodog1", "time": "Tue Aug 11 09:06:10 EDT 2015"},' >> /tmp/test_tablejs
	echo -n '"4":{"static": "off", "route": "default", "ip": "192.168.199.230", "mac": "d8:d1:85:e9:b2:d4", "name": "taobaodog2", "time": "Tue Aug 11 09:06:08 EDT 2015"},' >> /tmp/test_tablejs
	echo -n '"5":{"static": "on", "route": "default", "ip": "192.168.199.220", "mac": "d8:d3:81:e9:b2:d4", "name": "taobaodog3", "time": "Tue Aug 11 09:05:50 EDT 2015"}}' >> /tmp/test_tablejs	

	#Creating dhcp static test hosts
	host_1=$(uci show dhcp | grep "taobaodog1" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
	[ -n "$host_1" ] && uci delete dhcp.@host[$host_1] && uci delete dhcp.@host[$host_1] && uci commit dhcp 
	
	sabai_host_1=$(uci show sabai | grep "taobaodog1" | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)
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
			exit 1
		fi		
	rm /tmp/test_tablejs
	echo "---------------END OF GET-TEST-----------------"
}

_save(){
	echo "---------------START OF SAVE-TEST---------------"
	echo "-> -> -> Expecting "SAVE" procedure"
	#Input test data
	echo -n '{"1":{"static": "off", "route": "default", "ip": "192.168.199.250", "mac": "d8:d3:85:e9:b2:d4", "name": "taobaodog", "time": "Wed Aug 12 04:57:11 EDT 2015"},' > /tmp/table1
	echo -n '"2":{"static": "WAN PORT", "route": "--------", "ip": "kernel", "mac": "'$wanmac'", "name": "WAN PORT", "time": "----"},' >> /tmp/table1
	echo -n '"3":{"static": "on", "route": "local", "ip": "192.168.199.240", "mac": "d1:d3:85:e9:b2:d4", "name": "taobaodog1", "time": "Sat Apr  1 12:10:00 EDT 2017"},' >> /tmp/table1
	echo -n '"4":{"static": "off", "route": "accelerator", "ip": "192.168.199.230", "mac": "d8:d1:85:e9:b2:d4", "name": "taobaodog2", "time": "Sat Apr  1 12:08:00 EDT 2017"},' >> /tmp/table1
	echo -n '"5":{"static": "on", "route": "vpn_only", "ip": "192.168.199.220", "mac": "d8:d3:81:e9:b2:d4", "name": "taobaodog3", "time": "Sat Apr  1 11:50:00 EDT 2017"},' >> /tmp/table1
	echo -n '"6":{"static": "on", "route": "vpn_fallback", "ip": "192.168.199.210", "mac": "d8:d3:85:e1:b2:d4", "name": "taobaodog4", "time":  "Sat Apr  1 11:50:00 EDT 2017"}}' >> /tmp/table1
	cp /tmp/table1 /tmp/test_tablejs	

	#Start testing
	/www/bin/dhcp.sh json
	/www/bin/dhcp.sh save
	#Clean up check
	if [ ! -e "/tmp/table2" ] && [ ! -e "/tmp/table3" ] && [ ! -e "/tmp/table4" ] && [ ! -e "/tmp/tmpdhcptable" ]; then
		echo "-> -> -> 2.1: Pass <- <- <-"
		#Copy check
		check_json=$(uci $UCI_PATH get sabai.dhcp.tablejs)
		check=$(cat /tmp/test_tablejs)
		if [ "$check" = "$check_json" ]; then
			echo "-> -> -> 2.2: Pass <- <- <-"
		else
			echo -e "INPUT:\n$check"
			echo -e "OUTPUT:\n$check_json"
			echo "-> -> -> 2.2: Fail <- <- <-"
			exit 1	
		fi
	else
		echo "Clean up test failed."
		ls /tmp/
		echo "-> -> -> 2.1: Fail <- <- <-"
		exit 1
	fi
	#gw.sh testig	
	#Input test data tun0 is up
	#Accelerator test
	[ "$(uci $UCI_PATH get sabai.general.ac_ip)" -ne 2 ] && (echo "-> -> -> Accelerator IP was set incorrect <- <- <-"; exit 1)

	#IP rules check 
	[ -z "$(ip rule show | grep '192.168.199.210 lookup vpn')" ] && (echo "-> -> -> VPN rule was not added <- <- <-"; exit 1) 
	[ -z "$(ip rule show | grep '192.168.199.220 lookup vpn')" ] && (echo "-> -> -> VPN rule was not added <- <- <-"; exit 1)
	[ -z "$(ip rule show | grep '192.168.199.230 lookup acc')" ] && (echo "-> -> -> ACC rule was not added <- <- <-"; exit 1)
	[ -z "$(ip rule show | grep '192.168.199.240 lookup wan')" ] && (echo "-> -> -> WAN rule was not added <- <- <-"; exit 1)
	
	#Static attribute check
	[ -z "$(uci show dhcp | grep 192.168.199.240)" ] && [ -z "$(uci show dhcp | grep 192.168.199.240)" ] && (echo "-> -> -> Host wan not aded to static <- <- <-"; exit 1)
	[ -z "$(uci show dhcp | grep 192.168.199.220)" ] && [ -z "$(uci show dhcp | grep 192.168.199.220)" ] && (echo "-> -> -> Host wan not aded to static <- <- <-"; exit 1)
	[ -z "$(uci show dhcp | grep 192.168.199.210)" ] && [ -z "$(uci show dhcp | grep 192.168.199.210)" ] && (echo "-> -> -> Host wan not aded to static <- <- <-"; exit 1)
	
	rm /tmp/test_tablejs
	echo "---------------END OF SAVE-TEST-----------------"
}

case $test in
	get)	_get;;
	save)	_save;;
        all)    _get; _save ;;
esac

