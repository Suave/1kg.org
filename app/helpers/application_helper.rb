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
    "#{datetime.month}月#{datetime.day}日"
  end
  
  def title_suffix
    "&middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp; &middot;&nbsp;"
  end
  
  def date_for_short(datetime)
    datetime.to_formatted_s(:month_and_day)
  end
  
  def format_date(date)
    "#{date.year == Date.today.year ? '' : "#{date.year}年"}#{date.month}月#{date.day}日"
  end
  
  def full_date(date)
    date.strftime("%Y-%m-%d %X")
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
        %(href='#' onclick="$('#loading').show();jQuery.ajax({url:'#{(url ? url + $1.sub(/[^\?]*/, '') : $1)}', success: function(data) {jQuery('##{update}').html(data);$('#loading').hide();}}); return false;")
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
  
  def short_text(text,length=20)
    text.gsub('<\br>','\n').gsub(/<.*?>/,'').mb_chars.slice(0..length).to_s.lstrip + (text.mb_chars[length].nil?? "" : "...") if text
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
              <option value='#{Geo.find(value).id}' selected='selected'>#{Geo.find(value).name}</option>
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
    return (last_topic ? link_to("#{last_topic.last_replied_datetime.to_date} by #{last_topic.last_replied_user.login}", board_topic_url(last_topic.board_id, last_topic.id, :anchor => (last_topic.comments.last.id if last_topic.comments.last))) : school.created_at.to_date)
  end
  
  def activity_last_update(activity)
    #last_topic = activity.discussion.board.topics.find(:first, :order => "last_replied_at desc")
    #return (last_topic ? link_to("#{last_topic.last_replied_datetime.to_date} by #{last_topic.last_replied_user.login}", board_topic_url(last_topic.board_id, last_topic.id, :anchor => (last_topic.comments.last.id if last_topic.comments.last))) : activity.updated_at.to_date)
    last_comment = activity.comments.find(:first, :order => "created_at desc", :select => "id, created_at, user_id")
    return (last_comment ? link_to("#{last_comment.created_at.to_date} by #{last_comment.user.login}", activity_url(activity)) : activity.updated_at.to_date)
    
  end
  
  def topic_last_update(topic)
    return link_to("#{topic.last_replied_datetime.to_date} by #{topic.last_replied_user.login}",topic_url(topic, :anchor => (topic.comments.last.id if topic.comments.last)))
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
    elsif object.class == Team
      size_list = {'small' => '16px','large' => '48px'}
      image_tag object.image(:team_icon),:style => "width:#{size_list[size]};height:#{size_list[size]}"
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
  
  def link_for_activity(activity, show_sticky = true)
    return "#{image_tag("/images/stick.gif", :alt => "置顶活动", :title => "置顶活动") if show_sticky && activity.sticky?} #{link_to activity.title, activity_url(activity.id)}"
  end
  
  def main_photo_thumb(school,style="")
    img_url = school.main_photo.blank?  ? '/images/school_main_thumb.png' : school.main_photo.image.url
    "<div class='school_list_photo'>"+ (link_to image_tag(img_url, :alt => school.title,:style => style ),school_url(school)).to_s + "</div>"
  end
  
  def topic_photo_thumb(activity)
    img_url = activity.main_photo.blank?  ? "/images/activity_thumb_#{activity.category}.png" : activity.main_photo.image.url
    "<div class='activity_photo_frame'><div class='activity_list_photo'>"+ (link_to image_tag(img_url, :alt => activity.title ),activity_url(activity)).to_s + "</div></div>"
  end
  
  def plain_text(text,replacement="")
    text = text.gsub(/<[^>]*>/, '')
    text.gsub!("&nbsp;","");
    text.gsub!("\r\n","");
    text
  end
  
  def summary(article,number)
    html = article.clean_html || article.body_html
    plain_text(html).mb_chars.slice(0..number).to_s.lstrip
  end
  
  def html_summary(article,start,close)
    html = (article.clean_html?? article.clean_html : article.body_html).mb_chars.slice(start..close).to_s.lstrip
  end
  
  def short_title(something,long=22)
    something.title.mb_chars.slice(0..long).to_s.lstrip + (something.title.mb_chars[long].nil?? "" : "...")
  end

  def photo_meta(photo, current_user)
    photo.user_id = 1 if photo.user.nil?
    
    html = content_tag(:p) do
      meta = link_to(photo.user.login, user_url(photo.user)) + '上传于' + photo.created_at.to_date.to_s + ' '
      meta
    end

    html += "<p>上传于 #{link_to photo.photoable.name,photo.photoable }</p>" 
    html += "<p>#{h(photo.description)}</p>"
    html
  end
  
  def envoy_badge(user)
    "<img src='/images/badge.gif' title='#{user.login}是学校大使' class='envoy_badge'/>" if user.envoy?
  end
  
  def upload_script_for(id, container, url)
    javascript_tag(%(
      var swfu;
      jQuery(document).ready(function () {
        swfu = new SWFUpload({
          // Backend Settings
          upload_url: "#{url}",

          // File Upload Settings
          file_size_limit : "2 MB", // 2MB
          file_types : "*.jpg; *.JPG; *.jpeg; *.JPEG; *.PNG; *.png; *.GIF; *.gif",
          file_types_description : "所有图片文件",
          file_upload_limit : "0",
          file_queue_limit: 0,
          post_params: {
            authenticity_token: "#{u(form_authenticity_token)}"
          },

          // Event Handler Settings - these functions as defined in Handlers.js
          //  The handlers are not part of SWFUpload but are part of my website and control how
          //  my website reacts to the SWFUpload events.
          file_queue_error_handler : fileQueueError,
          file_dialog_complete_handler : fileDialogComplete,
          upload_progress_handler : uploadProgress,
          upload_error_handler : uploadError,
          upload_success_handler : uploadSuccess,
          upload_complete_handler : uploadComplete,

          // Button Settings
          button_image_url : "/images/buttonlink.gif",
          button_placeholder_id : "#{id}",
          button_width: 64,
          button_height: 21,
          button_text : '<a><font color="#ffffff">上传照片</font></a>',
          button_text_top_padding: 0,
          button_text_left_padding: 6,
          button_window_mode: SWFUpload.WINDOW_MODE.WINDOW,
          button_cursor: SWFUpload.CURSOR.HAND,

          // Flash Settings
          flash_url : "/swfs/swfupload.swf",

          custom_settings : {
            upload_target : "#{container}"
          },

          // Debug Settings
          debug: false
        });
      });
    ))
  end
  
  def state_tag(state)
    state_attr = {
     :waiting => ['#666',"待验证"],
     :refused => ['#666',"已拒绝"],
     :validated => ['#33c',"已验证"],
     :going => ['#c33',"进行中"],
     :finished => ['#600',"已结束"]
     }[state.to_sym]
     "<span style='color:#{state_attr[0]}'>#{state_attr[1]}</span>"
  end
  
  def upload_button(container, url)
    html = upload_script_for("upload", container, url)
    html += content_tag(:span, :id => "upload") do
      "上传照片"
    end
    html
  end
  
  def photo_upload_path_with_session(category=nil,id=nil)
    session_key = ActionController::Base.session_options[:key] || '_1kg_org_session'
    if category
      photos_path("photo[#{category}_id]" => id, session_key => cookies[session_key])
    else
      photos_path(session_key => cookies[session_key])
    end
  end

  def follow_to(followable)
    if logged_in? && current_user.is_following?(followable)
      link_to("正在关注",follow_path(followable.follows.find_by_user_id(current_user.id)),:method => :delete,:class=>"selected buttonlink")
    else  
      link_to("+ 关注","#{follows_path}?followable_type=#{followable.class}&followable_id=#{followable.id}",:method => :post,:class => "buttonlink")
    end
  end

end
