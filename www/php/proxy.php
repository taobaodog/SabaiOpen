<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC

header('Content-Type: application/javascript');

$act=$_REQUEST['act'];

switch ($act) {
	case "start":
        exec("sh proxy.sh $act");
		echo "res={ sabai: true, msg: 'Proxy starting.' }";
			break;
	case "stop":
        exec("sh proxy.sh $act");
		echo "res={ sabai: true, msg: 'Proxy stopped.' }";
		    break;
}

?>
