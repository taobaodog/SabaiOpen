<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology

// Bring over variables from the LAN page
$act=trim($_POST['act']);
$ip=trim($_POST['lan_ip']);
$mask=trim($_POST['lan_mask']);
$lease=trim($_POST['dhcp_lease']);
$start=trim($_POST['dhcp_start']);
$limit=trim($_POST['dhcp_limit']);
$command="sh /www/bin/lan.sh " . $act;

// Set the Sabai config to reflect latest settings
exec("uci set sabai.lan.ipaddr=\"" . $ip . "\"");
exec("uci set sabai.lan.netmask=\"" . $mask . "\"");
exec("uci set sabai.dhcp.leasetime=\"" . $lease . "\"");
exec("uci set sabai.dhcp.start=\"" . $start . "\"");
exec("uci set sabai.dhcp.limit=\"" . $limit . "\"");
exec("uci commit sabai");
exec($command);

// Send completion message back to UI
echo "res={ sabai: true, msg: 'LAN settings applied' }";

?>