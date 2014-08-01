<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology

$act=$_REQUEST['act'];
$user=trim($_REQUEST['user']);
$pass=trim($_REQUEST['pass']);
$server=trim($_REQUEST['server']);
$serverip=trim(gethostbyname($server));

switch ($act) {
	case "start":
        exec("sh /www/bin/pptp.sh $act $user $pass $server $user $pass $serverip");
		echo "res={ sabai: true, msg: 'PPTP starting.' }";
			break;
	case "stop":
        exec("sh /www/bin/pptp.sh $act");
		echo "res={ sabai: true, msg: 'PPTP stopped.' }";
		    break;
	case "save":
        exec("sh /www/bin/pptp.sh $act $user $pass $server");
		echo "res={ sabai: true, msg: 'PPTP settings saved.' }";
		    break;	
	case "clear":
        exec("sh /www/bin/pptp.sh $act $user $pass $server");
		echo "res={ sabai: true, msg: 'PPTP settings cleared.' }";
		    break;

}

?>