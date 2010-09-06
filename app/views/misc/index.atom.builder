atom_feed do |feed|
  feed.title("多背一公斤最新帖子")
  feed.updated(@atom_shares.first.created_at)

  for share in @atom_shares
    feed.entry(share) do |entry|
      entry.title(share.title + ' (来自:1kg.org)')
      entry.content(share.body_html, :type => 'html')

      entry.author do |author|
        author.name(share.user.login)
      end
    end
  end
end
