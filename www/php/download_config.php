<?php

$uploaddir = '/configs/';

if (!empty($_FILES['_browse1']['tmp_name'])) {
        $uploadfile = basename($_FILES['_browse1']['name']);
        $copy_res = copy($_FILES['_browse1']['tmp_name'], $uploaddir.$uploadfile) or die( "Could not copy file!");
        exec("ln -s $uploaddir$uploadfile /etc/config/$uploadfile");
        $get_version = exec("uci get $uploadfile.general.version");
        if ($get_version == "") {
		exec("rm $uploaddir$uploadfile");
                echo "false";
        } else {
                $exist_res = file_exists("$uploaddir.$uploadfile");
                if ($copy_res != 1 && $exist_res != 1) {
                        echo "false";
                } else {
                        echo "true";
                }
        }
	exec("rm /etc/config/$uploadfile");
} else {
        echo "false";
}

?>

