<!DOCTYPE html>
<!--Sabai Technology - Apache v2 licence
    copyright 2014 Sabai Technology -->
<meta charset="utf-8"><html><head>
<title id="mainTitle">SabaiOpen</title>

<link rel="stylesheet" type="text/css" href="/libs/jqueryui.css">
<link rel="stylesheet" type="text/css" href="/libs/jai-widgets.css">
<link rel="stylesheet" type="text/css" href="css/main.css">

<?php include("libs.php"); ?>
<script src="js/main.js"></script>
<script>

function toggleHelpSection() {
	$( "#helpClose").show();
	$( "#helpSection" ).toggle( "slide", { direction: "right" }, 500 );
	$( "#helpButton" ).hide();
	return false;
};

function closeHelpSection() {
	$( "#helpClose").hide();
	$( "#helpSection" ).toggle( "slide", { direction: "right" }, 500 );
	$( "#helpButton" ).show();
	return false;
}

<?php
 $template = array_key_exists('t',$_REQUEST);
 $panel = ( array_key_exists('panel',$_REQUEST) ? preg_replace('/[^a-z\d]/i', '', $_REQUEST['panel']) : null );
 $section = ( array_key_exists('section',$_REQUEST) ? preg_replace('/[^a-z\d]/i', '', $_REQUEST['section']) : null );
 if( empty($panel) ){ $panel = 'network'; $section = 'wan'; }
 $page = ( $template ?'m':'v') ."/$panel". ( empty($section) ? '' : ".$section") .".php";
 if(!file_exists($page)) $page = 'v/lorem.php';
 echo "var template = ". ($template?'true':'false') ."; var panel = '$panel'; var section = '$section';\n";
?>

$(function(){
	$("#goToHelp").attr("href", "http://wiki.jairoproject.com" + location.search);
	$("#goToWiki").attr("href", "help.php" + location.search);
	$( "#helpButton" ).click(toggleHelpSection);
	$( "#helpClose").click(closeHelpSection)
});

</script>
</head><body>

<div id="backdrop">
	<?php include('menu.php'); ?>

	<div id="panelContainer">

		<div id="helpArea">
					<div class='fright' id='vpnstats'>
					<div id='vpntype'></div>
					<div id='vpnstatus'></div>
				</div>

				<div class='fright' id='locstats'>
					<div id='locip'></div>
					<div class='noshow' id='loccontinent'></div>
					<div id='loccountry'></div>
					<div class= 'noshow' id='locregion'></div>
					<div id='loccity'></div>
				</div>
			<img id="helpButton" src="img/help.png">
			<div id="helpSection" class="ui-widget-content ui-corner-al">
		<!-- 		<a href="#" id="closeHelp" class="xsmallText fright">Close</a> -->
				Display Inline Help
				<a id="helpClose" class="noshow xsmallText" href="#">Close</a>
				<input name="inlineHelp" id="inlineHelp" type="checkbox" checked="checked"><br><br>
				<span style="text-decoration: underline">Links:</span><br>
				<a id="goToHelp" href="#">Help Page</a><br>
				<a id="goToWiki" href="#">Wiki Page</a>
			</div>
		</div>
		<div id="panel">
			<?php include($page); ?>
		</div>
	</div>
</div>

</body></html>
