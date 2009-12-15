module BodyFormat
  def sanitize(html)
    begin
      Sanitize.clean(html, :elements => ['a', 'div', 'span', 'img', 'p', 'embed', 'br',
        'em', 'ol', 'ul', 'li', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'tt'],
          :attributes => {'a' => ['href', 'target', 'title'], 'img' => ['src', 'alt', 'title'], 'span' => ['style']})
    rescue
      html
    end
  end
end