<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology
$UCI_PATH="-c /configs";
$filter = array("<", ">","="," (",")",";","/","|");
$_REQUEST['act']=str_replace ($filter, "#", $_REQUEST['act']);
$act=$_REQUEST['act'];
$user=trim($_REQUEST['user']);
$pass=trim($_REQUEST['pass']);
$server=trim($_REQUEST['server']);
$serverip=trim(gethostbyname($server));

// Set the Sabai config to reflect latest settings
exec("uci $UCI_PATH set sabai.vpn.username=\"" . $user . "\"");
exec("uci $UCI_PATH set sabai.vpn.password=\"" . $pass . "\"");
exec("uci $UCI_PATH set sabai.vpn.server=\"" . $server . "\"");
exec("uci $UCI_PATH set sabai.vpn.proto=\"" . pptp . "\"");
exec("uci $UCI_PATH commit sabai");

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
