<?php

$uploaddir = '/configs/';
$ovpn_dir = $uploaddir . "ovpn_backup/";


if (!empty($_FILES['_browse1']['tmp_name'])) {
        $uploadfile = basename($_FILES['_browse1']['name']);
	$tmp="/tmp/".$uploadfile;
	copy($_FILES['_browse1']['tmp_name'], $tmp) or die( "Could not copy file!");
	$file_type = pathinfo($tmp, PATHINFO_EXTENSION);
	
	if ($file_type == "tar") {
		$name = str_replace(".tar", "", $uploadfile);
		//TODO: check if it is backup or not 
		$file = str_replace("backup_", "", $name);;
		exec("mkdir /tmp/$name");
		exec("tar -xvf $tmp -C /tmp/$name");
		if (copy("/tmp/" . $name . "/configs/" . $name,$uploaddir.$name)) {
			if (file_exists($uploaddir.$name)) {
				exec("ln -s $uploaddir$name /etc/config/$name");
				$get_version = exec("uci get $name.general.version");
				if ($get_version != "") {
					$ovpn_tmp = "/tmp/" . $name . "/configs/ovpn_backup/";
					$copy_config = copy($ovpn_tmp . "ovpn.config_" . $file, $ovpn_dir."ovpn.config_".$file);
					$copy_msg = copy($ovpn_tmp . "ovpn.msg_" . $file, $ovpn_dir."ovpn.msg_".$file) ;
					$copy_filename = copy($ovpn_tmp . "ovpn.filename_" . $file, $ovpn_dir."ovpn.filename_".$file);
					if ($copy_config == 1 && $copy_msg == 1 && $copy_filename ==1) {
						echo "true";
					} else {
						echo "OVPN configuration was not uploaded.";
					} 
				} else {
					echo "Failed.You tried to upload some wrong configuration.";
				}
			} else {
				echo "Something went wrong. No file was uploaded.";
			}
                } else {
                        echo "Something went wrong. Could not upload your file.";
                }
        } else {
		echo "TODO: upload just a config file";
	}
	exec("rm /etc/config/$file");
} else {
        echo "false";
}

?>

