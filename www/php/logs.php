<?php
// Sabai Technology - Apache v2 licence
// Copyright 2016 Sabai Technology
 if (!headers_sent()){ header('Content-type: text/ecmascript'); }
 $logPath = '/var/log/';

function listFiles($path, $prefix = '', $sublist = false, $pathName = ''){
	if(empty($path) || (!is_readable($path)) || (!($files = scandir($path))) || empty($files) ) return;
	if($sublist){
		$eid = strtr(trim($path,"/"),"/","-");
		echo "$prefix<li class='sublist'>\n";
		echo "$prefix<span class='dir closed' rel='$eid'>$pathName/</span><ul class='directory' id='$eid'>\n";
	}else{
		echo "<ul id='listRoot' class='dirlist'>\n";
	}
	sort($files, SORT_NATURAL | SORT_FLAG_CASE);
	foreach($files as $f){
		if($f=='.' || $f=='..') continue; // ignore . and ..
		if(is_dir( ($fpath = rtrim($path,'/') .'/' .$f) )){
			listFiles($fpath, $prefix."\t", true, $f);
		}else{
			echo "$prefix\t<li>$f</li>\n";
		}
	}
	echo "$prefix</ul>\n";
	if($sublist) echo "$prefix</li>\n";
}

$act=array_key_exists('act', $_REQUEST) ? $_REQUEST['act'] : null;
$log=array_key_exists('log', $_REQUEST) ? $_REQUEST['log'] : null;
$detail=array_key_exists('detail', $_REQUEST) ? $_REQUEST['detail'] : null;


$validPath = realpath($logPath . $log);



$isZipped = ( pathinfo($validPath, PATHINFO_EXTENSION) == 'gz' );
$detail = escapeshellarg($detail);

switch ($act) {
	case 'all':
		if ($isZipped){
			passthru("gunzip -c $validPath");
		}else{
			readfile($validPath);	
		}
	break;

	case 'head':
	case 'tail':
		$detail = '-n '. $detail;
	case 'grep':
		passthru( $isZipped ? "gunzip -c $validPath | $act $detail" : "$act $detail $validPath" );
	break;
	case 'download':
		if (file_exists("/var/log/messages")) {
			exec("mkdir /configs/log/");
			exec("cat /var/log/messages > /configs/log/syslog");
			$pathToFile = "/configs/log/syslog";
		} else {
			$pathToFile = "false";
		}
		echo $pathToFile;
	break;
	
	case 'list':
	default:
		listFiles($logPath);
	break;
}

?>
