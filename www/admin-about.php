<!DOCTYPE html>
<!--Sabai Technology - Apache v2 licence
    copyright 2014 Sabai Technology -->
<html><head><meta charset='UTF-8'><meta name='robots' content='noindex,nofollow'>
<title>[VPNA] About</title><link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='jquery-1.11.1.min.js'></script>
<script type='text/javascript' src='sabaivpn.js'></script>
<script type='text/javascript'>

sabaiopen = {
 dist: <?php echo exec("grep 'DISTRIB_DESCRIPTION' /etc/openwrt_release | cut -d '=' -f2 | awk '{print $0}'")?>,
 kern: '<?php echo exec("uname -r -m"); ?>',
 vers: '<?php echo exec("cat /etc/sabai/sys/version"); ?>'
}

function init(){
$('.active').removeClass('active')
$('#about').addClass('active')
 if(sabaiopen==null || sabaiopen==undefined) return;
 if(sabaiopen.dist!=null&&sabaiopen.dist!=undefined&&sabaiopen.dist!='') E('distro').innerHTML = sabaiopen.dist;
 if(sabaiopen.kern!=null&&sabaiopen.kern!=undefined&&sabaiopen.kern!='') E('kernel').innerHTML = sabaiopen.kern;
 if(sabaiopen.vers!=null&&sabaiopen.vers!=undefined&&sabaiopen.vers!='') E('version').innerHTML = sabaiopen.vers;
} 
</script>
</head>
<body onload='init()'>
<table id='container' cellspacing=0>
<tr id='body'><td id='navi'>
					<script type='text/javascript'>navi()</script>
				</td>
<td id='content'>
<div class="pageTitle">About</div>
<div class='section-title'>Sabai Technology</div><div class='section'>
<div>

SabaiOpen v<span id='version'>1</span>  Alpha on <span id='distro'></span> 
<br>Linux Kernel Version <span id='kernel'></span>

<p>Thank you for being a Sabai Technology customer!
<blockquote>Sabai Technology: <i>Technology for the People</i><br>
301 N Main Street<br>
Simpsonville, SC 29681<br>
+1-864-962-4072<br>
<A HREF='mailto:info@sabaitechnology.com'>info@sabaitechnology.com</a><br>
</blockquote>
<p>
Sabai Technology and SabaiOpen are registered trademarks with all rights reserved.
Software may not be distributed for business purposes, except by Sabai Technology.
</p>
Copyright &copy; 2014 Sabai Technology, LLC<br>
<a href='http://www.sabaitechnology.com'>http://www.sabaitechnology.com</a><br>
<p>VPN Client Interface - Sabai Technology US patent pending #13/292,509.</p>

<p>Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. 
You may obtain a copy of the License at </p>
<a href='http://www.apache.org/licenses/LICENSE-2.0'>http://www.apache.org/licenses/LICENSE-2.0</a><br>
<p>
</p>
<p>
Unless required by applicable law or agreed to in writing, software distributed 
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS 
OF ANY KIND, either express or implied. See the License for the specific language 
governing permissions and limitations under the License.
</p>
</div></div>
</td></tr>
</table>
</body>
</html>

