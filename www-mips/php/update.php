<?php
// Sabai Technology - Apache v2 licence
// Copyright 2015 Sabai Technology

$file = '/tmp/upgrade/sabai-bundle-secured.tar';
if (file_exists($file))	{
	$res = exec("sh /www/bin/upgrade.sh");
	if (!strpos($res,"-")) {
		echo "OK";
	} else {
		echo strtok($res,"-");
	}
} else {
	echo "false";
}  

?>

