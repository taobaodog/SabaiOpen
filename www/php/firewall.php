<?php 
   
$icmp=$_REQUEST['respondToggle']; 
$multicast=$_REQUEST['multicastToggle']; 
$cookies=$_REQUEST['synToggle']; 
$wanroute=$_REQUEST['wanToggle']; 


// Set the Sabai config to reflect latest settings
exec("uci set sabai.firewall.icmp=\"" . $icmp . "\"");
exec("uci set sabai.firewall.multicast=\"" . $multicast . "\"");
exec("uci set sabai.firewall.cookies=\"" . $cookies . "\"");
exec("uci set sabai.firewall.wanroute=\"" . $wanroute . "\"");
exec("uci commit sabai");

if ($icmp == '') $icmp="off" ;
if ($multicast == '') $multicast="off" ;
if ($cookies == '') $cookies="off" ;
if ($wanroute == '') $wanroute="off" ;

exec("sh /www/bin/firewall.sh $icmp $multicast $cookies $wanroute");
echo "res={ sabai: true, msg: 'Firewall settings applied' }";

?>  
