atom_feed do |feed|
  feed.title("多背一公斤最新活动")
  feed.updated(@activities.first.created_at)

  for activity in @activities
    feed.entry(activity) do |entry|
      entry.title(activity.title)
      entry.content(activity.description_html, :type => 'html')

      entry.author do |author|
        author.name(activity.user.login)
      end
    end
  end
end
