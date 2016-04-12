<?php
// Sabai Technology - Apache v2 licence
// Copyright 2016 Sabai Technology
$UCI_PATH="-c /configs";
$command="sh /www/bin/time.sh";

if (isset($_POST['sync'])) {
	$location=$_POST['sync'];
	exec("uci $UCI_PATH set sabai.time.location=\"" . $location . "\"");
	exec("uci $UCI_PATH commit sabai");
	exec($command);
} else {
	// Bring over variables from the Time page
	$ntp=implode(" ", $_POST["ntp_servers"]);
	$location=$_POST['timezone'];
	// Set the Sabai config to reflect latest settings
	exec("uci $UCI_PATH set sabai.time.servers=\"" . $ntp . "\"");
	exec("uci $UCI_PATH set sabai.time.location=\"" . $location . "\"");
	exec("uci $UCI_PATH commit sabai");
	exec($command);
}

// Send completion message back to UI
echo "res={ sabai: true, msg: 'Time settings applied' }";
?>
