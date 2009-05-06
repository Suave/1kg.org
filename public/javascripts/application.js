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