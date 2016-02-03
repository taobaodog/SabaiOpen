<?php
// Sabai Technology - Apache v2 licence
// Copyright 2015 Sabai Technology
$UCI_PATH="-c /etc/config";
$prefix="tor";

if (isset($_POST['switch']))	{
	$mode=$_POST['switch'];
	$res=exec("sh /www/bin/tor.sh $mode");
	echo $res;
} else {
	$mode=trim($_POST[$prefix.'_mode']);
	$ssid=trim($_POST[$prefix.'_ssid']);
	$ip=trim($_POST[$prefix.'_nw_ip']);
	$mask=trim($_POST[$prefix.'_nw_mask']);
	$server=trim($_POST[$prefix.'_server']);
	$command="sh /www/bin/tor.sh $mode";

	exec("uci $UCI_PATH set sabai.wlradio0.ssid=\"" . $ssid . "\"");
	exec("uci $UCI_PATH set sabai.tor.ipaddr=\"" . $ip . "\"");
	exec("uci $UCI_PATH set sabai.tor.netmask=\"" . $mask . "\"");
	exec("uci $UCI_PATH set sabai.tor.network=\"" . $server . "\"");
	exec("uci -c /etc/config commit sabai");
	$res=exec($command);
	echo $res;
}
?>
