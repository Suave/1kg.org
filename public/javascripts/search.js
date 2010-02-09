$(document).ready(function(){
  search_box_blur();
});

function switch_search_to(kind)
{
  if(kind == 'school')
  {
    if($("#query-box").val() == "" || $("#query-box").val() == '活动标题,城市,介绍...') {
      $("#query-box").val('学校名称,地址,城市,需求...');
    }
  } else if(kind == 'activity') {
    if($("#query-box").val() == "" || $("#query-box").val() == '学校名称,地址,城市,需求...') {
      $("#query-box").val('活动标题,城市,介绍...');
    }
  }
  
  $("#advance_school").hide();
  $("#advance_activity").hide();
  $("#advance_search").hide();  
}

function search_box_blur()
{
  if($("#query-box").val() == ""){
    if($("#kind_school").attr('checked') == true) {
      $("#query-box").val('学校名称,地址,城市,需求...');
    } else if($("#kind_activity").attr('checked') == true) {
      $("#query-box").val('活动标题,城市,介绍...');
    }
  }
}

function clear_search_box()
{
  if($("#query-box").val() == '学校名称,地址,城市,需求...' || $("#query-box").val() == '活动标题,城市,介绍...') {
    $("#query-box").val('');
  }
}

function toggle_advanced_search()
{
  $("#advance_search").toggle();

  if($("#kind_school").attr('checked') == true) {
    $("#advance_school").toggle();
  } else if($("#kind_activity").attr('checked') == true) {
    $("#advance_activity").toggle();
  }
}