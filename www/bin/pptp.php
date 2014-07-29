<?php
header('Content-Type: application/javascript');

$act=$_REQUEST['act'];
$user=trim($_REQUEST['user']);
$pass=trim($_REQUEST['pass']);
$server=trim($_REQUEST['server']);
$serverip=trim(gethostbyname($server));
$blank="";


switch ($act) {
    case "clear":
    	$status="none";
        exec("uci set sabai.vpn.username=$blank");
		exec("uci set sabai.vpn.password=$blank");
		exec("uci set sabai.vpn.password=$blank");
		exec("uci set network.vpn.username=$blank");
		exec("uci set network.vpn.password=$blank");
		exec("uci set network.vpn.server=$blank");
		exec("uci set sabai.vpn.status=$status");
		exec("uci commit");
		exec("/etc/init.d/network restart");
        echo "res={ sabai: true, msg: 'Settings cleared.' }";
        	break;
	case "start":
	    $status="PPTP_Started";
	    exec("uci set network.vpn=interface");
        exec("uci set network.vpn.ifname=pptp-vpn");
        exec("uci set network.vpn.proto=pptp");
		exec("uci set network.vpn.username=$user");
		exec("uci set network.vpn.password=$pass");
		exec("uci set network.vpn.server=$server");
		exec("uci set network.vpn.buffering=1");
		exec("uci set sabai.vpn.username=$user");
		exec("uci set sabai.vpn.password=$pass");
		exec("uci set sabai.vpn.server=$server");
		exec("uci set sabai.vpn.status=$status");
		exec("uci commit");
		exec("/etc/init.d/network restart");
		echo "res={ sabai: true, msg: 'PPTP starting.' }";
			break;
	case "stop":
	    $status="none";
		exec("uci delete network.vpn");
		exec("uci set sabai.vpn.status=$status");
		exec("uci commit");
		exec("/etc/init.d/network restart");
		echo "res={ sabai: true, msg: 'PPTP stopped.' }";
		    break;
	case "save":
		exec("uci set sabai.vpn.username=$user");
		exec("uci set sabai.vpn.password=$pass");
		exec("uci set sabai.vpn.server=$server");
		exec("uci commit");
		echo "res={ sabai: true, msg: 'Settings saved.' }";
		   	break;
}

?>