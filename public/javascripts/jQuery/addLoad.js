/*
 * Script for jQuery Effects
 */

$(document).ready(function(){
  
	$("#commonUse > li:last-child").css({
    margin: "0"
	});
  
  /* jQuery.Cycle */
	$('#headline ul')
  .before('<div id="headlineMenu">')
  .cycle({
		fx: 'fade',
		speed: 'slow',
		pause: 1,
		timeout: 50000,
		pager: '#headlineMenu'
	});
  
});