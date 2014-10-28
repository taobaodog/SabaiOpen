<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC
$userPass=$_REQUEST['sabaiPassword'];
$password = crypt($userPass);

exec("uci set sabai.general.password=$password");
echo "res={ sabai: 1, msg: 'Credentials Updated' };";
?>
