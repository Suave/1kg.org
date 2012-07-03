module AntiSpam
  SPAM_WORDS = APP_CONFIG["spam_words"].split
  def check_spam_word_for(entry,attr)
    SPAM_WORDS.each do |w|
      return true if entry.attributes[attr].gsub(/ |　/,'').include? w
    end
    false
  end
end
