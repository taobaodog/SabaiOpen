<!DOCTYPE html>
<!--Sabai Technology - Apache v2 licence
    copyright 2014 Sabai Technology -->
<meta charset="utf-8"><html><head>
<link rel="stylesheet" type="text/css" href="/libs/jqueryui.css">
<link rel="stylesheet" type="text/css" href="/libs/jai-widgets.css">
<link rel="stylesheet" type="text/css" href="/libs/css/main.css">
<?php 
include("$_SERVER[DOCUMENT_ROOT]/php/libs.php");
?>
<script>

function init() { 
	$(document).ready(function() {
		//$("#backdrop").hide();
		$("#login").dialog({
    		autoOpen: true,
    		modal: true,
    	    resizable: false,
    	    draggable: false,
    		buttons:{ 
					"Cancel": {
		            	text: "Cancel",
		            	click: function() { cancelLogin(); }
		          	},
					"OK": {
						text: "OK",
    		            click: function() { okLogin(); }
    		          }
    		    	}
        });
   	});
}

function cancelLogin(){
	E('username').value = "";
	E('password').value = "";
	init();
}

function okLogin(){
	var userName=$("#username").val();
	var userPass=$("#password").val();
	
	if( userName =='' || userPass ==''){
		$('input[type="text"],input[type="password"]').css("border","2px solid red");
		$('input[type="text"],input[type="password"]').css("box-shadow","0 0 3px red");
		alert("Please fill all fields !!!");
	} else {
		$.post("login.php",{ 'name': userName, 'pass': userPass})
			.done(function(data) {
				if (data.indexOf("incorrect") >=0) {
					//alert(data);
					window.location.href = "/";
				} else {
					//start session
					$("#login").dialog('close');
					window.location.href = "/";
					//$("#backdrop").show();
				}
			})
			.fail(function(data) {

			})
	}
}
</script>
</head><body onload='init()'>
<div hidden="true" id="login" title="Authentification required">Please insert username and password to login.
    <form id="auth" method="post" enctype="multipart/form-data" >
		<table>
            <tr>
                <td>User Name:</td>
                <td>
                    <input id="username" name="username" type="text" />
                </td>
            </tr>
            <tr>
                <td>Password:</td>
                <td>
                    <input id="password" name="password" type="password" />
                </td>
            </tr>
        </table>
    </form>
</div>
<input hidden="true" id="panel" value="auth"/>
<input hidden="true" id="section" value="auth"/>
</body>

</html>
