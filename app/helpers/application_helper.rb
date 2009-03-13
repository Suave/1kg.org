# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def nav_menu(text, url, session_name)
    if session[:nav] == session_name
      return link_to(text, url, :class => "now")
    else
      return link_to(text, url)
    end
  end
  
  def title_suffix
    "&middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp;"
  end
  
  def date_for_short(datetime)
    datetime.to_formatted_s(:month_and_day)
  end
  
  def customize_paginate(value)
		will_paginate value, :previous_label => '<<',
												 :next_label => '>>'
	end
	
  def inbox_link(title="收件箱", user=current_user)
    if user.unread_messages.size > 0
      "<strong>" + link_to("#{title}(#{user.unread_messages.size})", user_received_index_path(user)) + "</strong> "
    else
      link_to title, user_received_index_path(user)
    end
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
              #{options_for_select(Geo.find(value).self_and_siblings.collect{|g| [g.name, g.id]}, geo_root_value)}
            </select>
          </span>
        "
      end
    end
    
    inputs << %Q"<img src='/images/indicator.gif' id='#{method}_indicator' class='indicator' style='display:none' />"
    return inputs << observe_field("#{method}_root",
                                     :frequency => 0.25,
                                     :loading => "Element.show('#{method}_indicator')",
                                     :loaded => "Element.hide('#{method}_indicator')",
                                     :update => "#{method}_container",
                                     :url => { :controller => "/geos", :action => "geo_choice" },
                                     :with => "'root='+value+'&object=#{object}&method=#{method}'"
                                  )
  end
  
  def school_last_update(school)
    last_topic = school.discussion.board.topics.find(:first, :order => "last_replied_at desc")
    return (last_topic ? link_to("#{last_topic.last_replied_datetime.to_date} by #{last_topic.last_replied_user.login}", board_topic_url(last_topic.board_id, last_topic.id, :anchor => (last_topic.last_post.id if last_topic.last_post))) : school.updated_at.to_date)
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
  
  
end
