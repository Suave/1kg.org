atom_feed do |feed|
  feed.title("多背一公斤最新学校话题")
  feed.updated(@topics.first.created_at)

  for topic in @topics
    feed.entry(topic, :url => school_url(topic.board.talkable.school)) do |entry|
      entry.title(topic.title)
      entry.content(topic.body_html, :type => 'html')

      entry.author do |author|
        author.name(topic.user.login)
      end
    end
  end
end
