<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=vpn&section=openvpnclient";
	header( "Location: $url" );     
}
?>
<!DOCTYPE html>
<!--Sabai Technology - Apache v2 licence
    copyright 2016 Sabai Technology -->
<html>
<head>
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="/libs/jqueryui.css">
	<link rel="stylesheet" type="text/css" href="/libs/jai-widgets.css">
	<link rel="stylesheet" type="text/css" href="/libs/css/main.css">
</head>
<body onload='init();' id='topmost'>
	<div class='pageTitle'>VPN: OpenVPN Client</div>
		<div class='controlBox'><span class='controlBoxTitle'>OpenVPN Settings</span>
			<div class='controlBoxContent'>
				<form id="ovpn_file">
					<div>Upload new VPN configuration file. </div><br>
					<input id='browse' type='button' name='browse' value='Browse' />
					<input id='fileName' type='text' name='fileName' />
					<input id='file' type='file' name='file' hidden='true' />
					<input id='submit' name='submit' type='button' value='Upload' /><br><br>
					<div>Current configuration: <span id='currFile'></span></div><br>
					<input type='button' value='Start' onclick='OVPNsave("start");'>
					<input type='button' value='Stop' onclick='OVPNsave("stop");'>
					<input id='clear' type='button' value='Clear' onclick='OVPNsave("clear");'></span>
					<input type='button' value='Show Log' id='logButton' onclick='toggleLog();'>
					<input type='button' value='Edit Config' id='editButton' onclick='toggleEdit();'>
				</form>
			<div id='hideme'>
				<div class='centercolumncontainer'>
					<div class='middlecontainer'>
						<div id='hiddentext'>Please wait...</div>
					</div>
				</div>
			</div>		
			</div>
		</div>
<p>
	<div id='footer'>Copyright © 2016 Sabai Technology, LLC</div>
</p>
</body>
</html>

<script type="text/javascript">
var f,oldip='',limit=10,logon=false,info=null;
var ovpnTry = 0;
var hidden, hide, pForm = {};
var hidden = E('hideme');
var hide = E('hiddentext');

$(document).ready(function(){
	$("#submit").on("click", function() {
		hideUi("Uploading ...");
		var ovpnFile=$("#file").val();
		if ( ovpnFile != '') {
			$.post('php/ovpn.php')
		} else {
			$('input[type="text"]').css("border","2px solid red");
			$('input[type="text"]').css("box-shadow","0 0 3px red");
			hideUi('Please, choose the file!');
			setTimeout(function(){showUi()},4500);
		}
	});
});
</script>
