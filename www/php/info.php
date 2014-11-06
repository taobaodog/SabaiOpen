<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC

 exec("/sbin/ifconfig eth0 | egrep -o \"HWaddr [A-Fa-f0-9:]*|inet addr:[0-9:.]*|UP BROADCAST RUNNING MULTICAST\"",$out);
$wan = " wan: {
  mac: '". strtoupper(str_replace("HWaddr ","", ( array_key_exists(0,$out)? "$out[0]" : "-" ) )) ."',
  ip: '". str_replace("inet addr:","", ( array_key_exists(1,$out)? "$out[1]" : "-" ) ) ."',
  status: '". ( array_key_exists(2,$out)? "Connected" : "-" ) ."' 
},\n";

unset($out);

$proxy_status = exec("uci get sabai.privoxy.status");

  
$proxy = " proxy: {
  \"status\": \"". exec("uci get sabai.proxy.status") ."\"
}";
$pptp_ifup=exec("ifconfig pptp-vpn | grep -e 'pptp-vpn' | awk -F: '{print $0}' | awk '{print $1}'");
$ovpn_ifup=exec("ifconfig tun0 | grep -e 'tun0' | awk -F: '{print $0}' | awk '{print $1}'");

$vo=exec("uci get sabai.vpn.proto");
switch($vo){
 case 'none': $vpn_type='-'; break;
 case 'pptp': $vpn_type='PPTP'; break;
 case 'l2tp': $vpn_type='L2TP'; break;
 case 'ovpn': $vpn_type='OpenVPN'; break;
}

$vpn = ",\n vpn: {\n type: '". $vpn_type ."',
  status: '". (($vpn_type=='-')?'-':'Connected') ."'\n },";

echo "info = {\n"
.$wan
.$proxy
.$vpn
."\n}";

?>