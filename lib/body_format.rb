module BodyFormat
  def sanitize(text, replace = false)
    html = text
    if replace
      html = text.dup
      
      html.gsub!(/<.*?>/, '')

      url_regex = /(?#Protocol)(?:(?:ht|f)tp(?:s?)\:\/\/|~\/|\/)?(?#Username:Password)(?:\w+:\w+@)?(?#Subdomains)(?:(?:[-\w]+\.)+(?#TopLevel Domains)(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel|[a-z]{2}))(?#Port)(?::[\d]{1,5})?(?#Directories)(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?#Query)(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?#Anchor)(?:#(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)?/i

      html.gsub!(url_regex) { |url|
        "<a href=\"#{url}\">#{url}</a>"
      }

      html.gsub!(/\r\n/, '<br />')
      html.gsub!(/\r/, '<br />')
      html.gsub!(/\n/, '<br />')
    end
    
    begin
      html = Sanitize.clean(html, :elements => ['a', 'div', 'span', 'img', 'p', 'embed', 'br',
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