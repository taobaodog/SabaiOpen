<?php 
   
$icmp=$_REQUEST['respondToggle'];
$multicast=$_REQUEST['multicastToggle'];
$cookies=$_REQUEST['synToggle'];
$wanroute=$_REQUEST['wanToggle'];

// Set the Sabai config to reflect latest settings
exec("uci set sabai.firewall.icmp=\"" . $icmp . "\"");
exec("uci set sabai.firewall.multicast=\"" . $mask . "\"");
exec("uci set sabai.firewall.cookies=\"" . $cookies . "\"");
exec("uci set sabai.firewall.wanroute=\"" . $wanroute . "\"");
exec("uci commit sabai");

exec("sh /www/bin/firewall.sh $icmp $multicast $cookies $wanroute");
echo "res={ sabai: true, msg: 'Firewall settings applied' }";

?>  
