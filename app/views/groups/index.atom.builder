atom_feed do |feed|
  feed.title("多背一公斤最新话题")
  feed.updated(@atom_topics.first.created_at)

  for topic in @atom_topics
    feed.entry(topic, :url => board_topic_url(topic.board, topic)) do |entry|
      entry.title(topic.title + ' (来自:1kg.org)')
      entry.content(topic.body_html, :type => 'html')

      entry.author do |author|
        author.name(topic.user.login)
      end
    end
  end
end
