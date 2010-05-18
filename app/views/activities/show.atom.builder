atom_feed do |feed|
  feed.title("#{@activity.title}最新回复")
  feed.updated(@comments.first.created_at)

  for comment in @comments
    feed.entry(@activity) do |entry|
      entry.title(comment.body)
      entry.content(comment.body_html, :type => 'html')

      entry.author do |author|
        author.name(comment.user.login)
      end
    end
  end
end
