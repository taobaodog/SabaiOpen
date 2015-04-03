<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC
# get the location update url
 $URIfile=exec("uci get sabai.general.updateuri");
 # if it doesn't exist, create it
 $URI=file_exists($URIfile)?file_get_contents($URIfile):'http://router.sabaitechnology.biz/sabai';
 #get current location
 $get_ip=file_get_contents($URI."/donde.php?plz=kthx");
 $ip=str_replace("'", "", $get_ip);
 #store it in a stat file
 file_put_contents("/etc/sabai/stat/ip",$ip);
 #give it back to the calling program
 echo $ip;
?>
