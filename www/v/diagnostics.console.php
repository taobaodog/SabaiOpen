<!--Sabai Technology - Apache v2 licence
    copyright 2014 Sabai Technology -->
<script>
	var hidden, hide;

	function setLog(res){ 
	E('response').value = res; 
		}
	
	function execConsole(){ 
		hideUi("Executing..."); 
		que.drop("bin/console.php", setLog, $("#_fom").serialize() ); 
	}

</script>

<body>
<form id='_fom' method='post'>
	<input type='hidden' name='act' value='all'>
	<div class='pageTitle'>Diagnostics: Console</div>
<div class='controlBox'><span class='controlBoxTitle'>Execute System Commands</span>
  <div class='controlBoxContent' id='console' >
		<table id='container' cellspacing=0>
			<tr id='body'>
				<textarea id='shellbox' name='cmd'></textarea><br>
				<input type='button' value='Execute' onclick='execConsole();'><div id='whatPage' class='noshow'>shell</div>
							</tr>
						</tbody>
						</table>
						<br>
						<pre id='response'></pre>
					</div>
				</div>
			</td>
		</tr>
	</table>
	<div id='footer'> Copyright © 2014 Sabai Technology, LLC </div>
</form>
</body>
<div id='hideme'><div class='centercolumncontainer'><div class='middlecontainer'></div></div></div>

