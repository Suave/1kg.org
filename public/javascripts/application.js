// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function CheckAll(value) 
{
    var boxes=document.getElementsByTagName("input");
    for(var i=0; i<boxes.length; i++) {
        if (boxes[i].type=='checkbox') {
            boxes[i].checked=value;
        }
    }
}

function markerClickFn(point, id) {
  return function() {
    map.openInfoWindowHtml(point, "<div id='map_popup' style='width: 480px; height: 420px;'></div>");
    GDownloadUrl("/schools/info_window/" + id, function(data, responseCode) {
      jQuery('#map_popup').html(data);
    });
  }
}

function schoolClickFn(latlng, id, level)
{
  map.setCenter(latlng, level);
  map.openInfoWindowHtml(latlng, "<div id='map_popup' style='width: 480px; height: 420px;'></div>");  
  GDownloadUrl("/schools/info_window/" + id, function(data, responseCode) {
    jQuery('#map_popup').html(data);
  });
}