# -*- encoding : utf-8 -*-
module RequirementTypesHelper

  def feedbacks_check_box(form, tag, value)
      text = '<p>需上传照片：  '
      text << [['物资签收单',"need_list"],['物资签收照片',"need_list_photo"],['发票/收据照片',"invoice_photo"],['感谢信照片',"letter_photo"],['项目开展照片',"project_photo"]].map do |option|
        included = value.nil? ? false : value.include?(option[0])
        check_box_tag(tag, option[0], included,:name => "project[#{option[1]}]") + 
        form.label(tag, option[0], {:class => 'checkbox_label'})
      end.join
      text << "</p><p>项目进展记录更新频率（分享或项目反馈）： "
      text << select('project[frequency]',nil,[['每日一次','每日一次'],['每周一次','每周一次'],['每月一次','每月一次'],['每季度一次','每季度一次']], {:selected => (['每月一次','每周一次','每月一次','每季度一次'].map{|option| option if !value.nil? && value.include?(option)}.<<('每月一次').compact[0]) } )
      text << "</p><p>其他要求：  "
      text << [['邮寄感谢信',"post_letter"],["项目执行报告","report"]].map do |option|
        included = value.nil? ? false : value.include?(option[0])
        check_box_tag(tag, option[0], included,:name => "project[#{option[1]}]") + 
        form.label(tag, option[0], {:class => 'checkbox_label'})
      end.join
      text << "</p>"
  end
  
end
