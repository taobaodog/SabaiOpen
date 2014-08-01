<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC
$userPass=$_REQUEST['vpnaPassword'];
$password = crypt($userPass);

file_put_contents("/www/sys/net.aut", "sabai" .":". $password);
echo "res={ sabai: 1, msg: 'Credentials Updated' };";
?>
