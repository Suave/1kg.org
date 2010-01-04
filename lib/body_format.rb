module BodyFormat
  def sanitize(html, replace = false)
    if replace
      html.gsub!(/\r\n/, '<br />')
      html.gsub!(/\r/, '<br />')
      html.gsub!(/\r/, '<br />')
    end
    
    begin
      Sanitize.clean(html, :elements => ['a', 'div', 'span', 'img', 'p', 'embed', 'br',
        'em', 'ol', 'ul', 'li', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'tt', 'param', 'object'],
          :attributes => {'a' => ['href', 'target', 'title'], 
            'img' => ['src', 'alt', 'title'], 
            'span' => ['style'],
            'object' => ['width', 'height'],
            'param' => ['name', 'value'],
            'embed' => ['src', 'type', 'allowscriptaccess', 'allowfullscreen', 'wmode', 'width', 'height']})
    rescue
      html
    end
  end
end