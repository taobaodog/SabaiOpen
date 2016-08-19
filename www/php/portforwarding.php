<?php
// Sabai Technology - Apache v2 licence
// Copyright 2016 Sabai Technology 
  
$json = json_decode($_POST['pftable'], true);
$file = '/tmp/table1';  
unset ($json[0]);
$aaData=json_encode($json);
file_put_contents($file, $aaData);
#create the table and write to sabai uci
$command="/www/bin/pftable.sh";
exec($command);
#implement the table
$res=exec("/www/bin/portforwarding.sh 2>&1",$out);
 
// Send completion message back to UI
echo $res;

?>  
