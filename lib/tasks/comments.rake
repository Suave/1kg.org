namespace :comments do
  desc "refactor comments to use one model"
  task :refactor => :environment do
    class ShareComment < Comment
    end
    class ActivityComment < Comment
    end
    class GuideComment < Comment
    end
    class BulletinComment < Comment
    end
    Comment.all.each do |comment|
      if comment.type != 'Comment'
        comment.commentable_id = comment.type_id
        
        if comment.type == 'ActivityComment'
          comment.commentable_type = 'Activity'
        elsif comment.type == 'ShareComment'
          comment.commentable_type = "Share"
        elsif comment.type == 'BulletinComment'
          comment.commentable_type = "Bulletin"
        elsif comment.type == 'GuideComment'
          comment.commentable_type = "SchoolGuide"
        end
        comment.type = 'Comment'
        comment.save(false)
      end
    end
  end
  
  desc "update comments count in parent"
  task :update_count => :environment do
    Share.all.each do |share|
      share.update_attribute(:comments_count, share.comments.count)
    end
    
    Activity.all.each do |activity|
      activity.update_attribute(:comments_count, activity.comments.count)
    end
    
    SchoolGuide.all.each do |guide|
      guide.update_attribute(:comments_count, guide.comments.count)
    end
    
    Bulletin.all.each do |bulletin|
      bulletin.update_attribute(:comments_count, bulletin.comments.count)
    end
    
    Topic.all.each do |topic|
      topic.update_attribute(:posts_count, topic.posts.count)
    end
  end
end