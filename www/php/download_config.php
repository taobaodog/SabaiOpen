<?php

$uploaddir = '/configs/';

if (!empty($_FILES['_browse1']['tmp_name'])) {
        $uploadfile = $uploaddir.basename($_FILES['_browse1']['name']);
        $copy_res = copy($_FILES['_browse1']['tmp_name'], $uploadfile) or die( "Could not copy file!");
        $exist_res = file_exists("$uploadfile");
        if ($copy_res != 1 && $exist_res != 1) {
                echo "false";
        } else {
                echo "true";
        }
} else {
        echo "false";
}
?>

