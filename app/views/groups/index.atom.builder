atom_feed do |feed|
  feed.title("多背一公斤最新话题")
  feed.updated(@recent_topics_in_all_groups.first.created_at)

  for topic in @recent_topics_in_all_groups
    feed.entry(topic, :url => board_topic_url(topic.board, topic)) do |entry|
      entry.title(topic.title)
      entry.content(topic.body_html, :type => 'html')

      entry.author do |author|
        author.name(topic.user.login)
      end
    end
  end
end
