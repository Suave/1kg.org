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
  } else if(kind == 'group') {
    if(search_box_can_clear()) {
      $("#query-box").val('小组名称,描述...');
    }
  } else if(kind == 'topic') {
    if(search_box_can_clear()) {
      $("#query-box").val('话题标题,正文,回帖...');
    }
  } else if(kind == 'topic') {
    if(search_box_can_clear()) {
      $("#query-box").val('搜索学校,活动,话题...');
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
  if(val == '活动标题,城市,介绍...' || val == '学校名称,地址,城市,需求...' || val == '攻略标题,学校名称,城市...' 
      || val == '' || val == '小组名称,描述...' || val == "话题标题,正文,回帖..." || val == "搜索学校,活动,话题...") {
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
    } else if($("#kind_group").attr('checked') == true) {
      $("#query-box").val('小组名称,描述...');
    } else if($("#kind_topic").attr('checked') == true) {
      $("#query-box").val('话题标题,正文,回帖...');
    } else {
      $("#query-box").val('搜索学校,活动,话题...');
      $("#kind_all").attr('checked', true)
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
  if($("#kind_school").attr('checked') == true) {
    $("#advance_school").toggle();
    $("#advance_search").toggle();
  } else if($("#kind_activity").attr('checked') == true) {
    $("#advance_activity").toggle();
    $("#advance_search").toggle();    
  } else if($("#kind_share").attr('checked') == true) {
    $("#advance_share").toggle();
    $("#advance_search").toggle();
  }
}