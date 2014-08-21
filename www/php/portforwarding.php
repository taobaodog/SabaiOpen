<?php 
  
$json = json_decode($_REQUEST['pftable'], true);
//$file = '/tmp/table';   
//$pftable=json_decode($_REQUEST['pftable']); 
file_put_contents($file, $json);
//$multicast=$_REQUEST['multicastToggle']; 
//$cookies=$_REQUEST['synToggle']; 
//$wanroute=$_REQUEST['wanToggle']; 


// Set the Sabai config to reflect latest settings
//exec("uci set sabai.firewall.icmp=\"" . $icmp . "\"");
//exec("uci set sabai.firewall.multicast=\"" . $multicast . "\"");
//exec("uci set sabai.firewall.cookies=\"" . $cookies . "\"");
//exec("uci set sabai.firewall.wanroute=\"" . $wanroute . "\"");
//exec("uci commit sabai");

//if ($icmp == '') $icmp="off" ;
//if ($multicast == '') $multicast="off" ;
//if ($cookies == '') $cookies="off" ;
//if ($wanroute == '') $wanroute="off" ;

//exec("sh /www/bin/firewall.sh $icmp $multicast $cookies $wanroute");

// Send completion message back to UI
$res = array('sabai' => true, 'rMessage' => 'Port Forwarding in development');
echo json_encode($res);

?>  
