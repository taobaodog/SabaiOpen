<?php 
  
$json = json_decode($_POST['dhcptable'], true);
$file = '/tmp/table1';  
unset ($json[0]);
$aaData=json_encode($json);
file_put_contents($file, $aaData);
$command="sh /www/bin/dhcptable.sh";
exec($command);
 
// Send completion message back to UI
$res = array('sabai' => true, 'rMessage' => 'DHCP in development');
echo json_encode($res);

?>  