# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  def nav_menu(text, url, session_name)
    if session[:nav] == session_name
      return link_to(text, url, :class => "now")
    else
      return link_to(text, url)
    end
  end
  
  def month_and_day(datetime)
    "#{datetime.month}-#{datetime.day}"
  end
  
  def title_suffix
    "&middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp;"
  end
  
  def date_for_short(datetime)
    datetime.to_formatted_s(:month_and_day)
  end
  
  def customize_paginate(value, params={})
		str = will_paginate(value, params.merge({:previous_label => '<<',
                          :next_label => '>>'}))
		if str != nil
		str.gsub(/href="(.*?)"/) do
		  %(href='#{$1}#topicCommentsList')
		end
	        end
  end

  def will_paginate_remote(paginator, options={})
    update = options.delete(:update)
    url = options.delete(:url)
    str = will_paginate(paginator, options)
    if str != nil
      str.gsub(/href="(.*?)"/) do
        %(href='#' onclick="jQuery.get('#{(url ? url + $1.sub(/[^\?]*/, '') : $1)}', null, function(data) {jQuery('##{update}').html(data)}); return false;")
      end
    end
  end
  
  def schools_paginate(schools, geo=nil)
    will_paginate_remote(schools, :previous_label => '<<', 
                :next_label => '>>', 
                :update => 'schools', 
                :url => (geo.nil? ? geos_path : schools_geo_path(geo)))
  end



  def inbox_link(title="收件箱", user=current_user)
    if user.unread_messages.size > 0
      "<strong>" + link_to("#{title}(#{user.unread_messages.size})", user_received_index_path(user)) + "</strong> "
    else
      link_to title, user_received_index_path(user)
    end
  end
  
  def get_current_page_link
    url_for( :controller => request.path_parameters['controller'], :action => request.path_parameters['action'], :only_path => false)
  end
  
  
  
  def geo_select(object, method, extra_field=[], value=nil)
    geo_root = extra_field.blank? ? Geo.roots.collect{|g| [g.name, g.id]} : ([extra_field] + Geo.roots.collect{|g| [g.name, g.id]})

    if value.nil?
      inputs = select_tag("#{method}_root", "<option></option>" + options_for_select(geo_root))
      inputs << %Q"
        <span id='#{method}_container'>
          <select name='#{object}[#{method}_id]' id='#{object}_#{method}_id' disabled='disabled'>
            <option></option>
          </select>
        </span>
        "
    elsif value == 0
      geo_root_value = 0
      inputs = select_tag("#{method}_root", "<option></option>" + options_for_select(geo_root, geo_root_value.to_s))
      inputs << %Q"
        <span id='#{method}_container'>
          <select name='#{object}[#{method}_id]' id='#{object}_#{method}_id'>
            <option value='0' selected='selected'>不限区域</option>
          </select>
        </span>
        "
    else
      geo_root_value = Geo.find(value).parent_id.blank? ? value : Geo.find(value).parent_id
      inputs = select_tag("#{method}_root", "<option></option>" + options_for_select(geo_root, geo_root_value))
      if geo_root_value == value # 直辖市
        inputs << %Q"
          <span id='#{method}_container'>
            <select name='#{object}[#{method}_id]' id='#{object}_#{method}_id'>
              <option value='#{Geo.find(value).id}' selected='selected'>#{Geo.find(value).name}</option>
            </select>
          </span>
          "
      else
        inputs << %Q"
          <span id='#{method}_container'>
            <select name='#{object}[#{method}_id]' id='#{object}_#{method}_id'>
              #{options_for_select(Geo.find(value).self_and_siblings.collect{|g| [g.name, g.id]}, value)}
            </select>
          </span>
        "
      end
    end
    
    inputs << %Q"<img src='/images/indicator.gif' id='#{method}_indicator' class='indicator' style='display:none' />"
    #inputs << %(<script type="text/javascript" charset="utf-8">$().ready(function(){$("#school_geo_id").val('#{value}');});</script>)
    return inputs << observe_field("##{method}_root",
                                     :frequency => 0.25,
                                     :loading => "jQuery('##{method}_indicator').show()",
                                     :update => "##{method}_container",
                                     :url => { :controller => "/geos", :action => "geo_choice" },
                                     :with => "'root='+value+'&object=#{object}&method=#{method}'",
                                     :success => "jQuery('##{method}_indicator').hide()"
                                  )
  end
  
  def school_last_update(school)
    last_topic = school.last_topic
    return (last_topic ? link_to("#{last_topic.last_replied_datetime.to_date} by #{last_topic.last_replied_user.login}", board_topic_url(last_topic.board_id, last_topic.id, :anchor => (last_topic.last_post.id if last_topic.last_post))) : school.created_at.to_date)
  end
  
  def activity_last_update(activity)
    #last_topic = activity.discussion.board.topics.find(:first, :order => "last_replied_at desc")
    #return (last_topic ? link_to("#{last_topic.last_replied_datetime.to_date} by #{last_topic.last_replied_user.login}", board_topic_url(last_topic.board_id, last_topic.id, :anchor => (last_topic.last_post.id if last_topic.last_post))) : activity.updated_at.to_date)
    last_comment = activity.comments.find(:first, :order => "created_at desc", :select => "id, created_at, user_id")
    return (last_comment ? link_to("#{last_comment.created_at.to_date} by #{last_comment.user.login}", activity_url(activity)) : activity.updated_at.to_date)
    
  end
  
  def topic_last_update(topic)
    return link_to("#{topic.last_replied_datetime.to_date} by #{topic.last_replied_user.login}", board_topic_url(topic.board_id, topic.id, :anchor => (topic.last_post.id if topic.last_post)))
  end
  
  def activity_departure_name(activity)
    activity.departure_id==0 ? "不限" : activity.departure.name
  end
  
  def activity_arrival_name(activity)
    activity.arrival_id==0 ? "不限" : activity.arrival.name
  end
  
  def avatar_for(object, size)
    if object.class == User
      user_avatar_for(object, size)
    elsif object.class == Group
      group_avatar_for(object, size)
    end
  end
  
  def user_avatar_for(user, size)
    if user.avatar.blank?
      image_tag "avatar_#{size}.png", :class => "avatar", :alt => user.login
    else
      image_tag url_for_file_column(user, :avatar, size), :class => "avatar", :alt => user.login
    end
  end
  
  def group_avatar_for(group, size)
    if group.avatar.blank?
      image_tag "gavatar_#{size}.png", :class => "avatar", :alt => group.title
    else
      image_tag url_for_file_column(group, :avatar, size), :class => "avatar", :alt => group.title
    end
  end
  
  def link_for_new_school
    link_to image_tag("submit_school.png"), new_school_url
  end
  
  def link_for_new_activity
    link_to image_tag("submit_activity.png"), new_activity_url
  end
  
  def link_for_new_share
    link_to image_tag("submit_share.png"), new_share_url
  end
  
  def link_for_new_topic(board)
    link_to image_tag("submit_topic.png"), new_board_topic_url(board)
  end
  
  def link_for_new_group
    link_to image_tag("submit_group.png"), new_group_url
  end
  
  
  def link_for_activity(activity, show_sticky = true)
    return "#{image_tag("/images/stick.gif", :alt => "置顶活动", :title => "置顶活动") if show_sticky && activity.sticky?} #{link_to activity.title, activity_url(activity.id)}"
  end
  
  def link_to_topic_group(topic)
    talkable = topic.board.talkable
    
    if talkable.is_a?(SchoolBoard)
      link_to talkable.school.title, board_path(topic.board)
    elsif talkable.class == PublicBoard
      link_to talkable.title, board_path(topic.board)
    elsif talkable.class == CityBoard
      link_to talkable.geo.name, board_path(topic.board)
    else
      link_to talkable.group.title, group_path(talkable.group)
    end
  end
  
  def comments_path(commentable)
    if commentable.is_a?(SchoolGuide)
      [commentable.school, commentable, :comments]
    else
      [commentable, :comments]
    end
  end
  
  def edit_comment_path(comment)
    if comment.commentable.is_a?(SchoolGuide)
      [:edit, comment.commentable.school, comment.commentable, comment]
    else
      [:edit, comment.commentable, comment]
    end
  end
  
  def comment_path(comment)
    if comment.commentable.is_a?(SchoolGuide)
      [comment.commentable.school, comment.commentable, comment]
    else
      [comment.commentable, comment]
    end
  end
  
  def main_photo_thumb(school)
    img_url = school.main_photo.blank?  ? '/images/school_main_thumb.png' : school.main_photo.public_filename(:thumb)
    "<div class='school_list_photo'>"+ (link_to image_tag(img_url, :alt => school.title ),school_url(school)).to_s + "</div>"
  end
  
  def plain_text(text,replacement="")
    text = text.gsub(/<[^>]*>/){|html| replacement}
    text = text.gsub("&nbsp;","");
    text = text.gsub("\r\n","");
  end
  
  def summary(article,number)
    html = plain_text(article.body_html).mb_chars.slice(0..number).to_s.lstrip
  end
end
