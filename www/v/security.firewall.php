<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=security&section=firewall";
	header( "Location: $url" );     
}
?>
<!--  TODO:
-->
<form id="fe">
<div class='pageTitle'>Security: Firewall</div>
<input type='hidden' id='act' name='act'>
<div class='controlBox'><span class='controlBoxTitle'>Firewall</span>
	<div class='controlBoxContent'>
		<table>
			<tr><td>Respond to ICMP ping</td>
				<td><input type="checkbox" id="respondToggle" name='respondToggle' class="slideToggle" />
					 <label class="slideToggleViewport" for="respondToggle">
					 <div class="slideToggleSlider">
					   <div class="slideToggleButton slideToggleButtonBackground">&nbsp;</div>
					   <div class="slideToggleContent slideToggleLeft button buttonSelected"><span>On</span></div>
					   <div class="slideToggleContent slideToggleRight button"><span>Off</span></div>
					  </div>
					 </label>
				</td>
			</tr>
			<tr><td>Allow multicast</td>
				<td><input type="checkbox" id="multicastToggle" name='multicastToggle' class="slideToggle" />
				 	<label class="slideToggleViewport" for="multicastToggle">
					 <div class="slideToggleSlider">
					   <div class="slideToggleButton slideToggleButtonBackground">&nbsp;</div>
					   <div class="slideToggleContent slideToggleLeft button buttonSelected"><span>On</span></div>
					   <div class="slideToggleContent slideToggleRight button"><span>Off</span></div>
					  </div>
					</label>
				</td>
			</tr>
			<tr><td>Enable SYN cookies</td>
				<td><input type="checkbox" id="synToggle" name='synToggle' class="slideToggle" /> 
					<label class="slideToggleViewport" for="synToggle">
					 <div class="slideToggleSlider">
					   <div class="slideToggleButton slideToggleButtonBackground">&nbsp;</div>
					   <div class="slideToggleContent slideToggleLeft button buttonSelected"><span>On</span></div>
					   <div class="slideToggleContent slideToggleRight button"><span>Off</span></div>
					  </div>
					 </label>
				</td>
			</tr>
			<tr><td>Enable WAN access to router</td>
				<td><input type="checkbox" id="wanToggle" name='wanToggle' class="slideToggle" /> 
					<label class="slideToggleViewport" for="wanToggle">
					 <div class="slideToggleSlider">
					   <div class="slideToggleButton slideToggleButtonBackground">&nbsp;</div>
					   <div class="slideToggleContent slideToggleLeft button buttonSelected"><span>On</span></div>
					   <div class="slideToggleContent slideToggleRight button"><span>Off</span></div>
					  </div>
					 </label>
				</td>
			</tr>
		</table>
    <div id='hideme'>
        <div class='centercolumncontainer'>
            <div class='middlecontainer'>
                <div id='hiddentext' value-'Please wait...' ></div>
                <br>
            </div>
        </div>
    </div>
    </div>
</div>
<input type='button' value='Save' onclick='FIREcall()'><span id='messages'>&nbsp;</span>
<p>
        <div id='footer'>Copyright © 2016 Sabai Technology, LLC</div>
</p>
</form>

<script>
var hidden, hide;
var f = E('fe'); 
var hidden = E('hideme'); 
var hide = E('hiddentext');

var firewall=$.parseJSON('{<?php
          $icmp=exec("uci get sabai.firewall.icmp");
          $multicast=trim(exec("uci get sabai.firewall.multicast"));
          $cookies=trim(exec("uci get sabai.firewall.cookies"));
          $wanroute=trim(exec("uci get sabai.firewall.wanroute"));
          echo "\"icmp\": \"$icmp\",\"multicast\": \"$multicast\",\"cookies\": \"$cookies\",\"wanroute\": \"$wanroute\"";
      ?>}');

function FIREcall(){ 
	hideUi("Adjusting Firewall settings..."); 
// Pass the form values to the php file 
	$.post('php/firewall.php', $("#fe").serialize(), function(res){
// Detect if values have been passed back   
    if(res!=""){
      FIREresp(res);
    };
      showUi();
});
// Important stops the page refreshing
	return false;
} 


function FIREresp(res){ 
  eval(res); 
  msg(res.msg); 
  showUi(); 
  } 

	$('#respondToggle').prop({'checked': firewall.icmp});
	$('#multicastToggle').prop({'checked': firewall.multicast});
	$('#synToggle').prop({'checked': firewall.cookies});
	$('#wanToggle').prop({'checked':firewall.wanroute});

</script>
