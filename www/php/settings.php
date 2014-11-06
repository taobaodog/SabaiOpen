<?php
 header("Content-type: text/plain");
 
if(isset($_REQUEST['act']) && $_REQUEST['act']!="")
{
$act=$_REQUEST['act'];
$pass=$_REQUEST['sabaiPassword'];
$name=$_REQUEST['host'];
exec("uci set sabai.general.hostname=\"" . $name . "\"");
exec("uci commit");
exec("echo -n $pass > /tmp/hold");

$toShell= exec("sh /www/bin/settings.sh $act",$out);

echo $toShell;


}
?>