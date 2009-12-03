module BodyFormat
  def sanitize(html)
    Sanitize.clean(html, :elements => ['a', 'div', 'img', 'p', 'embed'],
          :attributes => {'a' => ['href', 'title'], 'img' => ['src', 'alt', 'title']},
          :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}})
  end
end