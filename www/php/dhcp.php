<?php 
  
//receive action requested from GUI
$act = $_POST['act'];

if ($act == "save") {
	//receive datatables information from GUI
	$json = json_decode($_POST['dhcptable'], true);

	//set file to be used to process data into effective json format 
	$file = '/tmp/table1';  
//	unset ($json[0]); (makes no sense)
	$aaData=json_encode($json);

	//write initial json data into file for dhcptable.sh to work on
	file_put_contents($file, $aaData);

	//rework data into datatables ready json format
	exec("sh /www/bin/dhcp.sh json");

	//receive reworked datatables ready json data
	file_get_contents("/tmp/table4", $aaData);

	//save and commit modified json 
	exec("uci set sabai.dhcp.table=\"" . $aaData . "\"");
	exec("uci commit");

	//save changes in static
	exec("sh /www/bin/dhcp.sh save");

	//cleanup workspace
	//exec("rm /tmp/table*");

}

if ($act == "get") {
	//sabai.dhcp.table is constructed and assigned 
	exec("sh /www/bin/dhcp.sh get");
}

// Send completion message back to UI
$res = array('sabai' => true, 'rMessage' => 'DHCP in development');
echo json_encode($res);

?>  