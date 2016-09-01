<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=vpn&section=gateways";
	header( "Location: $url" );     
}
?>
<!DOCTYPE html>
<!--Sabai Technology - Apache v2 licence
    copyright 2016 Sabai Technology -->
<meta charset="utf-8"><html>
<head>
  <link rel="stylesheet" href="libs/css/buttons.dataTables.min.css">
  <link rel="stylesheet" href="libs/css/select.dataTables.min.css">
  <link rel="stylesheet" href="libs/css/dataTables.bootstrap.min.css">
  <link rel="stylesheet" href="libs/css/bootstrap.min.css">
  <link rel="stylesheet" href="libs/css/main.css">
  <script src="libs/bootstrap.min.js"></script>
  <script src="libs/jquery.dataTables.min.js"></script>
  <script src="libs/dataTables.bootstrap.min.js"></script>
  <script src="libs/dataTables.altEditor.free.js"></script>
  <script src="libs/dataTables.buttons.min.js"></script>
  <script src="libs/buttons.bootstrap.min.js"></script>
  <script src="libs/dataTables.select.min.js"></script>
</head>
<body>
<form id="fe">
<input type='hidden' id='dhcptable' name='dhcptable'>
<input type='hidden' id='act' name='act'>
	<div class='pageTitle'>Network: DHCP/Gateways</div>

<div class='controlBox'>
	<span class='controlBoxTitle'>Summary</span>
	<div class='controlBoxContent'>
      <table class="table table-striped" id="gateTable">
        <thead>
          <tr>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>        
        </tbody>
      </table>
      <input type='button' id="savebutton" name="savebutton" value='Save' onclick='DHCPcall("save")'>
      <span id='messages'>&nbsp;</span>
      <div id='hideme'>
      <div class='centercolumncontainer'>
        <div class='middlecontainer'>
          <div id='hiddentext' value-'Please wait...' ></div>
          <br>
        </div>
      </div>
    </div>
		<div class="smallText">
			<br><b>Make Static</b>- Choose "on" to make lease permanent. </li>
      <br><b>Route</b>- Choose the default route for this device.  "vpn_fallback" will continue access through internet if VPN is down. </li>
			<br><b>Address</b> - The IP address assigned to the device.  You can click in this field and change the IP address. </li>
			<br><b>MAC Address</b> - The hardware address of the unit. This is hardcoded into the device. </li>
			<br><b>Name</b> - The name of the device. You can click in this field and change the name.  </li>
			<br><b>Lease Ends</b>- The time when the lease expires. </li>
		</div>
	</div>	
</div>
<p>
	<div id='footer'>Copyright © 2016 Sabai Technology, LLC</div>
</p>
</form>
</body>
</html>
<script type='text/javascript'>

  var hidden, hide,res;
  var f = E('fe'); 
  var hidden = E('hideme'); 
  var hide = E('hiddentext');

$(document).ready(function() {

//////////////////////////////////////////
/*
IMPORTANT - COLUMNDEFS
Always add the ID row.
Visibility state doesnt matter but searchable
state should be set to the same value.

Always add a type.
Current supported type parameters:
text - for editable textfields (including numbers etc.)
select - for select menues, if used then options should be specified aswell
readonly - for fields with readonly attribute.

*/
//////////////////////////////////////////
  var columnDefs = [{
    id: "DT_RowId",
    data: "DT_RowId",
    type: "text",
    "visible": false,
    "searchable": false
  },{
    id: "static",
    title: "Static",
    data: "static",
    type: "select",
    "options": [
    "on",
    "off"
    ]
  }, {
    id: "route",
    title: "Route",
    data: "route",
    type: "select",
    "options": [
    "default",
    "local",
    "vpn_fallback",
    "vpn_only",
    "accellerator",
    "tor"
    ]
  }, {
    id: "ip",
    title: "IP address",
    data: "ip",
    type: "text",
    pattern: "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
    errorMsg: "*Invalid address - Enter valid ip",
    hoverMsg: "Ex: 82.84.86.88"
  }, {
    id: "mac",
    title: "Mac",
    data: "mac",
    type: "readonly"
  }, {
    id: "name",
    title: "Name",
    data: "name",
    type: "text",
    pattern: "^[a-zA-Z0-9_-]+$",
    errorMsg: "*Invalid name - Allowed: A-z0-9 _ -",
    hoverMsg: "Ex: UserPhone-22_Android"
  }, {
    id: "time",
    title: "Time",
    data: "time",
    type: "readonly"
  }, {
    id: "stat",
    title: "Status",
    data: "stat",
    type: "readonly"
  }];

//Making errors show in console rather than alerts
$.fn.dataTable.ext.errMode = 'none';

$('#gateTable').on( 'error.dt', function ( e, settings, techNote, message ) {
console.log( 'An error has been reported by DataTables: ', message );
} );
$.post('php/dhcp.php', {'act': 'get'})
   .done(function(res) {            
//Creating table
  $('#gateTable').dataTable( {
    dom: "Bfrltip",
    ajax: "libs/data/dhcp.json",        
    columns: columnDefs,
    select: "single",
    altEditor: true,
    responsive: true,
    buttons: [{ 
            extend: 'selected', 
            text: 'Edit',
            name: 'edit'        
    },{ 
            text: 'Refresh',
            name: 'refresh'        
    }]
  });
});

});








/*var settings;
	$.widget("jai.devicelist", {
  //Adding to the built-in widget constructor method - do this when widget is instantiated
  _create: function(){
    //TO DO: check to see if containing element has a unique id
    
    // BUILDING DOM ELEMENTS
    $(this.element)
    .prepend( $(document.createElement('table'))
    	.addClass("listTable")
    	.prop("id","list") 
    	.width("100%")
    	)

    $('#list').dataTable({
    	'bPaginate': false,
    	'bInfo': false,
    	'bFilter': false,
    	"sAjaxSource": 'libs/data/dhcp.json',
    	"aoColumns": [
    	{ "sTitle": "Make Static", "mData":"static", 'sClass':'staticDrop' },
      { "sTitle": "Route", "mData":"route", 'sClass':'routeDrop' },
    	{ "sTitle": "Address", "mData":"ip", 'sClass':'plainText'  },
    	{ "sTitle": "MAC", "mData":"mac" },
    	{ "sTitle": "Name", "mData":"name", "sClass":"plainText"},
    	{ "sTitle": "Lease Ends", "mData":"time" },
      { "sTitle": "Status", "mData":"stat" }
    	],

    	'fnRowCallback': function(nRow, aData, iDisplayIndex, iDisplayIndexFull){
    		$(nRow).find('.plainText').editable(
    			function(value, settings){ return value; },
    			{
    				'onblur':'submit',
    				'event': 'click',
    				'placeholder' : 'Click to edit'
    			}
    			);

        $(nRow).find('.staticDrop').editable(
          function(value, settings){ return value; },
          {
          'data': " {'on':'on','off':'off'}",
          'type':'select',
          'onblur':'submit',
          'placeholder':'off',
          'event': 'click'
          }
          );

          $(nRow).find('.routeDrop').editable(
          function(value, settings){ return value; },
          {
          'data': " {'default':'default','local':'local','vpn_fallback':'vpn_fallback','vpn_only':'vpn_only','accelerator':'accelerator','tor':'tor'}",
          'type':'select',
          'onblur':'submit',
          'placeholder':'default',
          'event': 'click'
          }
          );

    	} /* end fnRowCallback*/
/*    })

    this._super();
    },

   _destroy: function() {
   this.element
	.removeClass( "listTable" )
	.text( "" );
   },

    refresh: function() {
	this._destroy();
	this._create();
    }


});
*/
/*$(function(){
  //instatiate widgets on document ready
  $('#devicelist').devicelist();
  REFcall('get');
})

 */

/*
function PORTresp(){ 
  msg(res.rMessage); 
  showUi(); 
} 

function STATICcall(){ 
  var datatable = $('#list').DataTable();
  datatable
    .rows(':has(:checkbox:checked)')
    .draw();
//$('#rowclick2 tr').filter(':has(:checkbox:checked)').find('td');
} */

function DHCPcall(act){ 
    E("act").value=act;
      hideUi("Adjusting DHCP settings..."); 
      // Pass the form values to the php file 
      $.post('php/dhcp.php', {'act': 'save'})
      .done(function(res) {
        eval(res);                                                                                                                                   
        msg(res.msg);                                                                            
        showUi();
      });
      // Important stops the page refreshing
      return false;
}

</script>
   