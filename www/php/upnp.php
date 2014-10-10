<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology

// Bring over variables from the UPNP page
$enable=trim($_POST['enableToggle']);
$natpmp=trim($_POST['natpmpToggle']);
$clean=trim($_POST['cleanToggle']);
$secure=trim($_POST['secureToggle']);
$intmin=trim($_POST['intmin']);
$intmax=trim($_POST['intmax']);
$extmin=trim($_POST['extmin']);
$extmax=trim($_POST['extmax']);
$command="sh /www/bin/upnp.sh";

// Set the Sabai config to reflect latest settings
exec("uci set sabai.upnp.enable=\"" . $enable . "\"");
exec("uci set sabai.upnp.natpmp=\"" . $natpmp . "\"");
exec("uci set sabai.upnp.clean=\"" . $clean . "\"");
exec("uci set sabai.upnp.secure=\"" . $secure . "\"");
exec("uci set sabai.upnp.intmin=\"" . $intmin . "\"");
exec("uci set sabai.upnp.intmax=\"" . $intmax . "\"");
exec("uci set sabai.upnp.extmin=\"" . $extmin . "\"");
exec("uci set sabai.upnp.extmax=\"" . $extmax . "\"");
exec("uci commit sabai");
exec($command);

// Send completion message back to UI
echo "res={ sabai: true, msg: 'UPNP settings applied' }";

?>