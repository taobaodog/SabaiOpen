<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=vpn&section=pptpclient";
	header( "Location: $url" );     
}
?>
<!DOCTYPE html>
<html>
<!--Sabai Technology - Apache v2 licence
    Copyright 2016 Sabai Technology -->

<form id="fe">
<div class='pageTitle'>VPN: PPTP Client</div>
<div class='controlBox'><span class='controlBoxTitle'>PPTP Settings</span>
    <div class='controlBoxContent'>
        <body onload='init();' id='topmost'>
        <input type='hidden' id='act' name='act'>
 
            <table class="fields">
                <tbody>
                    <tr>
                        <td class="title indent1 shortWidth">Server</td>
                        <td class="content">
                            <input name="server" id="server" class='longinput' type="text">
                        </td>
                    </tr>
                    <tr>
                        <td class="title indent1 shortWidth">Username</td>
                        <td class="content">
                            <input name="user" id="user" class='longinput' type="text">
                        </td>
                    </tr>
                    <tr>
                        <td class="title indent1 shortWidth">Password</td>
                        <td class="content">
                            <input name="pass" id="pass" class='longinput' autocomplete="off" onfocus='peekaboo("pass")' onblur='peekaboo("pass")' type="password">
                        </td>
                    </tr>
                    <tr>
                        <td class="title indent1 shortWidth"> MPPE-128 </td>
                        <td class="content">
                            <div class='radioSwitchElement' id='mppe_conf'></div>   
                        </td>
                    </tr>
                </tbody>
            </table>
            <input id='start' type='button' class='firstButton' value='Start' onclick='PPTPcall("start")'>
            <input id='stop' type='button' value='Stop' onclick='PPTPcall("stop")'>
            <input id='save' type='button' value='Save' onclick='PPTPcall("save")'>
            <input id='clear' type='button' value='Clear' onclick='PPTPcall("clear")'>
            <span id='messages'>&nbsp;</span>
    </div>
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

<script type='text/javascript'>
    var hidden, hide, f,oldip='',limit=10,info=null,ini=false;
    var pptpTry = 0;
    pptp = {<?php
        $user=trim(exec("uci get sabai.vpn.username"));
        $pass=trim(exec("uci get sabai.vpn.password"));
        $server=trim(exec("uci get sabai.vpn.server"));
        $mppe=trim(exec("uci get sabai.vpn.mppe_mode"));
        if( $user!="" ) echo "\n\tuser: '". $user ."',\n\tpass: '". $pass ."',\n\tserver: '". $server ."',\n\tmppe: '". $mppe ."'\n";
        else echo " user: '', pass: '', server: '', mppe: '' ";
    ?>}

$.widget("jai.mppe", {
    _create: function(){
        $(this.element)
            .append(
                $(document.createElement('select'))
                    .prop("id","mppe")
                    .prop("name","mppe")
                    .prop("class", "radioSwitchElement")
                .append( $(document.createElement('option'))
                    .prop("value", "stateless")
                    .prop("text", 'Stateless')
                )
                .append( $(document.createElement('option'))
                    .prop("value", "nomppe")
                    .prop("text", 'No mppe')
                )
            )

    $('#mppe').radioswitch({ value: pptp.mppe, hasChildren: true });
},
});



function setUpdate(res){
    if(info) oldip = info.vpn.ip; 
    eval(res); 
    for(i in info.vpn){ 
        E('vpn'+i).innerHTML = info.vpn[i]; 
    }
    if (info.vpn.status == "Connected" && info.vpn.type == 'PPTP') {
        E('clear').hidden = true;;
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
	hideUi("Adjusting PPTP settings..."); 
	E("act").value=act;
	// Pass the form values to the php file
	if (act=='start') {
		if (info.vpn.type == 'OpenVPN') {
			hideUi("OpenVPN will be stopped.");
			$.post("php/ovpn.php", {'switch': 'stop'}, function(res){
				if(res!=""){
					eval(res);
					hideUi(res.msg);
					PPTPstart();
				}
			});
		  } else if (info.vpn.type == 'TOR') {
			hideUi("TOR will be stopped, but TOR proxy will keep working.");
			$.post('php/tor.php', {'switch': 'proxy'}, function(res){
				if(res!=""){
					eval(res);
					hideUi(res.msg);
					PPTPstart();
				}
			}); 
		} else {
			PPTPstart();
		}
	} else {
		$.post('php/pptp.php', $("#fe").serialize(), function(res){
			if(res!=""){
				PPTPresp(res);
			}
			showUi();
		});
		if(act =='clear'){
			setTimeout("window.location.reload()",5000);
		}
	}
 
// Important stops the page refreshing
return false;

}; 

function PPTPstart(){
	$.post('php/pptp.php', $("#fe").serialize(), function(res){
		// Detect if values have been passed back   
		if(res!=""){
			eval(res);
			hideUi(res.msg);
			setTimeout(function(){hideUi("Checking PPTP status...")},10000);
			setTimeout(check,10000);
		}
	});
}

function check(){
	$.post('php/pptp.php',{'check': 'status'}, function(res){
		if(res.indexOf("disconnected") < 0){
			PPTPresp(res);
			showUi();
		} else {
			if (pptpTry < 3) {
				setTimeout(check,10000);
				pptpTry++;
			} else {
				PPTPresp(res);
				showUi();
			}
		}
	});
}
$(function(){
    $('#mppe_conf').mppe({ conf: pptp });
})

function init(){ 
    f = E('fe'); 
    hidden = E('hideme'); 
    hide = E('hiddentext'); 
    for(var i in pptp){ 
        E(i).value = pptp[i]; 
    }; 
                <?php if (file_exists('/etc/sabai/stat/ip') && file_get_contents("/etc/sabai/stat/ip") != '') {
       echo "donde = $.parseJSON('" . strstr(file_get_contents("/etc/sabai/stat/ip"), "{") . "');\n";
       echo "for(i in donde){E('loc'+i).innerHTML = donde[i];}"; } ?>
       getUpdate();
       setInterval (getUpdate, 5000)
       
}
  
</script>

