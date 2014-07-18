<?php
 header('Content-type: text/ecmascript');
 
 function getConf($q, $debug){
  foreach($q as $i){
	$q[$i](get);
		
 }

// Settings Functions
function lan($in){
  $lan_ipaddr=exec("uci $in network.lan.ipaddr");
  $lan_netmask=exec("uci $in network.lan.netmask");
  if ( $in == "set" ) {
	exec("uci commit");
	network(restart);
}

function dhcp($in){
  $lan_ipaddr=exec("uci $in network.lan.ipaddr");
  $lan_netmask=exec("uci $in network.lan.netmask");
  if ( $in == "set" ) {
	exec("uci commit");
	network(restart);
}


// Service Functions
function network($in){
  exec("service network $in");
}

?>
