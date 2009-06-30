module SchoolsHelper
  def radio_choice(form, object)
    [[0,"否"], [1,"是"], [2, "未知"]].collect {|r| form.radio_button(object, r[0]) + r[1]}
  end
  
  def radio_value(value)
    result = %w(没有 有 未知)
    value.blank? ? "未知" : result[value]
  end
  
  def validate_for_human(school)
    school.validated? ? "已通过验证" : "<span class=\"notice\">未通过验证</span>"
  end
  
  def edit_school_position_path(school)
    edit_school_path(school, :step => 'position')
  end
end