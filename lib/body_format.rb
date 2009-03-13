module BodyFormat
  def formatting_body_html(body)
    body_html = auto_link(body, :link => :urls) { |text| truncate(text, 50) }
    body_html = simple_format(body_html)
    white_list(body_html)
  end
end