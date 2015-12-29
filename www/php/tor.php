<?php
// Sabai Technology - Apache v2 licence
// Copyright 2015 Sabai Technology
$UCI_PATH="-c /configs";
$prefix="tor";

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
exec("uci $UCI_PATH set sabai.tor.mode=\"" . $mode . "\"");
exec("uci -c /configs commit sabai");
exec($command);

echo "res={ sabai: true, msg: 'TOR tunnel started' }";
?>
