<?php
// Sabai Technology - Apache v2 licence
// Copyright 2016 Sabai Technology, LLC
$userPass=$_REQUEST['sabaiPassword'];
$password = crypt($userPass);
//path to config files
$UCI_PATH="-c /etc/config";

exec("uci $UCI_PATH set sabai.general.password=$password");
echo "res={ sabai: 1, msg: 'Credentials Updated' };";
?>

