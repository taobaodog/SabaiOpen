<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {  
	$url = "/index.php?panel=help";
	header( "Location: $url" );     
}
?>
<div class='pageTitle'>SabaiOpen Manual</div>
<br>

<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='wan'></a>WAN</span>
  <div class='controlBoxContent'>
    WAN Type, MTU, MAC, DNS
    <span class='smallText'><br><br><b>MAC Address-</b> MAC Address Media Access Control Address, MAC addresses are distinct addresses on the device level and is comprised of a manufacturer number and serial number.</span>  
    <span class='smallText'><br><br><b>DNS-</b> DNS Domain Name System, translates people-friendly domain names (www.google.com) into computer-friendly IP addresses (1.1.1.1). A DNS is especially important for VPNs as some countries return improper results for domains intentionally as a way of blocking that web site.</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='time'></a>Time</span>
  <div class='controlBoxContent'>
    NTP Servers, Current Router Time and Timezone, Current Computer Time and Timezone
    <span class='smallText'><br><br><b>NTP Servers-</b> Network Time Protocol servers, that  set correct time on user device. </span>
    <span class='smallText'><br><br><b>Current Router Time and Current Computer Time </b> can be synchronized with button Synchronize. Set user Time Zone using interactive map and synchronize device to it.</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='pptp'></a>PPTP</span>
  <div class='controlBoxContent'>
    PPTP
    <span class='smallText'><br><br><b>PPTP Client</b> can be configured by setting user server, username and password data. Use Save/Clear buttons to hold setting or to remove it. Start/Stop will set up VPN tunnel using user profile.</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='openvpnclient'></a>Open VPN</span>
  <div class='controlBoxContent'>
    OpenVPN, Configuration
    <span class='smallText'><br><br><b>OVPN client</b> uses configuration file *.ovpn. Upload your configuration file from your PC direct to device and get VPN working. Start/Stop buttons are for VPN process managemet. Edit Config button will help in case if any changes to file are needed to be done. In case of any problem can be usefull to see log by pushing Show Log.</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='tor'></a>Tor</span>
  <div class='controlBoxContent'>
    Tor tunnel
    <span class='smallText'><br><br><b>Tor</b> is new anonymizing feature in SabaiOpen. Turning on tunnel and forwarding any host to ACC will allow to anonymize traffic for the host. User can also set ACC IP and its port 8080 in browser for anonymous browsing. More information about Tor you can find on https://www.torproject.org/</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='ping'></a>Ping</span>
  <div class='controlBoxContent'>
    Ping Address, Count, Size
    <span class='smallText'><br><br><b>Ping</b> is a diagnostics tool of network connection. User can test connection adjusting adsress, count and packet size parameters.</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='trace'></a>Trace</span>
  <div class='controlBoxContent'>
    Trace Address, Hops, Wait
    <span class='smallText'><br><br><b>Trace</b> is also a diagnostics feature of network connection. User can make diagnostic with displaying the route (path) and measuring transit delays of packets across an Internet Protocol (IP) network.</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='nslookup'></a>NS Lookup</span>
  <div class='controlBoxContent'>
    Domain, Lookup
    <span class='smallText'><br><br><b>NS Lookup</b> is a network administration tool for querying the Domain Name System (DNS) to obtain domain name or IP address mapping or for any other specific DNS record.</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='route'></a>Route</span>
  <div class='controlBoxContent'>
    Routing table, Genmask,Flags, MSS, Window, IRTT, Interface
    <span class='smallText'><br><br><b>Routing table</b> is a data table, that lists the routes to particular network destinations. The routing table contains information about the topology of the network. </span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='logs'></a>Logs</span>
  <div class='controlBoxContent'>
    Logs
    <span class='smallText'><br><br><b>Logging</b> is open for user. User can scroll log on page or download as a file to PC.</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='console'></a>Console</span>
  <div class='controlBoxContent'>
    Console
    <span class='smallText'><br><br><b>Console</b> is accessible for user for advanced diagnostic and management.</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='portforwarding'></a>Port Forwarding</span>
  <div class='controlBoxContent'>
    Proto, Ports
    <span class='smallText'><br><br><b>Port Forwarding</b> is a feature for network administration.</span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='settings'></a>Settings</span>
  <div class='controlBoxContent'>
    Router Name, Proxy, Power, Password
    <span class='smallText'><br><br><b>Router Name</b> and <b>Password</b> can be updated by user. <b>Password MUST be updated immediately after installation.</b> </span>
    <span class='smallText'><br><br><b>Power</b> off or restart your device direct from WEB UI.</span>
    <span class='smallText'><br><br><b>Proxy</b> listening to port 8080. Turned off by default. </span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='upgrade'></a>Upgrade</span>
  <div class='controlBoxContent'>
    Server Update, Manual Update, Firmware Configuration
    <span class='smallText'><br><br><b>Server Update</b> is automatical upgrade process if new version of software is available.</span>
    <span class='smallText'><br><br><b>Manual Update</b> can be made by uploading .img file. It is available to revert last update and to make factory reset of the last update.</span>
    <span class='smallText'><br><br><b>Firmware Configuration</b> can be backuped or downloaded by user at any time. It ensures flexible switching between different settings. </span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='about'></a>About</span>
  <div class='controlBoxContent'>
    About SabaiOpen
    <span class='smallText'><br><br> Visit About page and learn more about SabaiOpen project. </span>
  </div>
</div>
<div class='controlBox'>
  <span class='controlBoxTitle'><a href='#' name='status'></a>Status</span>
  <div class='controlBoxContent'>
    System, WAN, VPN, Proxy
    <span class='smallText'><br><br>System overview and its status page.</span>
  </div>
</div>

<div id='footer'> Copyright © 2016 Sabai Technology, LLC </div>


<script type='text/ecmascript' src='/libs/jeditable.js'></script>
<script type='text/ecmascript'>

// $(function() {
// 	$('#accordion').accordion({
//     active:false,
//     animate: false,
//     collapsible:true,
//     heightStyle:"content",
//   });
//   $('#accordion').show();
//  })

</script>