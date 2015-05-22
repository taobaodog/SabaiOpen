<?php 
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology
$UCI_PATH="-c /configs";
$filter = array("<", ">","="," (",")",";","/","|");
$_REQUEST['dmzToggle']=str_replace ($filter, "#", $_REQUEST['dmzToggle']);
$_REQUEST['dmz_destination']=str_replace ($filter, "#", $_REQUEST['dmz_destination'];
$status=$_REQUEST['dmzToggle']; 
$destination=$_REQUEST['dmz_destination']; 

// Set the Sabai config to reflect latest settings
exec("uci $UCI_PATH set sabai.dmz.status=\"" . $status . "\"");
exec("uci $UCI_PATH set sabai.dmz.destination=\"" . $destination . "\"");
exec("uci $UCI_PATH commit sabai");

if ($status == '') $status="off" ;

$toDo=exec("sh /www/bin/dmz.sh $status $destination",$out);
echo $toDo;

?>  
