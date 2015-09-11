<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology
$UCI_PATH="-c /configs";

function setVar(){
// Bring over variables from the Wireless page
$mode=trim($_POST['wl_mode']);
$ssid=trim($_POST['wl_ssid']);
$encryption=trim($_POST['wl_encryption']);
$wpa_type=trim($_POST['wl_wpa_type']);
$wpa_encryption=trim($_POST['wl_wpa_encryption']);
$wpa_psk=trim($_POST['wl_wpa_psk']);
$wpa_rekey=trim($_POST['wl_wpa_rekey']);
$wepkeys=implode(" ", $_POST["wl_wep_keys"]);
$command="sh /www/bin/wl.sh ";
// Set the Sabai config to reflect latest settings
exec("uci $UCI_PATH set sabai.wlradio0.mode=\"" . $mode . "\"");
exec("uci $UCI_PATH set sabai.wlradio0.ssid=\"" . $ssid . "\"");
exec("uci $UCI_PATH set sabai.wlradio0.encryption=\"" . $encryption . "\"");
exec("uci $UCI_PATH set sabai.wlradio0.wpa_type=\"" . $wpa_type . "\"");
exec("uci $UCI_PATH set sabai.wlradio0.wpa_encryption=\"" . $wpa_encryption . "\"");
exec("uci $UCI_PATH set sabai.wlradio0.wpa_psk=\"" . $wpa_psk . "\"");
exec("uci $UCI_PATH set sabai.wlradio0.wpa_rekey=\"" . $wpa_rekey . "\"");
exec("uci $UCI_PATH set sabai.wlradio0.wepkeys=\"" . $wepkeys . "\"");
exec("uci $UCI_PATH commit sabai");
exec($command);

// Send completion message back to UI
echo "res={ sabai: true, msg: 'Wireless settings applied' }";
}

//Check what wl device must be configured
if (isset($_POST['form_wl0'])) {
	setVar("wl","wlradio0");
} else {
	echo "res={ sabai: true, msg: 'Wooohooo!' }";
}

?>
