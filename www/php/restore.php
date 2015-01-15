<?php
if(isset($_POST['restoreName'])) {
	$file_name = $_POST['restoreName'];
	exec("sh /www/bin/config_upload.sh /configs/$file_name");
	echo "OK";
} else {
	echo "false";
}
?>
