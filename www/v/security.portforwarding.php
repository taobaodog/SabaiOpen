<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=security&section=portforwarding";
	header( "Location: $url" );     
}
?>
<form id="fe">
  <input type='hidden' id='pftable' name='pftable'>
  
  <div class='pageTitle'>Security: Port Forwarding</div>

  <div class='controlBox'>
    <span class='controlBoxTitle'>Port Forwarding</span>
    <div class='controlBoxContent'> 
      <table id='list' class='listTable clickable' ></table>
      <input type='button' value='Add' id='add'>
      <input type='button' id="savebutton" name="savebutton" value='Save' onclick="PORTcall()">
      <input type='button' id="deletebutton" name="deletebutton" value='Delete Row' onclick="DELcall()">
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
        <br><b>Proto</b>- Which protocol (tcp or udp) to forward. </li>
        <br><b>VPN</b> - Forward ports through the normal internet connection (WAN) or through the tunnel (VPN), or both. Note that the Gateways feature may result in may result in undefined behavior when devices routed through an interface have ports forwarded through a different interface. Additionally, ports will only be forwarded through the VPN when the VPN service is active. </li>
        <br><b>Src Address</b>(optional) - Forward only if from this address. Ex: "1.2.3.4", "1.2.3.4 - 2.3.4.5", "1.2.3.0/24", "me.example.com". </li>
        <br><b>Ext Ports</b> - The port(s) to be forwarded, as seen from the WAN. Ex: "2345", "200,300", "200-300,400". </li>
        <br><b>Int Port</b>- The destination port inside the LAN. Only one port per entry is supported. </li>
        <br><b>Int Address</b>- The destination address inside the LAN. </li>
      </div>
    </div>
  </div>
  <p>
    <div id='footer'>Copyright © 2016 Sabai Technology, LLC</div>
  </p>
</form>

<script type='text/ecmascript'>
  var hidden, hide,res;
  var f = E('fe'); 
  var hidden = E('hideme'); 
  var hide = E('hiddentext');
  var portforwarding='<?php
  $pftable=exec("uci get sabai.pf.table");
  exec("uci get sabai.pf.table > /www/libs/data/port_forwarding.json");
  echo "$pftable"; 
  ?>'; 

  function PORTcall(){ 
    $('input[type=search]').val("");
    $('#example').dataTable().api().search("").draw();
     hideUi("Adjusting Port Forwarding settings..."); 
//read the text values
var TableData=new Array();
$('#list tr').each(function(row, tr){
  TableData[row] = {
    "status" : $(tr).find('td:eq(1)').text()
    , "protocol" : $(tr).find('td:eq(2)').text()
    , "gateway" : $(tr).find('td:eq(3)').text()
    , "src" : $(tr).find('td:eq(4)').text()
    , "ext" : $(tr).find('td:eq(5)').text()
    , "int" : $(tr).find('td:eq(6)').text()
    , "address" : $(tr).find('td:eq(7)').text()
    , "description" : $(tr).find('td:eq(8)').text()
  }
});

TableData = $.toJSON(TableData);
//var json=JSON.parse(TableData);
//alert(TableData);
//$("#pftable").val(TableData);
var json=$.parseJSON(TableData);
$("#pftable").val(TableData);
// Pass the form values to the php file 
$.post('php/portforwarding.php', $("#fe").serialize(), function(res){
 // res=$.parseJSON(pass);
// Detect if values have been passed back   
if( res != "" ){
  eval(res);                                                                                                                                   
  msg(res.msg);                                                                                
};
showUi();
});
// Important stops the page refreshing
return false;
} 

function PORTresp(){ 
  msg(res.rMessage); 
  showUi(); 
} 

function DELcall(){ 
  var datatable = $('#list').DataTable();
  datatable
    .rows(':has(:checkbox:checked)')
    .remove()
    .draw();
//$('#rowclick2 tr').filter(':has(:checkbox:checked)').find('td');
} 

var lt =  $('#list').dataTable({
  'bPaginate': false,
  'bInfo': false,
  'bStateSave': false,
  'bProcessing': true,
  'sAjaxSource': 'libs/data/port_forwarding.json',
  'aoColumns': [
  { 'sTitle': 'Select',       'mData': null,      "sDefaultContent": '<input type="checkbox" />' },
  { 'sTitle': 'On/Off',       'mData':'status',     'sClass':'statusDrop'},  
  { 'sTitle': 'Proto',        'mData':'protocol',   'sClass':'protoDrop' },
  { 'sTitle': 'Gateway',          'mData':'gateway',    'sClass':'vpnDrop' },
  { 'sTitle': 'Source Address',  'mData':'src',        'sClass':'plainText'  },
  { 'sTitle': 'Source Port',     'mData':'ext',        'sClass':'plainText'   }, 
  { 'sTitle': 'Destination Port',     'mData':'int',        'sClass':'plainText' },
  { 'sTitle': 'Destination Address',  'mData':'address',    'sClass':'plainText'  },
  { 'sTitle': 'Description',  'mData':'description','sClass':'plainText'  }
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

    $(nRow).find('.statusDrop').editable(
      function(value, settings){ return value; },
      {
        'data': " {'on':'on','off':'off'}",
        'type':'select',
        'onblur':'submit',
        'event': 'click'
      }
      );

    $(nRow).find('.protoDrop').editable(
      function(value, settings){ return value; },
      {
        'data': " {'UDP':'UDP','TCP':'TCP', 'Both':'Both'}",
        'type':'select',
        'onblur':'submit',
        'event': 'click'
      }
      );

    $(nRow).find('.vpnDrop').editable(
      function(value, settings){ return value; },
      {
        'data': " {'LAN':'LAN', 'WAN':'WAN','OVPN':'OVPN', 'PPTP':'PPTP'}",
        'type':'select',
        'onblur':'submit',
        'event': 'click'
      }
      );

  } /* end fnRowCallback*/
}) /* end datatable*/


$('#add').click( function (e) {
  e.preventDefault();
  lt.fnAddData(
  { 
    "status": 'on', 
    "protocol": 'Both',
    "gateway": 'WAN',
    "src": "24.24.24.24",
    "ext": "15",
    "int": "56",
    "address": "192.168.199.2",
    "description": "Test Data" 
  }
  );

});

function ROWcall(){
  var TableData=new Array();
  $('#list tr').each(function(row, tr){
    if ($(tr).find('td:eq(0)').text() == "checked") {
      $(nRow).addClass('row_selected');
      list.row('row_selected').remove().draw( false );
    };
  });
};

function saveGateway(){
  toServer('Save this.');
};

  // function toggleExplain(){

  //   $("#description").toggle();
  //   if( $("#toggleDesc").text()=="Show Description") {
  //     $("#description").show();
  //     $("#toggleDesc").text("Hide Description");
  //   } else {
  //     $("#description").hide();
  //     $("#toggleDesc").text("Show Description");
  //   }
  // }

</script>