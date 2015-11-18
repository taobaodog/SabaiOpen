<?php
// Sabai Technology - Apache v2 licence
// Copyright 2015 Sabai Technology, LLC
	$UCI_PATH = "-c /configs";

	# allow HTTPS comunication
	$arrContextOptions=array(
		"ssl"=>array(
		"cafile" => "/etc/php5/ca-bundle.crt",
		"verify_peer"=>true,
		"verify_peer_name"=>true,
		),
);
	
	# get the location update url
	$URIfile=exec("uci get sabai.general.version_uri");
	# if it doesn't exist, create it
	$URI=file_exists($URIfile)?file_get_contents($URIfile):'https://raw.githubusercontent.com/sabaitechnology/SabaiOpen/master/version';
	$get_data=file_get_contents($URI, false, stream_context_create($arrContextOptions));
	
	$data=str_replace("Soft:", "", $get_data);
	$obj=json_decode($data);
	$version=$obj->version;
	$link=$obj->link;

	$curr_version=exec("uci get sabai.general.version");
	if ($curr_version != $version) {
		exec("uci $UCI_PATH set sabai.general.new_version=\"" . $version . "\"");
		exec("uci $UCI_PATH set sabai.general.download_uri=\"" . $link . "\"");
		exec("uci $UCI_PATH commit sabai");
		echo $version;
	} else {
		echo "false";
	}
	
?>
