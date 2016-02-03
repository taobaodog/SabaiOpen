<?php
// Sabai Technology - Apache v2 licence
// Copyright 2015 Sabai Technology, LLC
$UCI_PATH = "-c /etc/config";
//receive action requested from GUI
$act = $_POST['act'];

if ($act == "save") {
	//receive datatables information from GUI
	$json = json_decode($_POST['dhcptable'], true);

	//set file to be used to process data into effective json format 
	$file = '/tmp/table1';  
	unset ($json[0]); //MAKE BIG SENSE 
	$aaData=json_encode($json);

	//write initial json data into file for dhcptable.sh to work on
	file_put_contents($file, $aaData);

	//rework data into datatables ready json format
	exec("sh /www/bin/dhcp.sh json");

	//receive reworked datatables ready json data
	file_get_contents("/tmp/table4", $aaData);

	//save changes in static
	$res=exec("sh /www/bin/dhcp.sh save 2>&1", $out);

	//cleanup workspace
	//exec("rm /tmp/table*");

	// Send completion message back to UI                                
	echo $res; 

} elseif ($act == "get") {
	//sabai.dhcp.table is constructed and assigned 
	exec("sh /www/bin/dhcp.sh get");
}
?>  
