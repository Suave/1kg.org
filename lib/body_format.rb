module BodyFormat
  def sanitize(html)
    Sanitize.clean(html, :elements => ['a', 'div', 'span', 'img', 'p', 'embed', 'em', 'ol', 'ul', 'li'],
          :attributes => {'a' => ['href', 'title'], 'img' => ['src', 'alt', 'title'], 'span' => ['style']},
          :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}})
  end
end