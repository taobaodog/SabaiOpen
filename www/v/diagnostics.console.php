<form id="fe">
<div class='pageTitle'>Diagnostics: Console</div>
<div class='controlBox'><span class='controlBoxTitle'>Execute System Commands</span>
  <div class='controlBoxContent' id='console'>
  		<table class='tablemenu'>
			<tbody>
				<tr>
					<td>
					<textarea id='shellbox' name='cmd'></textarea><br>
					<div id='whatPage' class='noshow'>shell</div>
							</td>
							</tr>
			</tbody>
		</table>
            <input type='button' class='button' value='Execute' onclick='CONSOLEcall()'> <br>
            <span id='messages' class='response'></span>
        </div>
    <div id='hideme'>
        <div class='centercolumncontainer'>
            <div class='middlecontainer'>
                <div id='hiddentext'></div>
                <br>
            </div>
        </div>
    </div>
    <p>
        <div id='footer'>Copyright © 2015 Sabai Technology, LLC</div>
    </p>
</body>
</form>

<script type='text/javascript'>
	var logWindow, logForm, logSelect, hidden, hide;
	var hidden = E('hideme'); 
	var hide = E('hiddentext');

	function CONSOLEresp(res){ 
  		output=$.parseJSON(res);
  		str = output.replace(/\n/g, "<br>");
      str = "<br>"+str;
    	document.getElementById('messages').innerHTML=str;
}
	
	function CONSOLEcall(){ 
 // 		hideUi("Applying Commands..."); 
			$(document).ready( function(){
			hideUi("Processing commands...");
			// Pass the form values to the php file 
			$.post('php/console.php', $("#fe").serialize(), function(res){
  			// Detect if values have been passed back   
   			 if(res!=""){
      			CONSOLEresp(res);
    		}
      showUi();
});
 
// Important stops the page refreshing
return false;

}); 
}

</script>