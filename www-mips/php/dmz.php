<?php 
// Sabai Technology - Apache v2 licence
// Copyright 2015 Sabai Technology
$UCI_PATH="-c /etc/config";
$filter = array("<", ">","="," (",")",";","/","|");
$_REQUEST['dmzToggle']=str_replace ($filter, "#", $_REQUEST['dmzToggle']);
$_REQUEST['dmz_destination']=str_replace ($filter, "#", $_REQUEST['dmz_destination']);
$status=$_REQUEST['dmzToggle']; 
$destination=$_REQUEST['dmz_destination']; 
if ($status == '') $status="off" ;

// Set the Sabai config to reflect latest settings
exec("uci $UCI_PATH set sabai.dmz.status=\"" . $status . "\"");
exec("uci $UCI_PATH set sabai.dmz.destination=\"" . $destination . "\"");
exec("uci $UCI_PATH commit sabai");

$toDo=exec("sh /www/bin/dmz.sh $status $destination",$out);
echo $toDo;

?>  
