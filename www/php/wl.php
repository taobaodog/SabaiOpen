<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology
$UCI_PATH="-c /configs";

function setVar($prefix, $option){
	// Bring over variables from the Wireless page
	$mode=trim($_POST[$prefix.'_mode']);
	$ssid=trim($_POST[$prefix.'_ssid']);
	$encryption=trim($_POST[$prefix.'_encryption']);
	$wpa_encryption=trim($_POST[$prefix.'_wpa_encryption']);
	$wpa_psk=trim($_POST[$prefix.'_wpa_psk']);
	if ($prefix == 'wl') {
		$wpa_rekey=trim($_POST[$prefix.'_wpa_rekey']);
		$wepkeys=implode(" ", $_POST[$prefix.'_wep_keys']);
	};
	$auto=trim($_POST['channel_mode']);
	$channel=trim($_POST[$prefix.'_channel']);
	$command="sh /www/bin/wl.sh ";

	// Set the Sabai config to reflect latest settings
	exec("uci $UCI_PATH set sabai.$option.mode=\"" . $mode . "\"");
	exec("uci $UCI_PATH set sabai.$option.ssid=\"" . $ssid . "\"");
	exec("uci $UCI_PATH set sabai.$option.encryption=\"" . $encryption . "\"");
	exec("uci $UCI_PATH set sabai.$option.wpa_encryption=\"" . $wpa_encryption . "\"");
	exec("uci $UCI_PATH set sabai.$option.wpa_psk=\"" . $wpa_psk . "\"");
	if ($option == 'wlradio0') {
		exec("uci $UCI_PATH set sabai.$option.auto=\"" . $auto . "\"");
		exec("uci $UCI_PATH set sabai.$option.channel_freq=\"" . $channel . "\"");
		exec("uci $UCI_PATH set sabai.$option.wpa_rekey=\"" . $wpa_rekey . "\"");
		exec("uci $UCI_PATH set sabai.$option.wepkeys=\"" . $wepkeys . "\"");
	};
	exec("uci -c /configs commit sabai");
	//exec($command);

// Send completion message back to UI
	echo "res={ sabai: true, msg: 'Wireless settings applied' }";
}

//Check what wl device must be configured
if (isset($_POST['form_wl0'])) {
	setVar("wl","wlradio0");
} else {
	setVar("wl1","wlradio1");
}

?>
