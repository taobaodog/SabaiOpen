<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=vpn&section=tor";
	header( "Location: $url" );     
}
?>
<!DOCTYPE html>
<html>
<!--Sabai Technology - Apache v2 licence
    Copyright 2016 Sabai Technology -->
<div class='pageTitle'>VPN: Tor - Anonymity Online</div>
<form id="fe">
<input type='hidden' id='form_tor' name='form_tor' value='tor'>
<div class='controlBox'><span class='controlBoxTitle'>Tor Settings</span>
	<div class='controlBoxContent' id='tor_setup_wl'>
	</div>
	<div class='controlBoxContent' id='tor_wl_config'>
	</div>
	<div class='controlBoxContent'><input type='button' value='Save' onclick='TORcall("#fe")'><span id='messages'>&nbsp;</span></div>
    <div id='hideme'>
        <div class='centercolumncontainer'>
            <div class='middlecontainer'>
                <div id='hiddentext'>Please wait...</div>
                <br>
            </div>
        </div>
    </div>
<table>
	<td><div id='torWarn'>Using Tor protects you against a common form of Internet surveillance known as "traffic analysis." Traffic analysis can be used to infer who is talking to whom over a public network. Knowing the source and destination of your Internet traffic allows others to track your behavior and interests.  This TOR client is provided to give network access to TOR for devices which may not have the ability to run TOR locally.  The TOR organization recommends that due to the various methods of tracking traffic, the best way to remain fully anonymous on a computer is through use of the TOR Browser.</div></br><br><br>
	<div id='torUse'>Turn on TOR by choosing "Tunnel" and push "Save". It is possible to access TOR feature on proxy port 8080 or by setting accelerator as a gateway on the router.</div>
	</td>
</div>
</table>
    <p>
        <div id='footer'>Copyright © 2016 Sabai Technology, LLC</div>
 	</p>
</form>


<script type='text/javascript'>
var hidden, hide, pForm = {};

var f = E('fe'); 
var hidden = E('hideme'); 
var hide = E('hiddentext');

var tor=$.parseJSON('{<?php
        $ssid=trim(exec("uci get sabai.wlradio0.ssid"));
        $ip=trim(exec("uci get sabai.tor.ipaddr"));
        $netmask=trim(exec("uci get sabai.tor.netmask"));
        $network=trim(exec("uci get sabai.tor.network"));
        $mode=trim(exec("uci get sabai.tor.mode"));
        echo "\"ip\": \"$ip\",\"ssid\": \"$ssid\",\"network\": \"$network\", \"netmask\": \"$netmask\", \"mode\": \"$mode\"";
    ?>}');


 function TORcall(torForm){ 
 	hideUi("Adjusting TOR settings...");
 	if (E("tor_mode").value == "tun") {
 		if (info.vpn.type == 'OpenVPN') {
			hideUi("OpenVPN will be stopped.");
			$.post("php/ovpn.php", {'switch': 'stop'}, function(res){
				if(res!=""){
					eval(res);
					hideUi(res.msg)
				}
			});
 		} else if (info.vpn.type == 'PPTP') {
			hideUi("PPTP will be stopped.");
			$.post('php/pptp.php', {'switch': 'stop'}, function(res){
				if(res!=""){
					eval(res);
					hideUi(res.msg);
				}
			});
 		} else {
 			hideUi("TOR tunnel will be started.");
 		}
 		setTimeout(function(){TORstart(torForm)},7000);
 	} else if (E("tor_mode").value == "proxy") {
 		hideUi("TOR proxy will be started.");
 		TORstart(torForm);
 	} else {
 		TORstart(torForm);
 	}
 	return false;
 };

function TORstart(torForm){
	$.post('php/tor.php', $(torForm).serialize(), function(res){
  	  // Detect if values have been passed back   
  	    if(res!=""){
  	      TORresp(res);
  	    }
  	      showUi();
  	});
}

 
 function TORresp(res){ 
 	eval(res); 
    msg(res.msg); 
    showUi(); 
    if(res.sabai){ 
    	limit=10; 
    	getUpdate(); 
    }
}



$.widget("jai.tor_setup_wl", {
	_create: function(){

		$(this.element)
		.append( $(document.createElement('table')).addClass("controlTable smallwidth")
	      .append( $(document.createElement('tbody')) 
	        
	        .append( $(document.createElement('tr'))
	          .append( $(document.createElement('td')).html('Mode') 
	          )
	          .append( $(document.createElement('td') ) 
	            .append(
	              $(document.createElement('select'))
	                .prop("id","tor_mode")
	                .prop("name","tor_mode")
	                .prop("class", "radioSwitchElement")
	              .append( $(document.createElement('option'))
	                .prop("value", "off")
	                .prop("text", 'Off')
	              )
	              .append( $(document.createElement('option'))
	                .prop("value", "proxy")
	                .prop("text", 'Proxy')
	              )
	              .append( $(document.createElement('option'))
	                .prop("value", "tun")
	                .prop("text", 'Tunnel')
	              )
	            )
	          )
	        ) // end mode tr

	      ) // end WPA tbody
	    ) // end lower table

	    $('#tor_mode').radioswitch({ 
			value: tor.mode
		});

		this._super();
	},
});

$.widget("jai.tor_wl_config", {
	_create: function(){

		$(this.element)
		.append( $(document.createElement('table')).addClass("controlTable smallwidth")
	      .append( $(document.createElement('tbody'))
	        .append( $(document.createElement('tr'))
	                .append( $(document.createElement('td')).html('SSID') 
	                )
	                .append( $(document.createElement('td') ) 
	                  .append(
	                    $(document.createElement('input'))
	                      .prop("id","tor_ssid")
	                      .prop("name","tor_ssid")
	                  )
	                )
	              ) // end SSID tr

	         .append( $(document.createElement('tr'))
				.append( $(document.createElement('td')).html('TOR Wireless IP')
						)
	  	                .append( $(document.createElement('td') ) 
	  	                  .append(
	  	                    $(document.createElement('input'))
	  	                      .prop("id","tor_nw_ip")
	  	                      .prop("name","tor_nw_ip")
	  	                      .prop("type","text")
	  	                  )
	  	                )
	  	              ) // end ip tr

	  	            .append( $(document.createElement('tr'))
	  	  				.append( $(document.createElement('td')).html('TOR Network Mask')
	  	  	  	                )
	  	  	  	                .append( $(document.createElement('td') ) 
	  	  	  	                  .append(
	  	  	  	                    $(document.createElement('input'))
	  	  	  	                      .prop("id","tor_nw_mask")
	  	  	  	                      .prop("name","tor_nw_mask")
	  	  	  	                      .prop("type","text")
	  	  	  	                    )
	  	  	  	                )
	  	  	  	              ) // end ip tr


	  	  	  	        .append( $(document.createElement('tr'))
	  		  	  				.append( $(document.createElement('td')).html('TOR Network IP') 
	  		  	  	  	                )
	  		  	  	  	                .append( $(document.createElement('td') ) 
	  		  	  	  	                  .append(
	  		  	  	  	                    $(document.createElement('input'))
	  		  	  	  	                      .prop("id","tor_server")
	  		  	  	  	                      .prop("name","tor_server")
	  		  	  	  	                      .prop("type","text")
	  		  	  	  	                      	  		  	  	  	                  )
	  		  	  	  	                )
	  		  	  	  	              ) // end ip tr
	      ) // end WPA tbody
	    ) // end lower table

	    $('#tor_ssid').val(tor.ssid);
		$('#tor_nw_ip').ipspinner().ipspinner('value', tor.ip);//tor.gateway);
		$('#tor_nw_mask').maskspinner().maskspinner('value', tor.netmask);//tor.mask);
		$('#tor_server').ipspinner().ipspinner('value', tor.network);//tor.server);


		this._super();
	},
});

$(function(){
	  //instatiate widgets on document ready
	  $('#tor_setup_wl').tor_setup_wl({ conf: 'tor'});
	  $('#tor_wl_config').tor_wl_config({ conf: 'tor'});
	  $('#tor_wl_config').hide();
	})

</script>

