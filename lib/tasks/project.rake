namespace :project do
  
  desc "公益项目状态判断"
  task :update_state => :environment do
    Project.state_is("validated").map{|p| p.start if 1.day.from_now > p.start_at}
    Project.state_is("going").each do |p|
      if 1.day.from_now > p.end_at
        p.finish
        p.executions.validated.map {|e| e.finish}
        message = Message.new(:subject => "你发起的公益项目#{p.title}已经结束",
                              :content => "<p>你好，#{p.user.login}:</p><br/><p>按照你的时间计划，你发起的公益项目#{p.title}已经结束了。</p>\
                                           <br/><p>至此所有的公益项目执行也都结束了，请查看每个项目的反馈内容来了解项目的执行情况。 => http://www.1kg.org/projects/#{p.id}</p>\
                                           <br/>再次感谢你发起的公益项目，希望执行的结果能够让你满意。\
                                           <br/><br/><p>多背一公斤团队</p>"
                                )
        message.author_id = 0
        message.to = [p.user]
        message.save!
        
      end
    end
    Execution.state_is("validated").map{|p| p.start if 1.day.from_now > p.project.start_at}
  end  

  desc "公益项目数据迁移"
  task :old_data_copy => :environment do
    RequirementType.non_exchangable.validated.each do |r|
      a = Project.new(
                  :user_id  => r.creator_id,
                  :title => r.title,
                  :state => "going",
                  :validated_at => r.validated_at,
                  :created_at => r.created_at,
                  :updated_at => r.updated_at,
                  :description => r.description_html,
                  :support => r.support_html,
                  :condition => r.condition_html,
                  :feedback_require => r.feedback_require,
                  :image_file_name => r.image_file_name,
                  :start_at => r.start_at,
                  :end_at => r.end_at,
                  :for_envoy => r.must,
                  :apply_end_at => r.apply_end_at,
                  :feedback_at => r.feedback_at
                  )
      puts a.save
      
      r.comments.each do |m|
        m.commentable_id = a.id
        m.commentable_type = 'Project'
        m.save
      end
    
      r.requirements.each do |s|
        b = Execution.new(
          :project_id => a.id,
          :user_id => s.applicator_id,
          :school_id => s.school_id,
          :state =>  ['finished','validated','waiting'][s.status.to_i],
          :validated_at => s.validated_at,
          :validated_by_id => (s.validated ? 1 :nil),
          :plan => s.apply_plan,
          :reason => s.apply_reason,
          :feedback => s.feedback,
          :problem => s.problem,
          :budget => s.budget,
          :start_at => s.start_at,
          :end_at => s.end_at,
          :telephone => s.applicator_telephone,
          :created_at => s.created_at,
          :last_modified_at => s.last_modified_at
        )
        puts "#{b.save} #{s.id}"
        s.shares.each do |x|
          x.execution_id = b.id
          x.save
        end
        s.photos.each do |x|
          x.execution_id = b.id
          x.save
        end
        s.comments.each do |c|
          c.commentable_id = b.id
          c.commentable_type = 'Execution'
          c.save
        end
      end
      
    end
  end  


end