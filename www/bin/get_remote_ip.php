<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC
 $URIfile='/www/sys/updateURI';
 $URI=file_exists($URIfile)?file_get_contents($URIfile):'http://blog.sabaitechnology.com/sabai';
 $lastip=file_get_contents($URI ."/donde.php?plz=kthx");
 file_put_contents("/www/stat/ip",$lastip);
 echo $lastip;
?>
