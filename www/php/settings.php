<?php
// Sabai Technology - Apache v2 licence
// Copyright 2015 Sabai Technology
 header("Content-type: text/plain");
$UCI_PATH="-c /configs"; 
if(isset($_REQUEST['act']) && $_REQUEST['act']!="")
{
$filter = array("<", ">","="," (",")",";","/","|");
$_REQUEST['act']=str_replace ($filter, "#", $_REQUEST['act']);
$act=$_REQUEST['act'];
$pass=$_REQUEST['sabaiPassword'];
$name=$_REQUEST['host'];
exec("uci $UCI_PATH set sabai.general.hostname=\"" . $name . "\"");
exec("uci $UCI_PATH commit sabai");
exec("echo -n $pass > /tmp/hold");

$toShell= exec("sh /www/bin/settings.sh $act",$out);

echo $toShell;


}
?>
