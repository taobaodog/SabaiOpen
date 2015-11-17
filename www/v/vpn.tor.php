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
				.append( $(document.createElement('td')).html('TOR Network IP') 
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
	  		  	  				.append( $(document.createElement('td')).html('TOR Server IP') 
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

	    $('#tor_mode').radioswitch({ 
			value: 'off'
		});

		$('#tor_ssid').val();
		$('#tor_nw_ip').ipspinner().ipspinner('value', '20.0.0.1');//tor.gateway);
		$('#tor_nw_mask').maskspinner().maskspinner('value','255.255.255.0');//tor.mask);
		$('#tor_server').ipspinner().ipspinner('value','10.192.0.0');//tor.server);

		this._super();
	},
});

$(function(){
	  //instatiate widgets on document ready
	  $('#tor_setup_wl').tor_setup_wl({ conf: 'tor'});
	})

</script>

