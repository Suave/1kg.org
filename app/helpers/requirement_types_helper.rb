module RequirementTypesHelper

  def feedbacks_check_box(form, tag, value)
    # 对秀秀和多背一公斤显示文本框模式
      text = '<p>照片：  '
      text << ['物资签收单','物资签收照片','发票/收据照片','项目开展照片'].map do |option|
        included = value.nil? ? false : value.include?(option)
        check_box_tag(tag, option, included, :onchange => "update_needs('#{tag.to_s}')", :class => "#{tag}_needs") + 
        form.label(tag, option, {:class => 'checkbox_label'})
      end.join + form.hidden_field(tag, :id => "#{tag}_needs")
      text << "</p><p>项目进展记录要求： "
      text << select ('school[basic_attributes]',:level_amount,[['每日一次','每日一次'],['每周一次','每周一次'],['每月一次','每月一次'],['每季度一次','每季度一次']], {:selected => (['每月一次','每周一次','每月一次','每季度一次'].map{|option| option if !value.nil? && value.include?(option) }.<<('每月一次').compact[0]  )} )
      text << "</p><p>感谢信： "
      text << ['照片','邮寄'].map do |option|
        included = value.nil? ? false : value.include?(option)
        check_box_tag(tag, option, included, :onchange => "update_needs('#{tag.to_s}')", :class => "#{tag}_needs") + 
        form.label(tag, option, {:class => 'checkbox_label'})
      end.join + form.hidden_field(tag, :id => "#{tag}_needs")
      text << "</p>"
  end
  
end