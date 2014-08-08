<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC
$prim=$_REQUEST['primaryDNS'];
$sec=$_REQUEST['secDNS'];


$toShell= exec("sh dns.sh $prim $sec",$out);

echo $toShell;
?>
