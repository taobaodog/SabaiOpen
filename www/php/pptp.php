<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology

$act=$_REQUEST['act'];
$user=trim($_REQUEST['user']);
$pass=trim($_REQUEST['pass']);
$server=trim($_REQUEST['server']);
$serverip=trim(gethostbyname($server));

// Set the Sabai config to reflect latest settings
exec("uci set sabai.vpn.username=\"" . $user . "\"");
exec("uci set sabai.vpn.password=\"" . $pass . "\"");
exec("uci set sabai.vpn.server=\"" . $server . "\"");
exec("uci commit sabai");

//execute the action and give response to calling page
switch ($act) {
	case "start":
		exec("sh /www/bin/pptp.sh $act");
		echo "res={ sabai: true, msg: 'PPTP starting.' }";
			break;
	case "stop":
		exec("sh /www/bin/pptp.sh $act");
		echo "res={ sabai: true, msg: 'PPTP stopped.' }";
		    break;
	case "save":
		echo "res={ sabai: true, msg: 'PPTP settings saved.' }";
		    break;	
	case "clear":
		exec("sh /www/bin/pptp.sh $act");
		echo "res={ sabai: true, msg: 'PPTP settings cleared.' }";
		    break;

}

?>