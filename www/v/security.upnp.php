<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=security&section=upnp";
	header( "Location: $url" );     
}
?>
<form id="fe">
<div class='pageTitle'>Security: UPnP</div>

<div class='controlBox'><span class='controlBoxTitle'>Settings</span>
	<div class='controlBoxContent'><table><tbody>
		<tr><td>Enable UPnP</td>
			<td><input type="checkbox" id="enableToggle" name='enableToggle' class="slideToggle" />
				 <label class="slideToggleViewport" for="enableToggle">
				 <div class="slideToggleSlider">
				   <div class="slideToggleButton slideToggleButtonBackground">&nbsp;</div>
				   <div class="slideToggleContent slideToggleLeft button buttonSelected"><span>On</span></div>
				   <div class="slideToggleContent slideToggleRight button"><span>Off</span></div>
				  </div>
				 </label>
			</td>
		</tr>
		<tr><td>Enable NAT-PMP</td>
			<td><input type="checkbox" id="natpmpToggle" name='natpmpToggle' class="slideToggle" />
				 <label class="slideToggleViewport" for="natpmpToggle">
				 <div class="slideToggleSlider">
				   <div class="slideToggleButton slideToggleButtonBackground">&nbsp;</div>
				   <div class="slideToggleContent slideToggleLeft button buttonSelected"><span>On</span></div>
				   <div class="slideToggleContent slideToggleRight button"><span>Off</span>
				 </label></div>
				  </div>				 
			</td>
		</tr>
		<tr><td>Inactive Rules Cleaning</td>
			<td><input type="checkbox" id="cleanToggle" name='cleanToggle' class="slideToggle" />
			 	<label class="slideToggleViewport" for="cleanToggle">
				 <div class="slideToggleSlider">
				   <div class="slideToggleButton slideToggleButtonBackground">&nbsp;</div>
				   <div class="slideToggleContent slideToggleLeft button buttonSelected"><span>On</span></div>
				   <div class="slideToggleContent slideToggleRight button"><span>Off</span></div>
				  </div>
				</label>
			</td>
		</tr>
		<tr><td>Secure Mode</td>
			<td><input type="checkbox" id="secureToggle" name='secureToggle' class="slideToggle" /> 
				<label class="slideToggleViewport" for="secureToggle">
				 <div class="slideToggleSlider">
				   <div class="slideToggleButton slideToggleButtonBackground">&nbsp;</div>
				   <div class="slideToggleContent slideToggleLeft button buttonSelected"><span>On</span></div>
				   <div class="slideToggleContent slideToggleRight button"><span>Off</span></div>
				  </div>
				 </label>
			</td>
		</tr>
		<tr>
			<td> </td>
			<td><span class='xsmallText'>
				NAT-PMP requires UPnP to be on.</span>
			</td>
		</tr>
	</tbody></table></div>
</div>

<div class='controlBox'><span class='controlBoxTitle'>Allowed UPnP Ports*</span>
	<div class='controlBoxContent'>
		<table><tbody>
			<tr><td>Internal Ports</td><td><input id='intmin' name='intmin' class='shortinput'/> - <input id='intmax' name='intmax' class='shortinput'/>
			</tr>
			<tr>
				<td> </td>
				<td>
				<span class='xsmallText'>Valid port ranges are from 2 to 65535</span></td>
				</td>
			</tr>
			<tr><td><br> </td><td><br> </td></tr>
			<tr><td>External Ports</td><td><input id='extmin' name='extmin' class='shortinput'/> - <input id='extmax' name='extmax' class='shortinput'/>
			</tr>
			<tr>
				<td> </td>
				<td>
					<span class='xsmallText'>Setting lower bound to less than 1024 may interfere with network services</span>
				</td>
			</tr>
			<tr>
				<td> </td>
			</tr>
		</tbody></table>
		<br>
		<span class='xsmallText'> *UPnP clients will only be allowed to map ports in the external range to ports in the internal range</span>

	</div>
</div>
  <div class='controlBoxFooter'>
    <input type='button' class='btn btn-default' id='saveButton' value='Save' onclick='UPNPcall()'>
    <input type='button' class='btn btn-default' id='cancelButton' value='Cancel' onClick="window.location.reload()" disabled>
    <span id='messages'>&nbsp;</span>
  </div>
    <div id='hideme'>
        <div class='centercolumncontainer'>
            <div class='middlecontainer'>
                <div id='hiddentext'>Please wait...</div>
                <br>
            </div>
        </div>
    </div>
    </td></tr></td></tr></tbody></table></div>
    	<div id='footer'> Copyright © 2016 Sabai Technology, LLC </div>
	</div>
</form>
<script type='text/javascript'>

//Detecting different changes on page
//and displaying an alert if leaving/reloading 
//the page or pressing 'Cancel'.
var somethingChanged = false;

//Any manual change to inputs
$(document).on('change', 'input', function (e) {
    somethingChanged = true; 
    $("#cancelButton").removeAttr('disabled');
});

//Using keyboard up- or downarrow
$(document).on('keyup', 'input', function (e) {
  if(e.keyCode == 38 || e.keyCode == 40){
    somethingChanged = true; 
    $("#cancelButton").removeAttr('disabled');
    }
});

//Click on spinner arrows
$(document).on('click', '.ui-spinner-button', function (e) {
    somethingChanged = true; 
    $("#cancelButton").removeAttr('disabled');   
});

//Click on slide button
$(document).on('click', '.slideToggleButton', function (e) {
    somethingChanged = true; 
    $("#cancelButton").removeAttr('disabled');
});

//Click on slide background
$(document).on('click', '.slideToggleContent', function (e) {
    somethingChanged = true; 
    $("#cancelButton").removeAttr('disabled');
});


//Resetting cancelButton to disabled-state when saving changes
$(document).on('click', '#saveButton', function (e) {
    $("#cancelButton").prop('disabled', 'disabled');  
    somethingChanged = false; 
});

//If any changes is detected then display alert
$(window).bind('beforeunload',function(){
   if(somethingChanged){
   return "";
    }
});

var hidden, hide, pForm = {}; pForm2 = {}

var f = E('fe'); 
var hidden = E('hideme'); 
var hide = E('hiddentext');

var upnp=$.parseJSON('{<?php
          	$enable=exec("uci get sabai.upnp.enable");
          	$natpmp=exec("uci get sabai.upnp.natpmp");
			$clean=exec("uci get sabai.upnp.clean");
			$secure=exec("uci get sabai.upnp.secure");
			$intmin=exec("uci get sabai.upnp.intmin");
			$intmax=exec("uci get sabai.upnp.intmax");
			$extmin=exec("uci get sabai.upnp.extmin");
			$extmax=exec("uci get sabai.upnp.extmax");
        echo "\"enable\": \"$enable\",\"clean\": \"$clean\",\"secure\": \"$secure\",\"intmin\": \"$intmin\",\"intmax\": \"$intmax\",\"extmin\": \"$extmin\",\"extmax\": \"$extmax\"";
      ?>}');

	$('#enableToggle').prop({'checked': upnp.enable});
	$('#natpmpToggle').prop({'checked': upnp.enable});
	$('#cleanToggle').prop({'checked': upnp.clean});
	$('#secureToggle').prop({'checked': upnp.secure});

function UPNPcall(){ 
  hideUi("Adjusting UPNP settings..."); 
$(document).ready( function(){
// Pass the form values to the php file 
$.post('php/upnp.php', $("#fe").serialize(), function(res){
  // Detect if values have been passed back   
    if(res!=""){
      UPNPresp(res);
    }
      showUi();
});
 
// Important stops the page refreshing
return false;

}); 

}

function UPNPresp(res){ 
  eval(res); 
  msg(res.msg); 
  showUi(); 
  if(res.sabai){ 
    limit=10; 
    getUpdate(); 
  } 
}

//end of wm add

	$('#intmin').spinner({ min: 1024, max: 65534 }).spinner('value',upnp.intmin);
		$('#intmax').spinner({ min: 1025, max: 65535}).spinner('value',upnp.intmax);
		$('#extmin').spinner({ min: 1024, max: 65534 }).spinner('value',upnp.extmin);
		$('#extmax').spinner({ min: 1025, max: 65535 }).spinner('value',upnp.extmax);

	function changeRange(){
		if($('#advanced').is(':checked')){
			$('#intmin').spinner({ min: 2, max: 65534 });
			$('#intmax').spinner({ min: 3, max: 65535});
			$('#extmin').spinner({ min: 2, max: 65534 });
			$('#extmax').spinner({ min: 3, max: 65535 });
		} else {
			$('#intmin').spinner({ min: 1024, max: 65534 });
			$('#intmax').spinner({ min: 1025, max: 65535});
			$('#extmin').spinner({ min: 1024, max: 65534 });
			$('#extmax').spinner({ min: 1025, max: 65535 });
		}

	};

</script>
