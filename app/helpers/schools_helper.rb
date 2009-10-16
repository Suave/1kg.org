module SchoolsHelper
  def radio_choice(form, object)
    [[0,"无"], [1,"有"], [2, "未知"]].collect {|r| form.radio_button(object, r[0]) + r[1]}
  end
  
  def radio_value(value)
    result = %w(没有 有 未知)
    value.blank? ? "未知" : result[value]
  end
  
  def validate_for_human(school)
    if school.validated?
      if school.validator
        "#{school.validated_at.to_date}由#{link_to school.validator.login, user_url(school.validator)}验证"
      else
        "#{school.validated_at.to_date}通过验证"
      end
    else
      if school.validated_at.blank?
        "<span class=\"required\">学校信息未验证</span>"
      elsif school.validator
        "<span class=\"required\">#{school.validated_at.to_date}由#{link_to school.validator.login, user_url(school.validator)}取消验证</span>"
      elsif school.validated_at && !school.validator.blank?
        "<span class=\"required\">#{school.validated_at.to_date}取消验证</span>"
      end

    end
  end
  
  def edit_school_position_path(school)
    edit_school_path(school, :step => 'position')
  end
  
  def render_school_main_photo(school)
    html = ''
    if school.main_photo
      html += image_tag(school.main_photo.public_filename(:small))
    else
      html += image_tag(image_path('/images/default_school.jpg'), :width => "200")
    end
    html
  end
  
  def photo_meta(photo, current_user)
    photo.user_id = 1 if photo.user.nil?
    
    html = content_tag(:p) do
      meta = link_to(photo.user.login, user_url(photo.user)) + '上传于' + photo.created_at.to_date.to_s
      meta += link_to("删除", photo_url(photo), :method => :delete, :confirm => "此操作不能撤销，确定删除么？") if photo.edited_by(current_user)
      meta
    end

    html += "<p>拍摄于 #{link_to photo.school.title, school_url(photo.school)}</p>" unless photo.school.blank?
    html += "<p>分享到 #{link_to photo.activity.title, activity_url(photo.activity)}</p>" unless photo.activity.blank?
    html += "<p>#{h(photo.description)}</p>"
    html
  end
  
  def needs_check_box(form, tag, options, value)
    other_needs = value
    options.map do |option|
      included = value.nil? ? false : value.include?(option)
      other_needs.sub!(option, '') if value && included
      check_box_tag(tag, option, included, :onchange => "update_needs('#{tag.to_s}')", :class => "#{tag}_needs") + 
      form.label(tag, option, {:class => 'checkbox_label'})
    end.join + form.hidden_field(tag, :id => "#{tag}_needs") +
    label_tag(" 其它 ") +
    text_field_tag("other_#{tag}_need", '', :size => '10', :onchange => "update_needs('#{tag.to_s}')", 
                      :value => other_needs)
  end
end