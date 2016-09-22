<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=diagnostics&section=logs";
	header( "Location: $url" );     
}
?>
<style type='text/css'>

/*.shortInput { width: 2.5em; }
.longInput { width: 50%; }*/

#logContents { width: 100%; height: 40em; }


/*#listContainer {
 position: relative;
 display: inline-block;
 border: 1px solid transparent;
 width: 25%;
 margin: .25em .5em 0 0;
}

#currentLog {
 display: inline-block;
 padding: .1em .5em;
/* cursor: pointer;
}
*/
/*#currentLog, .dirlist > li, .dir { cursor: pointer; }*/

/*#listRoot {
 width: 100%;
 display: none;
 background: white;
 border: 1px solid black;
 float: left;
 margin: 0 0 0 -1px;
 margin: 0;
 cursor: pointer;
 text-indent: 0;
 padding: .1em 0;
 list-style-type: none;
 z-index: 2;
 position: absolute;
}*/
/*.dirlist > li { padding: 0 .5em; }
.dirlist > li:hover { background-color: yellow; }
.dirlist > li.sublist:hover { background-color: silver; }
*/
/*.dir {
	display: inline-block;
	width: 100%;
}

.directory {
 display: none;
 text-indent: 0;
 margin: 0;
 padding-left: 0;
 list-style-type: none;
}
.directory > li {
 padding-left: 1em;
}

.closed:before { content: "+ "; }
.open:before { content: "- "; }

#goButton { float: right; }*/

</style>

<div class='pageTitle'>Diagnostics: Logs</div>

<div class='controlBox'>
	<span class='controlBoxTitle'>Logs</span>
	<div class='controlBoxContent'>
		<!-- <input id="log" name="log" type="hidden"> -->

<?php// include("php/logs.php"); ?>

<!-- <div id="listContainer">

<span id="currentLog" onclick='showLogSelect();'></span>

<ul id="listRoot" class='dirlist'>

</ul>

</div> -->
<div class="row">
    <div class="col-md-12 col-sm-12 col-xs-12">
        <form id='fe' class="form-inline" role="form">
            <div class="form-group">
              	<select id='log' class="form-control" name='log'>
	 				<option value='messages' selected>System log</option>
	 				<option value='privoxy'>Privoxy log</option>
	 				<option value='kernel'>Kernel log</option>
	 			</select>
            </div>
            <div class="form-group">
              	<select id='act' name='act' class="form-control" onchange="toggleDetail();">
	 				<option value='all'>View all</option>
	 				<option value='head'>View first</option>
	 				<option value='tail' selected>View last</option>
	 				<option value='grep'>Search for</option>
	 				<option value='download'>Download file</option>
	 			</select>
            </div>
            <div class="form-group">
              <input type="text" name='detail' id='detail' class='form-control'><span id='detailSuffix'></span>
            </div>
        </form>
    </div>
</div>
<br>
	<div class='col-md-2 col-sm-2 col-lg-2 '>	
		<button class='btn btn-default btn-sm pull-left' id='goButton' type="button" value="Go" onclick="goLog();">Show</button>
	</div>
<br>	


		<div id='hideme'>
            		<div class='centercolumncontainer'>
                		<div class='middlecontainer'>
                    			<div id='hiddentext'>Please wait...</div>
                    		<br>
                		</div>
            		</div>
        	</div><br>

		<textarea id='logContents' readonly></textarea>
	</div>
</div>
<div>

</div>
<div id='footer'> Copyright © 2016 Sabai Technology, LLC </div>

<script type='text/javascript'>
var hidden, hide, pForm = {};
var hidden = E('hideme');
var hide = E('hiddentext');

function goLog(n){

console.log($("#fe").serialize());

	if($("#act").val() == "download"){
		hideUi("Downloading ...");
		$.ajax("php/logs.php", {
			success: function(data){
				if (data.trim() == "false") {
					hideUi("Log file is missing.");
					setTimeout(function(){showUi()},4500);
				} else {
					window.location.href = data 
					hideUi("Downloading completed.");
					setTimeout(function(){showUi()},4500);
				}
			},
			error: function(data){ hideUi("Failed"); setTimeout(function(){showUi()},4500); },
			dataType: "text",
			data: $("#fe").serialize()
		});
	}else{
		$.ajax("php/logs.php", {
			success: function(o){ $('#logContents').html(o); },
			dataType: "text",
			data: $("#fe").serialize()
		});
	}
}

/*function catchEnter(event){ if(event.keyCode==13) goLog(); }*/


function toggleDetail(){
	$('#detailSuffix').html('');
	switch($('#act').val()){
		case 'all':
		case 'download':
			$('#detail').hide();
		break;
		case 'head':
		case 'tail':
			$('#detail').show().val('25');
			$('#detailSuffix').html(' lines');
		break;
		case 'grep':
			$('#detail').show().val('');
			break;
	}
}

//Preventing page-reload on "enter"-keypress
  $(document).ready(function() {
  $(window).keydown(function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });
}); 

/*function toggleContentList(event){
	$(this).toggleClass("closed open")
	$('#'+ $(this).attr('rel') ).slideToggle();
}

function setLogValue(logName){
	$('#log').val(logName);
	$('#currentLog').html(logName);
}

function hideLogSelect(){
	setLogValue( getLogSelected( this ) );
	$('#listRoot').slideUp('fast');
}*/

$(function(){
/* $('#detail').on("keydown", catchEnter);
 $('.dir').on("click", toggleContentList);
 $('#listRoot li').not('.sublist').on("click", hideLogSelect);
 setLogValue('messages');*/
 toggleDetail();
});

/*
function show(){ $('#tooltip').show(); }
function hide(){ $('#tooltip').hide(); }
function displayInline(){ if($('#inlineHelp').is(':checked')){ $('.inlineHelp').show(); }else { $('.inlineHelp').hide(); } }
function checkNum(){
	console.log('blurred');
	var contents = $('#lines').val();
	console.log(contents)
	if($.isNumeric(contents)){
		console.log('numberic')
		$('#error').html('');
		$('#linesDiv').removeClass('errorInput')
		getLog('last');
	}else{
		console.log('not numberic')
		$('#error').html('<span style="color: red">Oops! Value must be a number</span>')
		$('#linesDiv').addClass('errorInput')
	}
}

function ignoreError(){
		$('#error').html('');
		$('#linesDiv').removeClass('errorInput')
}


//Uncomment for spinner - functional but does not match drop down
// $('#lines').spinner({ min: 0, max: 1000 }).spinner('value',25);
*/
</script>
