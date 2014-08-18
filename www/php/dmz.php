<?php 
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology
$status=$_REQUEST['dmzToggle']; 
$destination=$_REQUEST['dmz_destination']; 

// Set the Sabai config to reflect latest settings
exec("uci set sabai.dmz.status=\"" . $status . "\"");
exec("uci set sabai.dmz.destination=\"" . $destination . "\"");
exec("uci commit sabai");

if ($status == '') $status="off" ;

$toDo=exec("sh /www/bin/dmz.sh $status $destination",$out);
echo $toDo;

?>  
