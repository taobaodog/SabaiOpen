<?php
if(isset($_POST['newName'])) {
	$file_name = str_replace(" " , "_" , $_POST['newName']);
	if (trim($file_name) == null) {
		echo "false";
	} else {
		exec("cp /configs/sabai /configs/backup_$file_name");
		echo "New backup was saved as backup_$file_name";
	}
} else {
    echo "false";
}
?>
