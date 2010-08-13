namespace :project do
  
  desc "公益项目状态判断"
  task :update_state => :environment do
    Project.state_is("validated").map{|p| p.start if 1.day.from_now > p.start_at}
    Project.state_is("going").map{|p| p.finish if 1.day.from_now > p.end_at}
    SubProject.state_is("validated").map{|p| p.start if 1.day.from_now > p.project.start_at}
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
        b = SubProject.new(
          :project_id => a.id,
          :user_id => s.applicator_id,
          :school_id => s.school_id,
          :state =>  ['finished','validated','waiting'][s.status.to_i],
          :validated_at => s.validated_at,
          :validated => s.validated,
          :validated_by_id => s.validated_by_id,
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
        b.save
        s.shares.each do |x|
          x.sub_project_id = b.id
          x.save
        end
        s.comments.each do |c|
          c.commentable_id = b.id
          c.commentable_type = 'SubProject'
          c.save
        end
      end
      
    end
  end  


end