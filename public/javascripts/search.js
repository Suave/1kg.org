$(document).ready(function(){
  search_box_blur();
});

function switch_search_to(kind)
{
  if(kind == 'school')
  {
    if(search_box_can_clear()) {
      $("#query-box").val('学校名称,地址,城市,需求...');
    }
  } else if(kind == 'activity') {
    if(search_box_can_clear()) {
      $("#query-box").val('活动标题,城市,介绍...');
    }
  } else if(kind == 'share') {
    if(search_box_can_clear()) {
      $("#query-box").val('攻略标题,学校名称,城市...');
    }
  }
  
  $("#advance_school").hide();
  $("#advance_activity").hide();
  $("#advance_search").hide();
  $("#advance_share").hide();
}

function search_box_can_clear()
{
  var val = $("#query-box").val();
  if(val == '活动标题,城市,介绍...' || val == '学校名称,地址,城市,需求...' || val == '攻略标题,学校名称,城市...' || val == '') {
    return true;
  }
  return false;
}

function search_box_blur()
{
  if($("#query-box").val() == ""){
    if($("#kind_school").attr('checked') == true) {
      $("#query-box").val('学校名称,地址,城市,需求...');
    } else if($("#kind_activity").attr('checked') == true) {
      $("#query-box").val('活动标题,城市,介绍...');
    } else if($("#kind_share").attr('checked') == true) {
      $("#query-box").val('攻略标题,学校名称,城市...');
    } else {
      $("#query-box").val('学校名称,地址,城市,需求...');
      $("#kind_school").attr('checked', true)
    }
  }
}

function clear_search_box()
{
  if(search_box_can_clear()) {
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
  } else if($("#kind_share").attr('checked') == true) {
    $("#advance_share").toggle();
  }
}