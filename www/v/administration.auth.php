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

function resetPass() {
	$(document).ready(function() {
		$("#reset").dialog({
    		autoOpen: true,
    		modal: true,
    	    resizable: false,
    	    draggable: false,
    		buttons:{ 
					"OK": {
						text: "OK",
    		            click: function() { setPass(); }
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
					alert(data);
				} else if (data.indexOf("reset") >=0) {
					alert("You can reset your password.");
					$("#login").dialog('close');
					resetPass();
				} else {
					//start session
					$("#login").dialog('close');
					window.location.href = "/";
				}
			})
			.fail(function() {
				alert("Login is FAILED!");
			})
	}
}

function setPass(){
	var newPass_1=$("#pass_1").val();
	var newPass_2=$("#pass_2").val();
	
	if( newPass_1 =='' || newPass_2 ==''){
		$('input[type="text"],input[type="password"]').css("border","2px solid red");
		$('input[type="text"],input[type="password"]').css("box-shadow","0 0 3px red");
		alert("Please fill all fields !!!");
	} else if ( newPass_1 != newPass_2 ) {
		$('input[type="text"],input[type="password"]').css("border","2px solid blue");
		$('input[type="text"],input[type="password"]').css("box-shadow","0 0 3px blue");
		alert("Passwords differ.");
	} else {
		$.post("resetPass.php",{ 'pass': newPass_1} )
		.done(function(data) {
			alert(data);
			$("#reset").dialog('close');
			window.location.href = "/";
		})
		.fail(function(data) {
			alert("Password changing is FAILED.");
		})
	} 

}
</script>
</head><body onload='init()'>
<div hidden="true" id="login" title="Authentication required">Please insert username and password to login.
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

<div hidden="true" id="reset" title="New password">
    <form id="auth" method="post" enctype="multipart/form-data" >
		<table>
            <tr>
                <td>New password:</td>
                <td>
                    <input id="pass_1" name="pass_1" type="text" />
                </td>
            </tr>
            <tr>
                <td>Confirm new password:</td>
                <td>
                    <input id="pass_2" name="pass_2" type="text" />
                </td>
            </tr>
        </table>
    </form>
</div>
<input hidden="true" id="panel" value="auth"/>
<input hidden="true" id="section" value="auth"/>
</body>

</html>
