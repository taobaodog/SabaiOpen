<?php
error_reporting(0);
session_start();

$user=$_REQUEST['name'];
$pass=$_REQUEST['pass'];

if ($_SESSION['login'] == 'true'){
	exec("logger \"1\"");
	header("Location: /index.php");
	die();
} elseif ($user == "admin"){	
		exec("logger \"2\"");
		$hash=exec("cat /etc/shadow | grep admin | awk -F: '{print $2}'");
		if (password_verify($pass, $hash)) {
			$_SESSION['login'] = 'true';
			$_SESSION['username'] = $user;
			header("Location: /");
			die();
		} else {
			echo 'Password is incorrect.';
		}
}else{
	exec("logger \"4\"");
	echo "User Name is incorrect.";
	header("Location: /index.php");
}
?>
