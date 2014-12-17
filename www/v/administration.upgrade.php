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
    <p>
    <div id='footer'>Copyright © 2014 Sabai Technology, LLC</div>
    </p>
  </div>
</div>

</form>
<script type='text/javascript'>

var hidden, hide, pForm = {};
var hidden = E('hideme');
var hide = E('hiddentext');

E('fileName').value = '';
E('browse').value = '';

var version='<?php readfile("libs/data/version"); ?>';
 E('_version').value = (version==''?'000':version);
 E('cversion').innerHTML= version.substr(0,1) +'.'+ version.substr(1);

// jQuery uploadbutton implementation
$('.uploadButton').bind("click" , function () {
        $('#browse').click();
});
// View the file`s name
function fileInput(obj){
	var browseFile = obj.value;
        E('fileName').value = browseFile;
}

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
                                setTimeout(function(){checkUpdate()}, 173000);
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

</script>
