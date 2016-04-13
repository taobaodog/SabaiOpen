<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=vpn&section=openvpnclient";
	header( "Location: $url" );     
}
?>
<!--Sabai Technology - Apache v2 licence
    Copyright 2016 Sabai Technology -->
	<script type='text/javascript'>

		var hidden,hide,f,oldip='',limit=10,logon=false,info=null;
		var ovpnTry = 0;

		function setLog(res){ 
			E('response').value = res; 
		}

		function saveEdit(){ 
			hideUi("Adjusting OpenVPN..."); 
			E("_act").value='save'; 
			que.drop( "php/ovpn.php", OVPNresp, $("#fe").serialize() );
		}

		function toggleEdit(){
		 $('#ovpn_controls').hide();
		 E('logButton').style.display='none';
		 E('edit').className='';
		 E('editButton').style.display='none';
<?php
        if (file_exists('/etc/sabai/openvpn/auth-pass')) {
                $authpass = file('/etc/sabai/openvpn/auth-pass');
                echo "uname =  '";
                echo rtrim($authpass[0]);
                echo "';\npass = '" . rtrim($authpass[1]) . "';\n";
}
?>
 	         typeof uname === 'undefined' || $('#VPNname').val(uname);
                 typeof pass === 'undefined'  || $('#VPNpassword').val(pass);		

		 // var conf=E('conf');
		 // var leng=(conf.value.match(/\n/g)||'').length;
		 // conf.style.height=(leng<15?'15':leng)+'em';
		}

		function toggleLog(){
		 if(logon=!logon){ 
		 	que.drop('php/ovpn.php', setLog, 'act=log'); 
		 }
		 E('logButton').value = (logon?'Hide':'Show') + " Log";
		 E('response').className = (logon?'tall':'hiddenChildMenu');
		 $('#editButton').toggle();
		}

		function load(){
		var ovpnfile='<?php $filename=exec('uci get openvpn.sabai.filename'); echo $filename; ?>';
		document.getElementById('ovpn_file').innerHTML = ovpnfile;
		E('ovpn_file').innerHTML = 'Current File: ' + ovpnfile;
-		 msg('Please supply a .conf/.ovpn configuration file.');
		}

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

			if (info.vpn.status == "Connected" && info.vpn.type == 'OpenVPN') {
				E('clear').hidden = true;
	    		} else {
				E('clear').hidden = false;
			}
		}

		function getUpdate(ipref){ 
			que.drop('php/info.php',setUpdate,ipref?'do=ip':null); 
	   $.get('php/get_remote_ip.php', function( data ) {
	     donde = $.parseJSON(data);
	     console.log(donde);
	     for(i in donde) E('loc'+i).innerHTML = donde[i];
	   });
		}

		function OVPNresp(res){ 
			eval(res); 
			msg(res.msg); 
			showUi(); 
			if(res.reload){ 
				window.location.reload(); 
			}; 
			if(res.sabai){ 
				limit=10; getUpdate(); 
			} 
		}

		function OVPNsave(act){ 
			hideUi("Adjusting OpenVPN..."); 
			E("_act").value=act;
			if (act=='start') {
				if (info.vpn.type == 'PPTP') {
					hideUi("PPTP will be stopped.");
					$.post('php/pptp.php', {'switch': 'stop'}, function(res){
						if(res!=""){
							eval(res);
							hideUi(res.msg);
							OVPNcall();
						}
					});
				} else if (info.vpn.type == 'TOR') {
					hideUi("TOR will be stopped.");
					$.post('php/tor.php', {'switch': 'off'}, function(res){
						if(res!=""){
							eval(res);
							hideUi(res.msg);
							OVPNcall();
						}
					});
				} else {
					OVPNcall();
				}
			} else {
				$.post("php/ovpn.php", $("#fe").serialize(), function(res){
					if(res!=""){
						OVPNresp(res);
					}
					showUi();
				});  
			}
		}

		function OVPNcall(){
			$.post("php/ovpn.php", $("#fe").serialize(), function(res){
				if(res!=""){
					eval(res);
					hideUi(res.msg);
					setTimeout(function(){hideUi("Checking OVPN status...")},5000);
					setTimeout(check,10000);
				}
			});
		}

		
		function init(){ 
			f = E('fe'); 
			hidden = E('hideme'); 
			hide = E('hiddentext'); 
			load(); 
	   getUpdate();
	   setInterval (getUpdate, 5000); 
	}

		function check(){
			E("_act").value='check';
			$.post('php/ovpn.php', $("#fe").serialize(), function(res){
				if(res.indexOf("not start") < 0){
					OVPNresp(res);
					showUi();
				} else {
					if (ovpnTry < 3) {
						setTimeout(check,10000);
						ovpnTry++;
					} else {
						OVPNresp(res);
						showUi();
					}
				}
			});
		}

	</script>
<div class='pageTitle'>VPN: OpenVPN Client</div>
<div class='controlBox'><span class='controlBoxTitle'>OpenVPN Settings</span>
	<div class='controlBoxContent'>
<body onload='init();' id='topmost'>
<form id='newfile' method='post' action='php/ovpn.php' encType='multipart/form-data'>
						<input type='hidden' name='act' value='newfile'>

						<span id='ovpn_file'></span>
						<p>
						<span id='upload'>
						<input type='file' id='file' name='file'>
						<input type='button' value='Upload' onclick='submit()'></span>
						</p>
						<p>
						<span id='messages'>&nbsp;</span>
						</p>
					</form>
<form id='fe'>
							<span id='ovpn_controls'>
							<input type='hidden' id='_act' name='act' value=''>
							<input type='button' value='Start' onclick='OVPNsave("start");'>
							<input type='button' value='Stop' onclick='OVPNsave("stop");'>
							<input id='clear' type='button' value='Clear' onclick='OVPNsave("clear");'></span>
							<input type='button' value='Show Log' id='logButton' onclick='toggleLog();'>
							<input type='button' value='Edit Config' id='editButton' onclick='toggleEdit();'>
						</div>
							
						<textarea id='response' class='hiddenChildMenu'></textarea>
						<div id='edit' class='hiddenChildMenu'>
						 <table>
						 	<tr><td>Name: </td><td><input type='text' name='VPNname' id='VPNname' placeholder='(optional)'></td></tr>
						 	<tr><td>Password:</td><td><input type='text' name='VPNpassword' id='VPNpassword' placeholder='(optional)'></td></tr>
						 </table>
						 
						 <br>
						 <textarea id='conf' class='tall' name='conf'>
						 	<?php readfile('/etc/sabai/openvpn/ovpn.current'); ?>
						 </textarea> <br>
						 <input type='button' value='Save' onclick='saveEdit();'>
						 <input type='button' value='Cancel' onclick='window.location.reload();'>
						</div>
                </tbody>
            </table>
        </div>
        </form>
    <div id='hideme'>
        <div class='centercolumncontainer'>
            <div class='middlecontainer'>
                <div id='hiddentext'>Please wait...</div>
                <br>
            </div>
        </div>
    </div>
    <p>
        <div id='footer'>Copyright © 2016 Sabai Technology, LLC</div>
    </p>
</body>
