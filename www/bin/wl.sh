#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

if [ $# -ne 1 ]; then
        action=save
else
        action=$1
fi

if [ $action = "update" ]; then
        config_file=sabai-new
else
        config_file=sabai
fi

encryption=$(uci get $config_file.wlradio0.encryption)

uci set wireless.radio0.country='US'
uci set wireless.radio0.channel='auto'
wifi down

if [ $(uci get $config_file.wlradio0.mode) = "off" ]; then
		uci set wireless.radio0.disabled=1
		uci delete wireless.@wifi-iface[0].mode
	else
		uci set wireless.radio0.disabled=0
		uci set wireless.@wifi-iface[0].mode="$(uci get $config_file.wlradio0.mode)";
	fi

uci set wireless.@wifi-iface[0].ssid="$(uci get $config_file.wlradio0.ssid)";
uci set wireless.@wifi-iface[0].encryption="$(uci get $config_file.wlradio0.encryption)";

_wep(){
	wepkeys="$(uci get $config_file.wlradio0.wepkeys)";
	uci set wireless.@wifi-iface[0].key1=$(echo $wepkeys |awk -F: '{print $0}' | awk '{print $1}')
	uci set wireless.@wifi-iface[0].key2=$(echo $wepkeys |awk -F: '{print $0}' | awk '{print $2}')
	uci set wireless.@wifi-iface[0].key3=$(echo $wepkeys |awk -F: '{print $0}' | awk '{print $3}')
	uci set wireless.@wifi-iface[0].key4=$(echo $wepkeys |awk -F: '{print $0}' | awk '{print $4}')
	uci set wireless.@wifi-iface[0].key=4
	uci commit wireless;
}

_psk(){
	wpa_encryption=$(uci get $config_file.wlradio0.wpa_encryption)
	full_encryption=$(echo "$encryption+$wpa_encryption") 
	uci set wireless.@wifi-iface[0].encryption=$full_encryption
	uci set wireless.@wifi-iface[0].key=$(uci get $config_file.wlradio0.wpa_psk)
	uci set wireless.@wifi-iface[0].key1=''
	uci set wireless.@wifi-iface[0].key2=''
	uci set wireless.@wifi-iface[0].key3=''
	uci set wireless.@wifi-iface[0].key4=''
	uci commit wireless
}

ls >/dev/null 2>/dev/null 

case $encryption in
	none)	break;	;;
	wep)	_wep	;;
	psk)	_psk	;;
	psk2)	_psk	;;
	mixed-psk)	_psk	;;
esac

if [ $action = "update" ]; then
	echo "network" >> /tmp/.restart_services
else
	wifi up
fi
logger "wireless script run and wifi restarted"
