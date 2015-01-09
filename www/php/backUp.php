<?php
if(isset($_POST['newName'])) {
	$file_name = $_POST['newName'];
	if (trim($file_name) == null) {
		echo "no name";
	} else {
		exec("cp /configs/sabai /configs/backup_$file_name");
		echo "New backup was saved as backup_$file_name";
	}
} else {
    echo "false";
}
?>
