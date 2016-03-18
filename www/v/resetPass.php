<?php
error_reporting(0);
session_start();
$_SESSION['count'] = 1;

$pass=$_REQUEST['pass'];
exec("echo -n $pass > /tmp/hold");
exec("sh /www/bin/settings.sh updatepass");
echo "New password is available.";
?>
