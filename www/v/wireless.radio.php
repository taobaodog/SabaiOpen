<form id="fe">
<div class='pageTitle'>Wireless: Radio</div>
<!--	TODO: align td widths-->

<div class='controlBox'><span class='controlBoxTitle'>WL0</span>
  <div class='controlBoxContent' id='wl_wl0'>
  </div>
</div>
<input type='button' value='Save' onclick='WLcall()'><span id='messages'>&nbsp;</span>
    <div id='hideme'>
        <div class='centercolumncontainer'>
            <div class='middlecontainer'>
                <div id='hiddentext'>Please wait...</div>
                <br>
            </div>
        </div>
    </div>
    </div>
    <p>
        <div id='footer'>Copyright © 2014 Sabai Technology, LLC</div>
</p>
</form>

<script type='text/ecmascript'>

var pForm = {}
var hidden, hide;
var f = E('fe'); 
var hidden = E('hideme'); 
var hide = E('hiddentext');

var wl0=$.parseJSON('{<?php
          $mode=exec("uci get sabai.wlradio0.mode");
          $ssid=trim(exec("uci get sabai.wlradio0.ssid"));
          $encryption=trim(exec("uci get sabai.wlradio0.encryption"));
          $wpa_type=trim(exec("uci get sabai.wlradio0.wpa_type"));
          $wpa_encryption=trim(exec("uci get sabai.wlradio0.wpa_encryption"));
          $wpa_psk=trim(exec("uci get sabai.wlradio0.wpa_psk"));
          $wpa_rekey=trim(exec("uci get sabai.wlradio0.wpa_rekey"));      
          echo "\"mode\": \"$mode\",\"ssid\": \"$ssid\",\"encryption\": \"$encryption\",\"wpa_type\": \"$wpa_type\",\"wpa_encryption\": \"$wpa_encryption\",\"wpa_psk\": \"$wpa_psk\",\"wpa_rekey\": \"$wpa_rekey\"";
      ?>}');
var wl0_wepkeyraw='<?php
          $servers=exec("uci get sabai.wlradio0.wepkeys");
          echo "$servers"; 
          ?>';         
var wl0_array = JSON.stringify(wl0_wepkeyraw.split(" "));
var wl0_wepkeyfin= "{\"keys\"" + ":" + wl0_array + "}";
var wl0_wepkey = $.parseJSON(wl0_wepkeyfin);

$('#wl_mode').val(wl0.mode);   
$('#wl_ssid').val(wl0.ssid); 
$('#wl_encryption').val(wl0.encryption); 
$('#wl_wpa_type').val(wl0.wpa_type); 
$('#wl_wpa_encryption').val(wl0.wpa_encryption); 
$('#wl_wpa_psk').val(wl0.wpa_psk);  
$('#wl_wpa_rekey').val(wl0.wpa_rekey);  

function WLcall(){ 
  hideUi("Adjusting Wireless settings..."); 
$(document).ready( function(){
// Pass the form values to the php file 
$.post('php/wl.php', $("#fe").serialize(), function(res){
  // Detect if values have been passed back   
    if(res!=""){
      WLresp(res);
    }
      showUi();
});
 
// Important stops the page refreshing
return false;

}); 

}

function WLresp(res){ 
  eval(res); 
  msg(res.msg); 
  showUi(); 
  if(res.sabai){ 
    limit=10; 
    getUpdate(); 
  } 
}

$.widget("jai.wl_wl0", {
    
  //Adding to the built-in widget constructor method - do this when widget is instantiated
  _create: function(){
    //TO DO: check to see if containing element has a unique id
    
    // BUILDING DOM ELEMENTS
    $(this.element)
    .append( $(document.createElement('table')).addClass("controlTable smallwidth")
      .append( $(document.createElement('tbody')) 
        
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Mode') 
          )
          .append( $(document.createElement('td') ) 
            .append(
              $(document.createElement('select'))
                .prop("id","wl_mode")
                .prop("name","wl_mode")
                .prop("class", "radioSwitchElement")
              .append( $(document.createElement('option'))
                .prop("value", "off")
                .prop("text", 'Off')
              )
              .append( $(document.createElement('option'))
                .prop("value", "ap")
                .prop("text", 'Wireless Server')
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
                .prop("id","wl_ssid")
                .prop("name","wl_ssid")
            )
          )
        ) // end SSID tr

        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Encryption') 
          )
          .append( $(document.createElement('td') ) 
            .append(
              $(document.createElement('select'))
                .prop("id","wl_encryption")
                .prop("name","wl_encryption")
                .prop("class", "radioSwitchElement")
              .append( $(document.createElement('option'))
                .prop("value", "none")
                .prop("text", 'None')
              )
              .append( $(document.createElement('option'))
                .prop("value", "wep")
                .prop("text", 'WEP')
              )
              .append( $(document.createElement('option'))
                .prop("value", "psk")
                .prop("text", 'WPA')
              )
              .append( $(document.createElement('option'))
                .prop("value", "psk2")
                .prop("text", 'WPA2')
              )
              .append( $(document.createElement('option'))
                .prop("value", "mixed-psk")
                .prop("text", 'WPA/WPA2')
              )
            )
          )
        ) // end ssid tr
      ) // end first tbody
    ) // end table

    // LOWER TABLE, DEPENDS ON SECURITY SELECTION
    //wep table body
    .append( $(document.createElement('table')).addClass("controlTable indented")
      .append( $(document.createElement('tbody')).addClass("wl_encryption wl_encryption-wep") 
        
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('WEP Keys') 
          )
          .append( $(document.createElement('td') ) 
            .append(
              $(document.createElement('ul')).prop("id","wl_wep_keys")
            )
          )
        ) // end WEP keys tr
      ) // end WEP tbody

      //wpa tbody
      .append( $(document.createElement('tbody'))
        .addClass("wl_encryption wl_encryption-psk wl_encryption-psk2 wl_encryption-mixed-psk") 
        
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('&nbsp') 
          )
          .append( $(document.createElement('td')).html('&nbsp') 
          )
        ) // end empty tr



        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('WPA Encryption') 
          )
          .append( $(document.createElement('td') ) 
            .append(
              $(document.createElement('select'))
                .prop("id","wl_wpa_encryption")
                .prop("name","wl_wpa_encryption")
                .prop("class", "radioSwitchElement")
              .append( $(document.createElement('option'))
                .prop("value", "aes")
                .prop("text", 'AES')
              )
              .append( $(document.createElement('option'))
                .prop("value", "tkip")
                .prop("text", 'TKIP')
              )
              .append( $(document.createElement('option'))
                .prop("value", "tkip+aes")
                .prop("text", 'AES/TKIP')
              )
            )
          )
        ) // end WPA Encryption tr

        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('PSK') 
          )
          .append( $(document.createElement('td') ) 
            .append(
              $(document.createElement('input'))
                .prop("id","wl_wpa_psk")
                .prop("name","wl_wpa_psk")
            )
          )
        ) // end PSK tr

        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Key Duration') 
          )
          .append( $(document.createElement('td') ) 
            .append(
              $(document.createElement('input'))
                .prop("id","wl_wpa_rekey")
                .prop("name","wl_wpa_rekey")
            )
          )
        ) // end PSK tr
      ) // end WPA tbody
    ) // end lower table


	$('#wl_encryption').change(function(){
		$('.wl_encryption').hide(); 
		$('.wl_encryption-'+ $('#wl_encryption').val() ).show(); 
	})

	$('#wl_mode').radioswitch({
		value: wl0.mode,
		change: function(event,ui){ 
			$('.wl_mode').hide(); 
			$('.wl_mode-'+ wl0.encryption ).show(); 
		}
	});

	$('#wl_ssid').val(wl0.ssid);

	$('#wl_encryption').radioswitch({
		value: wl0.encryption
	});

	$('#wl_wpa_type').radioswitch({
	 value: wl0.wpa_type
	});

	$('#wl_wpa_encryption').radioswitch({
	 value: wl0.wpa_encryption
	});

	$('#wl_wpa_psk').val(wl0.wpa_psk);

	//$('#wl_wpa_rekey').val(wl[0].wpa.rekey);

	$('#wl_wpa_rekey').spinner({ min: 0, max: 525600 }).spinner('value',wl0.wpa_rekey);

	$('#wl_wep_keys').oldeditablelist({ list: wl0_wepkey.keys, fixed: true });

    
    this._super();
  },

  //global save method
  saveWL0: function(){  

    //   $('#save').click( function() {
  //     var rawForm = $('#fe').serializeArray()
  //     var pForm = {}
  //     for(var i in rawForm){
  //       pForm[ rawForm[i].name ] = rawForm[i].value;
  //     }
  //     // if(!pForm['dhcp_on']) pForm['dhcp_on'] = 'off'
  // //    $('#testing').html( JSON.stringify(pForm) )
  //     toServer(pForm, 'save');
  //   }); 
  
    var rawForm = $('#wl_wl0 input').serializeArray();
    for(var i in rawForm){
      pForm[ rawForm[i].name ] = rawForm[i].value;
    }
    $('#testing').html( rawForm )
    console.log(pForm)
    return pForm;
 
  } //end save WL0
});

$(function(){
  //instatiate widgets on document ready
  $('#wl_wl0').wl_wl0({ conf: wl0 });
})

$('#save').click( function() {
  //FIGURE OUT HOW TO join pforms
  $('#wl_wl0').wl_wl0('saveWL0')
  toServer(pForm, 'save');
});  

//validate the fields
$( "#fe" ).validate({
  rules: {
    wl_ssid: {
      required: true,
    },
    wl_encryption: {
      required: true,
    },
    wl_wpa_psk : {
      required: true,
      minlength: 8,
      maxlength: 63
    },
    wl_wpa_rekey: {
      required: true,
      range: [600, 7200]
    }
  }
});

</script>
