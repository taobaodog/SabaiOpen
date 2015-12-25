<?php
// Sabai Technology - Apache v2 licence
// Copyright 2015 Sabai Technology, LLC
$UCI_PATH="-c /configs";

exec("/sbin/ifconfig eth0 | egrep -o \"HWaddr [A-Fa-f0-9:]*|inet addr:[0-9:.]*|UP BROADCAST RUNNING MULTICAST\"",$out);
$wan = " wan: {
  mac: '". strtoupper(str_replace("HWaddr ","", ( array_key_exists(0,$out)? "$out[0]" : "-" ) )) ."',
  ip: '". str_replace("inet addr:","", ( array_key_exists(1,$out)? "$out[1]" : "-" ) ) ."',
  status: '". ( array_key_exists(2,$out)? "Connected" : "-" ) ."' 
},\n";

unset($out);

$proxy = " proxy: {
  \"status\": \"". exec("uci get sabai.proxy.status") ."\"
}";

$vo=exec("uci get sabai.vpn.proto");
switch($vo){
 case 'none': $vpn_type='-'; break;
 case 'pptp': 
 	$vpn_type='PPTP'; 
 	$vpn_ip=exec("ifconfig pptp-vpn | grep inet | awk '{print $2}' | sed 's/addr://g' ");
 	if($vpn_ip != '') {
 		exec("uci $UCI_PATH set sabai.vpn.ip=$vpn_ip");
 		exec("uci $UCI_PATH set sabai.vpn.status=Connected");
 		exec("uci $UCI_PATH commit sabai");
 	}
 	break;
 case 'l2tp': $vpn_type='L2TP'; break;
 case 'ovpn': 
 	$vpn_type='OpenVPN'; 
 	$vpn_ip=exec("ifconfig tun0 | grep inet | awk '{print $2}' | sed 's/addr://g' ");
 	if($vpn_ip != '') {
 		exec("uci $UCI_PATH set sabai.vpn.ip=$vpn_ip");
 		exec("uci $UCI_PATH set sabai.vpn.status=Connected");
 		exec("uci $UCI_PATH commit sabai");
 	}
 	break;
}
$vpn_status=exec("uci get sabai.vpn.status");

$vpn = ",\n vpn: {\n type: '". $vpn_type ."',
  status: '". (($vpn_type=='-')?'-': $vpn_status) ."',
  ip: '". $vpn_ip ."' \n },";

echo "info = {\n"
.$wan
.$proxy
.$vpn
."\n}";

?>