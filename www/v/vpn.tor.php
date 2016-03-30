<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=vpn&section=tor";
	header( "Location: $url" );     
}
?>
<!DOCTYPE html>
<html>
<!--Sabai Technology - Apache v2 licence
    Copyright 2015 Sabai Technology -->
<div class='pageTitle'>VPN: Tor - Anonymity Online</div>
<form id="fe">
<input type='hidden' id='form_tor' name='form_tor' value='tor'>
<div class='controlBox'><span class='controlBoxTitle'>Tor Settings</span>
	<div class='controlBoxContent' id='tor_setup_wl'>
	</div>
	<div class='controlBoxContent' id='tor_wl_config'>
	</div>
</div>    
<input type='button' value='Save' onclick='TORcall("#fe")'><span id='messages'>&nbsp;</span>     
    <div id='hideme'>
        <div class='centercolumncontainer'>
            <div class='middlecontainer'>
                <div id='hiddentext'>Please wait...</div>
                <br>
            </div>
        </div>
    </div>
    <p>
        <div id='footer'>Copyright © 2015 Sabai Technology, LLC</div>
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
 	hideUi("Adjusting Wireless settings..."); 
    $(document).ready( function(){
    	// Pass the form values to the php file 
    	$.post('php/tor.php', $(torForm).serialize(), function(res){
    	  // Detect if values have been passed back   
    	    if(res!=""){
    	      TORresp(res);
    	    }
    	      showUi();
    	});
    	// Important stops the page refreshing
    	return false;

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
	                .prop("value", "ap")
	                .prop("text", 'Wireless Server')
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
})

</script>

