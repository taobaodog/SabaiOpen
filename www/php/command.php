<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC
 

$act=$_REQUEST['act'];
if ( $act == "halt" ){
	echo "Shutting Down";
}
exec("$act");

?>
