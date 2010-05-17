atom_feed do |feed|
  feed.title("多背一公斤最新话题")
  feed.updated(@recent_shares.first.created_at)

  for share in @recent_shares
    feed.entry(share) do |entry|
      entry.title(share.title)
      entry.content(share.body_html, :type => 'html')

      entry.author do |author|
        author.name(share.user.login)
      end
    end
  end
end
