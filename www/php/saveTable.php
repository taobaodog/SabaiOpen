<?php
	$data_rows = $_POST["row"];
	$data_table_id = $_POST["table"];
	$data = json_encode($data_rows, true);

	file_put_contents("/www/libs/data/network.time.json", $data);
?>