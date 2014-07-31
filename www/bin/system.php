<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC
 header("Content-type: text/plain");
 
if(isset($_REQUEST['act']) && $_REQUEST['act']!="")
{
$act=$_REQUEST['act'];

$toShell= exec("sh /www/bin/system.sh $act",$out);

echo $toShell;


}
?>
