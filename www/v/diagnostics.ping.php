<form id='fe'><div class='pageTitle'>Diagnostics: Ping</div>

<!-- TODO: -->

<div class='controlBox'><span class='controlBoxTitle'>Ping</span>
  <div class='controlBoxContent'>
    <table class='controlTable'><tbody>
      <tr>
        <td>Address</td>
        <td><input id='pingAddress' name='pingAddress' value='google.com'></td>           
        <td><input type='button' id='ping' value='Ping' onClick='getResults()'></td>
      </tr>
      <tr>
        <td>Ping Count</td>
        <td><input id='pingCount' name='pingCount' class='shortinput' value='4' /></td>
      </tr>
      <tr>
        <td>Packet Size</td>
        <td><input id='pingSize' name='pingSize' class='shortinput' value='56' /><span class='smallText'> (bytes)</span></td>
      </tr>
    </tbody></table>
    </form>
    <br>
    <div id='results' class='controlBoxContent noshow'>
      <div id='statistics' class='smallText'></div>
      <table id='resultTable' class='listTable'></table>
    </div>
  </div> <!--end control box content -->
</div> <!--end control box  -->

<script type='text/ecmascript'>

function getResults(){
  $('#results').show();
  $('#statistics').html('');
    $('#resultTable').dataTable({
      "bDestroy":true,
      'bPaginate': false,
      'bInfo': false,
      'bFilter': false,
      "sAjaxDataProp": "pingResults",
      
      "fnServerParams": function(aoData){ 
        $.merge(aoData,$('#fe').serializeArray()); 
      },
      
      "fnInitComplete": function(oSettings, json) {
        var stats=json.pingStatistics.split(',');
        var info=json.pingInfo.split(',');
        $('#statistics').append('--Summary--<br><br>Round-Trip: '+stats[0]+' min, '+stats[1]+' avg, '+stats[2]+' max <br>');
        $('#statistics').append('Packets: '+info[0]+' transmitted, '+info[1]+' received, '+info[2]+'% lost<br><br>');
      },
      
      "sAjaxSource": "php/ping.php",
      "aoColumns": [
        { "sTitle": "Count",  "mData":"count" },
        { "sTitle": "Bytes",  "mData":"bytes" },
        { "sTitle": "TTL",    "mData":"ttl"   },
        { "sTitle": "Time",   "mData":"time"  }
      ]

  }); 
}

</script>

