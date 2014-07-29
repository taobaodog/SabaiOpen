<!DOCTYPE html>
<html>
<head>
	<meta charset='UTF-8'><meta name='robots' content='noindex,nofollow'>
	<title>[VPNA] PPTP</title><link rel='stylesheet' type='text/css' href='sabai.css'>
	<script type='text/javascript' src='jquery-1.11.1.min.js'></script>
	<script type='text/javascript' src='sabaivpn.js'></script>
	<script type='text/javascript'>
	var hidden, hide, f,oldip='',limit=10,info=null,ini=false;

	pptp = {<?php
		$user=trim(exec("uci get sabai.vpn.username"));
		$pass=trim(exec("uci get sabai.vpn.password"));
		$server=trim(exec("uci get sabai.vpn.server"));
		if( $user!="" ) echo "\n\tuser: '". $user ."',\n\tpass: '". $pass ."',\n\tserver: '". $server ."'\n";
		else echo " user: '', pass: '', server: '' ";
	?>}

function setUpdate(res){
			if(info) oldip = info.vpn.ip; 
			eval(res); 
			if(oldip!='' && info.vpn.ip==oldip){ 
				limit--; 
			}; 
			if(limit<0) return; 

			for(i in info.vpn){ 
		 		E('vpn'+i).innerHTML = info.vpn[i]; 
		 	}
}

function getUpdate(ipref){ 
			que.drop('bin/info.php',setUpdate,ipref?'do=ip':null); 
	   $.get('bin/get_remote_ip.php', function( data ) {
	     donde = $.parseJSON(data.substring(6));
	     console.log(donde);
	     for(i in donde) E('loc'+i).innerHTML = donde[i];
	   });
}

function PPTPresp(res){ 
	eval(res); 
	msg(res.msg); 
	showUi(); 
	if(res.sabai){ 
		limit=10; 
		getUpdate(); 
	} 
}


function PPTPcall(act){ 
	hideUi("Adjusting PPTP..."); 
	E("_act").value=act; 
	que.drop("bin/pptp.php",PPTPresp, $("#_fom").serialize() ); 
		if(act =='clear'){ 
		setTimeout("window.location.reload()",5000);
			}; 
}

function init(){ 
	f = E('_fom'); 
	hidden = E('hideme'); 
	hide = E('hiddentext'); 
	for(var i in pptp){ 
		E(i).value = pptp[i]; 
	}; 
				<?php if (file_exists('stat/ip') && file_get_contents("stat/ip") != '') {
	   echo "donde = $.parseJSON('" . strstr(file_get_contents("stat/ip"), "{") . "');\n";
	   echo "for(i in donde){E('loc'+i).innerHTML = donde[i];}"; } ?>
	   getUpdate();
	   setInterval (getUpdate, 5000); 
	$('#VPNsub-menu').show();
	$('.active').removeClass('active')
	$('#pptp').addClass('active')
}
  
</script>

</head>
<body onload='init();' id='topmost'>
	<table id='container' cellspacing=0>
		<tr id='body'>		
			<td id='navi'>
					<script type='text/javascript'>navi()</script>
			</td>
			<td id='content'>
					<input type='button' class='fright' value='Help' onclick='window.open("http://www.sabaitechnology.com/v/sabaiHelp/vpnahelp.html#ovpn","_newtab");'>
				<div class='fright' id='vpnstats'>
					<div id='vpntype'></div>
					<div id='vpnstatus'></div>
				</div>

				<div class='fright' id='locstats'>
					<div id='locip'></div>
					<div class='noshow' id='loccontinent'></div>
					<div id='loccountry'></div>
					<div class= 'noshow' id='locregion'></div>
					<div id='loccity'></div>
				</div>

				<form id='_fom' method='post'>
				<div class="pageTitle">VPN: PPTP</div>
				<input type='hidden' id='_act' name='act'>

				<div class='section-title'>PPTP Setup</div>
				<div class='section'>
					<table class="fields"><tbody>
					 <tr>
					 	<td class="title indent1 shortWidth">Server</td>
					 	<td class="content">
					 		<input name="server" id="server" class='longinput' type="text">
					 	</td>
					 </tr>
					 <tr>
					 	<td class="title indent1 shortWidth">Username</td>
					 	<td class="content"><input name="user" id="user" class='longinput' type="text">
					 	</td>
					 </tr>
					 <tr>
					 	<td class="title indent1 shortWidth">Password</td>
					 	<td class="content">
					 		<input name="pass" id="pass" class='longinput' autocomplete="off" onfocus='peekaboo("pass")' onblur='peekaboo("pass")' type="password">
					 	</td>
					 </tr>
					</tbody></table>
					
					<input type='button' class='firstButton' value='Start' onclick='PPTPcall("start")'>
					<input type='button' value='Stop' onclick='PPTPcall("stop")'>
					<input type='button' value='Save' onclick='PPTPcall("save")'>
					<input type='button' value='Clear' onclick='PPTPcall("clear")'>
					<span id='messages'>&nbsp;</span><br>
				</div>
				</form>
			</td>
		</tr>
	</table>
	<div id='hideme'>
		<div class='centercolumncontainer'>
			<div class='middlecontainer'>
				<div id='hiddentext'>Please wait...</div>
				<br>
				<center>
				<img src='images/menuHeader.gif'>
				</center>
			</div>
		</div>
	</div>
	<div id='footer'> Copyright © 2014 Sabai Technology, LLC </div>
</body>
</html>