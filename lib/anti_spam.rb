module AntiSpam
  SPAMWORD = %w(　 小姐 考级 考试答案 考前答案 性服务 小妹 淘宝 媛交 按摩服务 全套服务 特殊服务 妓 夜情 你妹 找美女)
  def check_spam_word_for(entry,attr)
    SPAMWORD.each do |w|
      return true if entry.attributes[attr].include? w
    end
    false
  end
end
