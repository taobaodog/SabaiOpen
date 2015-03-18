<?php 
  
$json = json_decode($_POST['pftable'], true);
$file = '/tmp/table1';  
unset ($json[0]);
$aaData=json_encode($json);
file_put_contents($file, $aaData);
#create the table and write to sabai uci
$command="sh /www/bin/pftable.sh";
exec($command);
#implement the table
$command="sh /www/bin/portforwarding.sh save";
exec($command);
 
// Send completion message back to UI
$res = array('sabai' => true, 'rMessage' => 'Port Forwarding in development');
echo json_encode($res);

?>  
