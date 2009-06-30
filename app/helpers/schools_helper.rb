module SchoolsHelper
  def radio_choice(form, object)
    [[0,"否"], [1,"是"], [2, "未知"]].collect {|r| form.radio_button(object, r[0]) + r[1]}
  end
  
  def radio_value(value)
    result = %w(没有 有 未知)
    value.blank? ? "未知" : result[value]
  end
  
  def validate_for_human(school)
    !school.validated_at.blank? ? "#{school.validated_at.to_date} 通过验证" : "<span class=\"notice\">学校信息未验证</span>"
  end
  
  def edit_school_position_path(school)
    edit_school_path(school, :step => 'position')
  end
end