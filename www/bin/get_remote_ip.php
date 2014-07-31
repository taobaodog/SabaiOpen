<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC
 $URIfile='/etc/sabai/sys/updateURI';
 $URI=file_exists($URIfile)?file_get_contents($URIfile):'http://blog.sabaitechnology.com/sabai';
 $ip=file_get_contents($URI ."/donde.php?plz=kthx");
 file_put_contents("/etc/sabai/stat/ip",$ip);
 echo $ip;
?>