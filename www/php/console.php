<?php
// Sabai Technology - Apache v2 licence
// copyright 2014 Sabai Technology, LLC
$act=$_REQUEST['act'];
$ex=str_replace("\r","\n",$_REQUEST['cmd']);
$rname="/tmp/tmp.". str_pad(mt_rand(1000,9999), 4, "0", STR_PAD_LEFT)  .".sh";
file_put_contents($rname,"#!/bin/ash\nexport PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'\n$ex\n");
exec("ash $rname",$out);
header("Content-type: text/plain");
echo (unlink($rname)?"":"There was an error when trying to delete the file $rname.\n") . implode("\n",$out);
?>