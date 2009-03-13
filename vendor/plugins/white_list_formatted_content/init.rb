ActiveRecord::Base.class_eval do
  include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper, WhiteListHelper
  def self.format_attribute(attr_name)
    class << self; include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper, WhiteListHelper; end
    define_method(:body)       { read_attribute attr_name }
    define_method(:body_html)  { read_attribute "#{attr_name}_html" }
    define_method(:body_html=) { |value| write_attribute "#{attr_name}_html", value }
    before_save :format_content
  end

  def dom_id
    [self.class.name.downcase.pluralize.dasherize, id] * '-'
  end

  protected
    def format_content
      body.strip! if body.respond_to?(:strip!)
      self.body_html = body.blank? ? '' : body_html_with_formatting
    end
    
    def body_html_with_formatting
      body_html = auto_link(body) { |text| truncate(text, 50) }
      #body_html = body.gsub(/\<图片\d+\>/) {|s| "<img src='#{Photo.find(s.scan(/\d+/)[0]).public_filename(:small)}'/>" }
      #textilized = RedCloth.new(body_html, [ :hard_breaks ])
      body_html = simple_format(body_html)
      textilized = auto_link(body_html)
      #textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
      white_list(textilized)
    end
  
end


