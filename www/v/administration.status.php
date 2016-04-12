<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=administration&section=status";
	header( "Location: $url" );     
}
?>
<div class='pageTitle'>Network: Status</div>
<!--	TODO:

-->
</div>
<div class='controlBox'><span class='controlBoxTitle'>System</span>
	<!-- this div gets populated by widget -->
  <div class='controlBoxContent' id='system_build'>
	</div>
</div>
<div class='controlBox'><span class='controlBoxTitle'>WAN</span>
	<!-- this div gets populated by widget -->
  <div class='controlBoxContent' id='wan_build'>
	</div>
</div>
<!--	Removed for Accelerator
<div class='controlBox'><span class='controlBoxTitle'>LAN</span>
  <div class='controlBoxContent' id='lan_build'>
	</div>
</div>
<div class='controlBox'><span class='controlBoxTitle'>Wireless</span>
  <div class='controlBoxContent' id='wireless_build'>
	</div>
</div>
-->
<div class='controlBox'><span class='controlBoxTitle'>VPN</span>
  <!-- this div gets populated by widget -->
  <div class='controlBoxContent' id='vpn_build'>
  </div>
</div>
<div class='controlBox'><span class='controlBoxTitle'>Proxy</span>
  <!-- this div gets populated by widget -->
  <div class='controlBoxContent' id='proxy_build'>
  </div>
</div>
<div id='footer'> Copyright © 2016 Sabai Technology, LLC </div>

<script>
var data, fullinfo;
function getStats(){ 
    $.get("php/status.php", function(data)
      {
        fullinfo=$.parseJSON(data);
                    //set sys elements
                    $("#sys_name").text(fullinfo.sys.name);
                    $("#sys_model").text(fullinfo.sys.model);
		    $("#sys_version").text(fullinfo.sys.version);
                    $("#sys_time").text(fullinfo.sys.time);
                    $("#sys_uptime").text(fullinfo.sys.uptime);
                    $("#sys_cpuload").text(fullinfo.sys.cpuload);
                    $("#sys_mem").text(fullinfo.sys.mem);
                    $("#sys_gateway").text(fullinfo.sys.gateway);
                    //set wan elements
                    $("#wan_mac").text(fullinfo.wan.mac);
                    $("#wan_connection").text(fullinfo.wan.connection);
                    $("#wan_ip").text(fullinfo.wan.ip);
                    $("#wan_subnet").text(fullinfo.wan.subnet);
		    if (fullinfo.wan.gateway)	{
                    	$("#wan_gateway").text(fullinfo.wan.gateway);
		    }	else 	{
			$("#wan_gateway").text(fullinfo.sys.gateway);
		    }
                    //set lan elements
                    $("#lan_mac").text(fullinfo.lan.mac);
                    $("#lan_ip").text(fullinfo.lan.ip);
                    $("#lan_subnet").text(fullinfo.lan.subnet);
                    $("#lan_dhcp").text(fullinfo.lan.dhcp);
                    //set wireless 0 elements
                    $("#wl0_mac").text(fullinfo.wl0.mac);
                    $("#wl0_mode").text(fullinfo.wl0.mode);
                    $("#wl0_netmode").text(fullinfo.wl0.netmode);
                    $("#wl0_radio").text(fullinfo.wl0.radio);
                    $("#wl0_ssid").text(fullinfo.wl0.ssid);
                    $("#wl0_security").text(fullinfo.wl0.security);
                    $("#wl0_channel").text(fullinfo.wl0.channel);
                    $("#wl0_width").text(fullinfo.wl0.width);
                    $("#wl0_interference").text(fullinfo.wl0.interference);
                    //set VPN elements
                    $("#vpn_type").text(fullinfo.vpn.proto);
                    $("#vpn_status").text(fullinfo.vpn.status);
                    //set proxy elements
                    $("#proxy_status").text(fullinfo.proxy.status);
                    $("#proxy_port").text(fullinfo.proxy.port);
                    setTimeout("getStats()",5000);
      });
  };
$("document").ready(function(){
    getStats();
    return false;
  });

$.widget("jai.system_build", {
    
  //Adding to the built-in widget constructor method - do this when widget is instantiated
  _create: function(){
    //TO DO: check to see if containing element has a unique id
    
    // BUILDING DOM ELEMENTS
    $(this.element)
    .append( $(document.createElement('table')).addClass("controlTable")
      .append( $(document.createElement('tbody')).addClass("smallText") 
        
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Name') 
          )
          .append( $(document.createElement('td')).html('<div id=sys_name></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Model') 
          )
          .append( $(document.createElement('td')).html('<div id=sys_model></div>') 
          )
        )
	.append( $(document.createElement('tr'))                           
          .append( $(document.createElement('td')).html('Version Build')                          
          )                                                            
          .append( $(document.createElement('td')).html('<div id=sys_version></div>')
          )                                                                
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Time') 
          )
          .append( $(document.createElement('td')).html('<div id=sys_time></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Uptime') 
          )
          .append( $(document.createElement('td')).html('<div id=sys_uptime></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('CPU Load') 
          )
          .append( $(document.createElement('td')).html('<div id=sys_cpuload></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Free Mem') 
          )
          .append( $(document.createElement('td')).html('<div id=sys_mem></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Sys Gateway') 
          )
          .append( $(document.createElement('td')).html('<div id=sys_gateway></div>') 
          )
        )
      ) //end tbody
		) //end system table
	}
})

$.widget("jai.wan_build", {
    
  //Adding to the built-in widget constructor method - do this when widget is instantiated
  _create: function(){
    //TO DO: check to see if containing element has a unique id
    
    // BUILDING DOM ELEMENTS
    $(this.element)
    .append( $(document.createElement('table')).addClass("controlTable")
      .append( $(document.createElement('tbody')).addClass("smallText") 
        
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('MAC Address') 
          )
          .append( $(document.createElement('td')).html('<div id=wan_mac></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Connection') 
          )
          .append( $(document.createElement('td')).html('<div id=wan_connection></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('IP Address') 
          )
          .append( $(document.createElement('td')).html('<div id=wan_ip></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Subnet Mask') 
          )
          .append( $(document.createElement('td')).html('<div id=wan_subnet></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Gateway') 
          )
          .append( $(document.createElement('td')).html('<div id=wan_gateway></div>') 
          )
        )
      ) //end tbody
		) //end wan table
	}
})

$.widget("jai.lan_build", {
    
  //Adding to the built-in widget constructor method - do this when widget is instantiated
  _create: function(){
    //TO DO: check to see if containing element has a unique id
    
    // BUILDING DOM ELEMENTS
    $(this.element)
    .append( $(document.createElement('table')).addClass("controlTable")
      .append( $(document.createElement('tbody')).addClass("smallText") 
        
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('MAC Address') 
          )
          .append( $(document.createElement('td')).html('<div id=lan_mac></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('IP Address') 
          )
          .append( $(document.createElement('td')).html('<div id=lan_ip></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Subnet Mask') 
          )
          .append( $(document.createElement('td')).html('<div id=lan_subnet></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('DHCP') 
          )
          .append( $(document.createElement('td')).html('<div id=lan_dhcp></div>') 
          )
        )
      ) //end tbody
		) //end lan table
	}
})


$.widget("jai.wireless_build", {
    
  //Adding to the built-in widget constructor method - do this when widget is instantiated
  _create: function(){
    //TO DO: check to see if containing element has a unique id
    
    // BUILDING DOM ELEMENTS
    $(this.element)
    .append( $(document.createElement('table')).addClass("controlTable")
      .append( $(document.createElement('tbody')).addClass("smallText") 
        
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('MAC Address') 
          )
          .append( $(document.createElement('td')).html('<div id=wl0_mac></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Wireless Mode') 
          )
          .append( $(document.createElement('td')).html('<div id=wl0_mode></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('SSID') 
          )
          .append( $(document.createElement('td')).html('<div id=wl0_ssid></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Security') 
          )
          .append( $(document.createElement('td')).html('<div id=wl0_security></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Channel') 
          )
          .append( $(document.createElement('td')).html('<div id=wl0_channel></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Channel Width') 
          )
          .append( $(document.createElement('td')).html('<div id=wl0_width></div>') 
          )
        )
      ) //end tbody
		) //end system table
	}
})

$.widget("jai.vpn_build", {
    
  //Adding to the built-in widget constructor method - do this when widget is instantiated
  _create: function(){
    //TO DO: check to see if containing element has a unique id
    
    // BUILDING DOM ELEMENTS
    $(this.element)
    .append( $(document.createElement('table')).addClass("controlTable")
      .append( $(document.createElement('tbody')).addClass("smallText") 
    
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Type') 
          )
          .append( $(document.createElement('td')).html('<div id=vpn_type></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Status') 
          )
          .append( $(document.createElement('td')).html('<div id=vpn_status></div>') 
          )
        )
      ) //end tbody
    ) //end system table
  }
})

$.widget("jai.proxy_build", {
    
  //Adding to the built-in widget constructor method - do this when widget is instantiated
  _create: function(){
    //TO DO: check to see if containing element has a unique id
    
    // BUILDING DOM ELEMENTS
    $(this.element)
    .append( $(document.createElement('table')).addClass("controlTable")
      .append( $(document.createElement('tbody')).addClass("smallText") 
        
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Proxy Status') 
          )
          .append( $(document.createElement('td')).html('<div id=proxy_status></div>') 
          )
        )
        .append( $(document.createElement('tr'))
          .append( $(document.createElement('td')).html('Proxy Port') 
          )
          .append( $(document.createElement('td')).html('<div id=proxy_port></div>') 
          )
        )
      ) //end tbody
    ) //end system table
  }
})

$(function(){
  //instatiate widgets on document ready
  $('#system_build').system_build();
  $('#wan_build').wan_build();
 // $('#lan_build').lan_build();
 // $('#wireless_build').wireless_build();
  $('#vpn_build').vpn_build();
  $('#proxy_build').proxy_build();
});

</script>
