<?php
	$act = $_POST['action'];
	$data_post = $_POST["raw"]["data"][0];
	$data_raw = $_POST["raw"]["data"][0]["DT_RowId"];
	$data_val = $_POST["raw"]["data"][0]["ntp_server"];

	$json_old_raw = file_get_contents("/www/libs/data/network.time.json");
	$json_old = json_decode($json_old_raw, true);
	$json_new = array();
	$length	 = count($json_old["aaData"]) - 1;


	function remove() {
		global $data_val, $json_old, $json_new;
		$string_to_remove = $data_val;
		foreach ($json_old["aaData"] as $key => $value) {
			if ($value["ntp_server"] != $string_to_remove) {
				$json_new[] = $value; 
			}
		}
		
		$json_old["aaData"] = $json_new;
		$data = json_encode($json_old, true);
		file_put_contents("/www/libs/data/network.time.json", $data);
		echo "NTP server has been removed.";	
	}

	function edit() {
		global $data_val, $data_raw, $json_old, $json_new, $length;
		$string_to_edit = $data_raw;
		foreach ($json_old["aaData"] as $key => $value) {
			if ($value["DT_RowId"] == $string_to_edit) {
				foreach ($json_old["aaData"] as $key => $value) {
					if ($value["ntp_server"] == $data_val) {
						$res = "NTP server has been already added.";
					} else {
						if ($key == $length) {
							$value["ntp_server"] = $data_val;
							$res = "NTP server options has been changed.";
						}
					}
					$json_new[] = $value;
				}
			}
						
		}
		$json_old["aaData"] = $json_new;
		$data = json_encode($json_old, true);
		file_put_contents("/www/libs/data/network.time.json", $data);
		echo $res;		
	}

	function add() {
		global $data_val, $data_post, $json_old, $json_new, $length;
		$string_to_add = $data_val;

		foreach ($json_old["aaData"] as $key => $value) {
			if ($value["ntp_server"] == $string_to_add) {
				echo "NTP server has been already added.";
			} else {
				$json_new[] = $value;
				if ($key == $length) {
					$json_new[] = $_POST["raw"]["data"][0];
					$json_old["aaData"] = $json_new;
					$data = json_encode($json_old, true);
					file_put_contents("/www/libs/data/network.time.json", $data);
					echo "New NTP server has been added.";
				} 
			}
		}
	}

	switch ($act) {
		case 'deleteRow':
			remove();
			break;
		case 'editRowData':
			edit();
			break;
		case 'addRowData':
			add();
			break;
		default:
			echo "Something went wrong!";
			break;
	}
?>