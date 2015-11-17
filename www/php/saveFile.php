<?php
// Sabai Technology - Apache v2 licence
// Copyright 2015 Sabai Technology
if(isset($_POST['loadFile'])) {
        $file_name = $_POST['loadFile'];

	$check = strpos($name, "backup_");
	if ($check === false) {
		$name = $file_name;
	} else {
		$name = str_replace("backup_", "", $file_name);
	}
	
	switch ($name) {
		case "sabai":
			$date = exec("date '+%B %d' | tr -d ' ' ");
			exec("cp /etc/sabai/openvpn/ovpn.current /configs/ovpn_backup/ovpn.config_$name$date");
			exec("cp /etc/sabai/openvpn/ovpn /configs/ovpn_backup/ovpn.msg_$name$date");
			exec("cp /etc/sabai/openvpn/ovpn /configs/ovpn_backup/ovpn.filename_$name$date");
			exec("cp /configs/$name /configs/$name$date");
			$config="/configs/ovpn_backup/ovpn.config_$name$date";                          
			$msg="/configs/ovpn_backup/ovpn.msg_$name$date";                                
			$ovpn_filename="/configs/ovpn_backup/ovpn.filename_$name$date";
			$File = '/configs/'.$file_name.$date;
			exec("tar -cvf /configs/$name$date.tar $File $config $msg $ovpn_filename");
			$pathToFile = "/configs/" . $name . $date . ".tar" ;
			break;
		default:
			if (file_exists("/configs/ovpn_backup/ovpn.filename_$name")) {
				$File = '/configs/'.$file_name;
				$config="/configs/ovpn_backup/ovpn.config_$name";
				$msg="/configs/ovpn_backup/ovpn.msg_$name";
				$ovpn_filename="/configs/ovpn_backup/ovpn.filename_$name";
				exec("tar -cvf /configs/$file_name.tar $File $config $msg $ovpn_filename");
				$pathToFile = "/configs/" . $file_name . ".tar" ;
			} else {
				$pathToFile = "/configs/" . $file_name;
			}
	}	
        echo $pathToFile;
}
?>
