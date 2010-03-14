// CHANGE FOR APPS HOSTED IN SUBDIRECTORY
FCKRelativePath = '';

// DON'T CHANGE THESE
FCKConfig.LinkBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Connector='+FCKRelativePath+'/fckeditor/command';
FCKConfig.ImageBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Type=Image&Connector='+FCKRelativePath+'/fckeditor/command';
FCKConfig.FlashBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Type=Flash&Connector='+FCKRelativePath+'/fckeditor/command';

FCKConfig.LinkUploadURL = FCKRelativePath+'/fckeditor/upload';
FCKConfig.ImageUploadURL = FCKRelativePath+'/fckeditor/upload?Type=Image';
FCKConfig.FlashUploadURL = FCKRelativePath+'/fckeditor/upload?Type=Flash';
FCKConfig.SpellerPagesServerScript = FCKRelativePath+'/fckeditor/check_spelling';
FCKConfig.AllowQueryStringDebug = true;
FCKConfig.SpellChecker = 'SpellerPages';

// ONLY CHANGE BELOW HERE
FCKConfig.SkinPath = FCKConfig.BasePath + 'skins/silver/';
/* sample
FCKConfig.ToolbarSets["Simple"] = [
	['Source','-','-','Templates'],
	['Cut','Copy','Paste','PasteWord','-','Print','SpellCheck'],
	['Undo','Redo','-','Find','Replace','-','SelectAll'],
	'/',
	['Bold','Italic','Underline','StrikeThrough','-','Subscript','Superscript'],
	['OrderedList','UnorderedList','-','Outdent','Indent'],
	['JustifyLeft','JustifyCenter','JustifyRight','JustifyFull'],
	['Link','Unlink'],
	'/',
	['Image','Table','Rule','Smiley'],
	['FontName','FontSize'],
	['TextColor','BGColor'],
	['-','About']
] ;
*/
FCKConfig.ToolbarSets["Simple"] = [
	['Source'],
	['Cut','Copy','Paste','PasteWord'],
	['Undo','Redo','-','Find','Replace','-','SelectAll'],
	'/',
	['Bold','Italic','Underline','StrikeThrough','-','Subscript','Superscript'],
	['OrderedList','UnorderedList','-','Outdent','Indent'],
	['JustifyLeft','JustifyCenter','JustifyRight'],
	['Link','Unlink'],
	'/',
	['FontName','FontSize'],
	['Image','Smiley'],
	['TextColor','BGColor']
] ;

FCKConfig.ToolbarSets["Post"] = [
	['Source'],
	['Cut','Copy','Paste','PasteWord'],
	['Undo','Redo'],
	'/',
	['Bold','Italic','StrikeThrough'],
	['TextColor','BGColor'],
	['OrderedList','UnorderedList'],
	['Link','Unlink'],
	['Image','Smiley']
] ;
FCKConfig.ToolbarSets["OneLine"] = [
	['Undo','Redo'],
	['Cut','Copy','Paste','PasteWord'],
	['Bold','Italic','StrikeThrough'],
	['JustifyLeft','JustifyCenter','JustifyRight'],
	['OrderedList','UnorderedList'],
	['TextColor','BGColor'],
	['Link','Unlink'],
	['Image','Smiley'],
	['Source']
] ;
FCKConfig.ToolbarSets["Image"] = [
	['Image'],
	['Source']
] ;