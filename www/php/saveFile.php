<?php
if(isset($_POST['loadFile'])) {
        $file_name = $_POST['loadFile'];
	$File = '/configs/'.$file_name;
	$name = str_replace("backup_", "", $file_name);
	if (file_exists("/configs/ovpn_backup/ovpn.filename_$name")) {
		$config="/configs/ovpn_backup/ovpn.config_$name";
		$msg="/configs/ovpn_backup/ovpn.msg_$name";
		$ovpn_filename="/configs/ovpn_backup/ovpn.filename_$name";
		exec("tar -cvf /configs/$file_name.tar $File $config $msg $ovpn_filename");	
	}	
        $pathToFile = "/configs/" . $file_name . ".tar" ;
        echo $pathToFile;
}
?>
