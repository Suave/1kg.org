atom_feed do |feed|
  feed.title("#{@topic.title}最新回复")
  feed.updated(@posts.first.created_at)

  for post in @posts
    feed.entry(@topic, :url => board_topic_url(@topic.board, @topic)) do |entry|
      entry.title(post.body_html)
      entry.content(post.body_html, :type => 'html')

      entry.author do |author|
        author.name(post.user.login)
      end
    end
  end
end
