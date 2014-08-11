<form id='fe'>
<div class='pageTitle'>Diagnostics: Trace</div>

<!-- TODO: -->

<div class='controlBox'><span class='controlBoxTitle'>Traceroute</span>
  <div class='controlBoxContent'>
    <table class='controlTable'><tbody>
      <tr>
        <td>Address</td>
        <td><input id='traceAddress' name='traceAddress' value='google.com'></td>           
        <td><input type='button' id='trace' value='Trace' onClick='getResults()'></td>
      </tr>
      <tr>
        <td>Max Hops</td>
        <td><input id='maxHops' name='maxHops' class='shortinput' value='20'/></td>
      </tr>
      <tr>
        <td>Max Wait Time</td>
        <td><input id='maxWait' name='maxWait' class='shortinput' value='5' /><span class='smallText'></span></td>
      </tr>
    </tbody></table>
    </form>
    <br>
    
    <div id='results' class='controlBoxContent noshow'>
      <table id='resultTable' class='listTable'></table>
    </div>

  </div> <!--end control box content -->
</div> <!--end control box  -->


<script type='text/ecmascript'>

  function getResults(){
    $('#results').show();
    $('#resultTable').dataTable({
      "bDestroy":true,
      'bAutoWidth': false,
      'bPaginate': false,
      'bInfo': false,
      'bFilter': false,
      'bSort': false,
      "sAjaxDataProp": "traceResults",
      "fnServerParams": function(aoData){ $.merge(aoData,$('#fe').serializeArray()); },
      "sAjaxSource": "php/trace.php",
      'aoColumns': [
        { 'sTitle': 'Hop', "mData":"Hop" },
        { 'sTitle': 'Address',"mData":"Address" },
        { 'sTitle': 'Time (ms)', "mData":"Time (ms)"   },
        { 'sTitle': 'Address 2' , "mData":"Address2" },
        { 'sTitle': 'Time (ms)', "mData":"Time2 (ms)" },
        { 'sTitle': 'Address 3', "mData":"Address3" },
        { 'sTitle': 'Time (ms)', "mData":"Time3 (ms)" }
        ]

     });
  };

</script>
