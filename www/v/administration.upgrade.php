<form id='fe' method="post" enctype="multipart/form-data">
<input type='hidden' name='version' id='_version'>
<input type='hidden' id='act' name='act'>
<div class='pageTitle'>Settings</div>
<div class='controlBox'><span class='controlBoxTitle'>SabaiOpen Update</span>
 <div class='controlBoxContent'>
    <div>Current Version: <span id='cversion'></span></div><br>
    <div id='newversion' class='hiddenChildMenu'>New Version: <span id='available'></span></div><br>
    <span class='uploadButton'><font style="font-size:14px"> Browse for Update</font></span>
    <input id='browse' name='_browse' type='file' onchange='fileInput(this)'/><t>
    <input id='fileName' name='_fileName' type='text'>
    <input id='download' type='button' name='submit' value='Download'/><br><br>
    <input type='button' id='upgrade' value='Run Update' onclick="Upgrade('upgrading');"/><br>
        <div id='hideme'>
            <div class='centercolumncontainer'>
                <div class='middlecontainer'>
                    <div id='hiddentext'>Please wait...</div>
                    <br>
                </div>
            </div>
        </div><br>
  </div>
</div>
<div class='controlBox'><span class='controlBoxTitle'>Firmware Configuration</span>
  <div class='controlBoxContent'>
    <div>Available user configurations: <span id='config'></span></div><br>
    <div class='radioSwitchElement' id='configList'></div><br>
    <input id='restore' name='Restore' type='button' hidden='true' value='Restore'/>
    <input id='backUp' name='backUp_config' type='button' value='Backup'/>
    <span id='aMsg' style="color:blue" ></span></br>
  </div>
</div>

    <p>
    <div id='footer'>Copyright © 2014 Sabai Technology, LLC</div>
    </p>
</form>

<script type='text/javascript'>

var hidden, hide, pForm = {};
var hidden = E('hideme');
var hide = E('hiddentext');

var list = $.parseJSON('{<?php $config = exec("sh /www/bin/config_search.sh");
			       echo $config;?>}');

var version = '<?php $get_version=exec("uci get sabai.general.version");
		     echo $get_version; ?>';

E('cversion').innerHTML = version;

E('fileName').value = '';
E('browse').value = '';
E('aMsg').innerHTML = ' * Sabai - is the currently running configuration.';

// jQuery uploadbutton implementation
$('.uploadButton').bind("click" , function () {
        $('#browse').click();
});
// View the file`s name
function fileInput(obj){
	var browseFile = obj.value;
        E('fileName').value = browseFile;
}

$('#backUp').on("click", function() {
	if (selectOption == '') {
		hideUi("Please, select the configuration.");
		setTimeout(function(){showUi()},3000);
	} else {
	       	var backUpName = prompt("Please enter new user config name.");
		if (backUpName.trim() == null) {
        	        hideUi("Backup wasn`t done.");
                              setTimeout(function(){showUi()},3000);
                        } else {
				$.post('php/backUp.php', {'newName': backUpName})
					.done(function(data) {
						if (data.trim() == "no name") {
							hideUi("Backup wasn`t done. The name is incorrect.")
						} else {
							hideUi(data);
						}
                       				setTimeout(function(){showUi()},3000);
						setTimeout(function(){location.reload()},3100);
					})
					.fail(function(data) {
						hideUi(data);
                              			setTimeout(function(){showUi()},3000);
					})
                      	}
	}
});
$('#restore').on("click", function() {
	var selectOption = $("#configs").find(":selected").text();
	hideUi("Restoring in process ...");
	$.post('php/restore.php', {'restoreName': selectOption})
		.done(function(data) {
			setTimeout(function(){hideUi("Restored configuration settings from backup file.")},3000);
			setTimeout(function(){showUi()},7000);
			setTimeout(function(){location.reload()},7100);
		})
		.fail(function(data) {
			setTimeout(function(){hideUi(data)},3000);
			setTimeout(function(){showUi()},4500);
		}) 

});


$(document).ready( function() {
$("#fe").submit(function() { return false; });
$("#download").on("click", function(){
		hideUi("Downloading ...");
		E("act").value='download';

                var form = document.forms.fe;
                var formData = new FormData(form);

                var xhr = new XMLHttpRequest();
                xhr.open("POST", "php/download.php");

                xhr.onreadystatechange = function() {
                        if (xhr.readyState == 4) {
                                if(xhr.status == 200) {
                                        data = xhr.responseText;
                                        if(data == "true") {
						setTimeout(function(){hideUi("New firmware was downloaded succesfully!")},3000);
						setTimeout(function(){showUi()},7000);
                                        } else {
						setTimeout(function(){hideUi("Downlaod FAILED! Refresh page and try again.")},3000);
						setTimeout(function(){showUi()},7000);
                                        }
                                 }
                        }
                };
                xhr.send(formData);
        });
});


function Upgrade(act)	{
	$(document).ready( function() {
		hideUi("Please wait. Preparing installation.");
		E("act").value=act;
		$.get('php/update.php')
  			.done(function(data) {
				if (data.trim() == "false") {
					hideUi("No image file selected.");
					setTimeout(function(){showUi()},3000);
				} else {
					setTimeout(function(){hideUi(data)},3000);
                                        setTimeout(function(){showUi()},5000);
				}
			})
			.fail(function() {
				hideUi_timer("Firmware was transferred. Please wait. Upgrade in progress...", 170);
				setTimeout(function(){hideUi("Please wait. Check installation status.")},171000);
                                setTimeout(function(){checkUpdate()}, 180000);
			})
	});

}

function checkUpdate() {
	$.get('resUpgrade.txt')
		.done(function(res) {
			if (res != '')	{
				var text = res.slice(7);
				setTimeout(function(){hideUi(text)},2000);
				setTimeout(function(){showUi()},5000);
			} else {
				setTimeout(function(){hideUi("Something went wrong.")},2000);
	                	setTimeout(function(){showUi()},5000);
			}
		})
		.fail(function() {
			setTimeout(function(){hideUi("Upgrade was not done.")},2000);
			setTimeout(function(){showUi()},5000);
		})
}

$.widget("jai.config", {
	_create: function(){
		$(this.element)
			.append(
				$(document.createElement('select'))
					.prop("id","configs")
					.prop("name","configs")
					.prop("class", "radioSwitchElement")
			);
		$.each( list, function( key, value ){
			$('#configs').append (
				$(document.createElement('option'))
				 .prop("value", key)
				 .prop("text", value)
				)
		});

	var currConf = $('#configs option').filter(function() { return $(this).html() == "sabai"; }).val();
	$('#configs').radioswitchH({ value: currConf , hasChildren: true });
},
});

// Display radioswitch element
$("#configList").config();
var selectOption = $("#configs").find(":selected").text();

$('#configs').change(function() {
	selectOption = $(this).find(":selected").text();
	if (selectOption.trim() == 'sabai') {
		E('backUp').hidden = false;
		E('restore').hidden = true;
		E('aMsg').innerHTML = ' * Sabai - is the currently running configuration.';
	} else {
		E('restore').hidden = false;
		E('backUp').hidden = true;
		E('aMsg').innerHTML = ' * This is a previous user backup of Sabai configuration.';
	}
});
</script>
