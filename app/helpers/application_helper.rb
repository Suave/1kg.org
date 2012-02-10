# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  def month_and_day(datetime)
    "#{datetime.month}月#{datetime.day}日"
  end
  
  def full_date(date)
    "#{date.year == Date.today.year ? '' : "#{date.year}年"}#{date.month}月#{date.day}日"
  end
  
  def inbox_link(title="收件箱", user=current_user)
    if user.unread_messages.size > 0
      "<strong>" + link_to("#{title}(#{user.unread_messages.size})", user_received_index_path(user)) + "</strong> "
    else
      link_to title, user_received_index_path(user)
    end
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
  
  def activity_departure_name(activity)
    activity.departure_id==0 ? "不限" : activity.departure.name
  end
  
  def activity_arrival_name(activity)
    activity.arrival_id==0 ? "不限" : activity.arrival.name
  end
  
  def topic_photo_thumb(activity)
    "<div class='oto_frame'>"+ (link_to image_tag(img_url, :alt => activity.title ),activity_url(activity)).to_s + "</div>"
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
  
  def follow_to(followable)
    if logged_in? && current_user.is_following?(followable)
      button_to("正在关注",follow_path(followable.follows.find_by_user_id(current_user.id)),:method => :delete,:class=>"selected")
    else  
      button_to("+ 关注","#{follows_path}?followable_type=#{followable.class}&followable_id=#{followable.id}",:method => :post)
    end
  end

end
