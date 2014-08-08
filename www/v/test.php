<!DOCTYPE html>
<html>
<!--Sabai Technology - Apache v2 licence
    copyright 2014 Sabai Technology -->
<?php include("/www/libs.php"); ?>
<script type='text/javascript'>
      var hidden, hide, f,oldip='',limit=10,info=null,ini=false;

      var wan=$.parseJSON('{<?php
          $type=exec("uci get sabai.wan.proto");
          $ip=trim(exec("uci get sabai.wan.ip"));
          $mask=trim(exec("uci get sabai.wan.mask"));
          $gateway=trim(exec("uci get sabai.wan.gateway"));
          if (exec("uci show network | grep macaddr") != ""){
                $mac=trim(exec("uci get sabai.wan.mac"));
          } else {
            $mac=trim(exec("ifconfig eth0 | awk '/HWaddr/ { print $5 }'"));
          }
          $mtu=trim(exec("uci get sabai.wan.mtu"));
        echo "\"type\": \"$type\",\"ip\": \"$ip\",\"mask\": \"$mask\",\"gateway\": \"$gateway\",\"mac\": \"$mac\",\"mtu\": \"$mtu\"";
      ?>}');
        var dns=$.parseJSON('{<?php
          $servers=exec("uci get sabai.dns.servers");
          echo "\"servers\": \"$servers\"";
      ?>}');
//          for(i in wan){E(i).value = wan[i];};
 //         for(i in dns){E(i).value = dns[i];};


  
</script>
<body >
<div class='pageTitle'>Network: WAN</div>
<div class='controlBox'><span class='controlBoxTitle'>WAN</span>
  <div class='controlBoxContent' id='wansetup'>
<form id="fe">
        <input type='hidden' id='_act' name='act'>
        <div class='section'>
            <table class="fields">
                <tbody>
                    <tr>
                        <td class="title indent1 shortWidth">IP address</td>
                        <td class="content">
                            <input name="ip" id="ip" class='longinput' type="text">
                        </td>
                    </tr>
                    <tr>
                        <td class="title indent1 shortWidth">Mask</td>
                        <td class="content">
                            <input name="mask" id="mask" class='longinput' type="text">
                        </td>
                    </tr>
                    <tr>
                        <td class="title indent1 shortWidth">Gateway</td>
                        <td class="content">
                            <input name="gateway" id="gateway" class='longinput' type="text">
                        </td>
                    </tr>
                </tbody>
            </table>
            <input type='button' class='firstButton' value='Start' onclick='PPTPcall("start")'>
            <input type='button' value='Stop' onclick='PPTPcall("stop")'>
            <input type='button' value='Save' onclick='PPTPcall("save")'>
            <input type='button' value='Clear' onclick='PPTPcall("clear")'> <span id='messages'>&nbsp;</span>
            <br>
        </div>
        </form>

  </div>
</div>

<div class='controlBox'>
  <span class='controlBoxTitle'>DNS</span>
  <div class='controlBoxContent'>
    <table class='controlTable'>
      <tbody>
      <tr>
        <td>DNS Servers</td>
        <td><div><ul id='dns_servers'></ul></div></td>
        <td class="description">
          <div id='editableListDescription'>
            <span class ='xsmallText'>(These are the DNS servers the DHCP server will provide for devices also on the LAN)
            </span>
          </div>
        </td>
      </tr>
      </tbody>
    </table>
  </div>
</div>
<input type='button' value='Save' id='save'>
<pre id='testing'>
</pre>
