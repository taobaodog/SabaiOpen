<?php
$prim=$_REQUEST['primaryDNS'];
$sec=$_REQUEST['secDNS'];


$toShell= exec("sh dns.sh $prim $sec",$out);

echo $toShell;
?>
