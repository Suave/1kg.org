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


function copy_clip(meintext){
	if (window.clipboardData){   
		// the IE-manier
		window.clipboardData.setData("Text", meintext);   
		// waarschijnlijk niet de beste manier om Moz/NS te detecteren;
		// het is mij echter onbekend vanaf welke versie dit precies werkt:
   	}else if (window.netscape){    
		// dit is belangrijk maar staat nergens duidelijk vermeld:
		// you have to sign the code to enable this, or see notes below
		try {
			netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");   
		} catch (e) {   
			alert("按Ctrl+C复制链接地址，按Ctrl +V粘贴到聊天窗口发送给好友");
			return;   
		}   
		//netscape.security.PrivilegeManager.enablePrivilege('UniversalXPConnect');
		// maak een interface naar het clipboard
		var clip = Components.classes['@mozilla.org/widget/clipboard;1'].createInstance(Components.interfaces.nsIClipboard);
		if (!clip) return;

		// maak een transferable
		var trans = Components.classes['@mozilla.org/widget/transferable;1'].createInstance(Components.interfaces.nsITransferable);
		if (!trans) return;

		// specificeer wat voor soort data we op willen halen; text in dit geval
		trans.addDataFlavor('text/unicode');

		// om de data uit de transferable te halen hebben we 2 nieuwe objecten 
		// nodig om het in op te slaan
		var str = new Object();
		var len = new Object();

		var str = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);

		var copytext=meintext;		
		str.data=copytext;		
		trans.setTransferData("text/unicode",str,copytext.length*2);		
		var clipid=Components.interfaces.nsIClipboard;		
		if (!clip) return false;		
		clip.setData(trans,null,clipid.kGlobalClipboard);		
	} else {
		alert("按Ctrl+C复制链接地址，按Ctrl +V粘贴到聊天窗口发送给好友");
		return;   
	}
	alert("地址复制成功！ 按Ctrl+V 粘贴到聊天窗口发送给好友");
	return false;
}

function openInfoWindow(latlng, id)
{
  GDownloadUrl("/schools/info_window/" + id, function(data, responseCode) {
    map.openInfoWindowHtml(latlng, data);
  });
}
function markerClickFn(latlng, id) {
  return function() {
    openInfoWindow(latlng, id)
  }
}

function schoolClickFn(latlng, id, level)
{
  map.setCenter(latlng, level);
  openInfoWindow(latlng, id)
}

/* 根据用户选择的需求更新需求文本框 */
function update_needs(tag)
{
  needs = []
  $("." + tag + '_needs').each(function(i){
    if($(this).attr('checked')) {
      needs.push($(this).val());
    }
  });
  $("#"+tag+"_needs").val(needs.join(' '));
}