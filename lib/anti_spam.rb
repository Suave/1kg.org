module AntiSpam
  SPAMWORD = %w(小姐 考级 考试答案 考前答案 性服务 小妹 淘宝)
  def check_spam_word_for(entry,attr)
    SPAMWORD.each do |w|
      return true if entry.attributes[attr].include? w
    end
    false
  end
end
