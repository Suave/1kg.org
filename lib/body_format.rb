module BodyFormat
  def sanitize(html)
    begin
      Sanitize.clean(html, :elements => ['a', 'div', 'span', 'img', 'p', 'embed',
        'em', 'ol', 'ul', 'li', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'tt'],
          :attributes => {'a' => ['href', 'title'], 'img' => ['src', 'alt', 'title'], 'span' => ['style']},
          :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}})
    rescue
      html
    end
  end
end