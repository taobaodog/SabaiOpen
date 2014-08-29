<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology

// Bring over variables from the Wireless page
$mode=trim($_POST['wl_mode']);
$ssid=trim($_POST['wl_ssid']);
$encryption=trim($_POST['wl_encryption']);
$wpa_type=trim($_POST['wl_wpa_type']);
$wpa_encryption=trim($_POST['wl_wpa_encryption']);
$wpa_psk=trim($_POST['wl_wpa_psk']);
$wpa_rekey=trim($_POST['wl_wpa_rekey']);
$wepkeys=implode(" ", $_POST["wl_wep_keys"]);
$command="sh /www/bin/wl.sh " . $encryption;
// Set the Sabai config to reflect latest settings
exec("uci set sabai.wlradio0.mode=\"" . $mode . "\"");
exec("uci set sabai.wlradio0.ssid=\"" . $ssid . "\"");
exec("uci set sabai.wlradio0.encryption=\"" . $encryption . "\"");
exec("uci set sabai.wlradio0.wpa_type=\"" . $wpa_type . "\"");
exec("uci set sabai.wlradio0.wpa_encryption=\"" . $wpa_encryption . "\"");
exec("uci set sabai.wlradio0.wpa_psk=\"" . $wpa_psk . "\"");
exec("uci set sabai.wlradio0.wpa_rekey=\"" . $wpa_rekey . "\"");
exec("uci set sabai.wlradio0.wepkeys=\"" . $wepkeys . "\"");
exec("uci commit sabai");
exec($command);

// Send completion message back to UI
echo "res={ sabai: true, msg: 'Wireless settings applied' }";

?>