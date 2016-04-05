<?php
// Sabai Technology - Apache v2 licence
// Copyright 2015 Sabai Technology
$UCI_PATH="-c /configs";
$filter = array("<", ">","="," (",")",";","/","|");

if (isset($_POST['check'])) {
	$act=$_POST['check'];
	$res=exec("sh /www/bin/pptp.sh $act");
	if( strpos($res,'connected.') == true ) {
  		exec("sh /www/bin/pptp.sh dns");
  	}
	echo $res;
} else if (isset($_POST['switch']))	{
	$act=$_POST['switch'];
	$res=exec("sh /www/bin/pptp.sh $act");
	echo $res;
} else {
	$_REQUEST['act']=str_replace ($filter, "#", $_REQUEST['act']);
	$act=$_REQUEST['act'];


$user=trim($_REQUEST['user']);
$pass=trim($_REQUEST['pass']);
$server=trim($_REQUEST['server']);
$serverip=trim(gethostbyname($server));

if ($user && $pass && $server) {
	// Set the Sabai config to reflect latest settings
	exec("uci $UCI_PATH set sabai.vpn.username=\"" . $user . "\"");
	exec("uci $UCI_PATH set sabai.vpn.password=\"" . $pass . "\"");
	exec("uci $UCI_PATH set sabai.vpn.server=\"" . $server . "\"");
	exec("uci $UCI_PATH commit sabai");

	//execute the action and give response to calling page
	switch ($act) {
		case "start":
			$res=exec("sh /www/bin/pptp.sh $act");
			echo $res;
			break;
		case "stop":
			$res=exec("sh /www/bin/pptp.sh $act");
			echo $res;
			break;
		case "save":
			echo "res={ sabai: true, msg: 'PPTP settings saved.' }";
		    break;
		case "clear":
			exec("sh /www/bin/pptp.sh $act");
			echo "res={ sabai: true, msg: 'PPTP settings cleared.' }";
		    break;
	}
} else {
	echo "res={ sabai: true, msg: 'Incorrect PPTP settings. Please check.' }";
}
}
?>
