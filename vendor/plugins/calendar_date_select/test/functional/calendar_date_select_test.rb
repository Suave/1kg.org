  require File.join(File.dirname(__FILE__), '../test_helper.rb')

class HelperMethodsTest < Test::Unit::TestCase
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  
  include CalendarDateSelect::FormHelper
  
  def setup
    @controller = ActionController::Base.new
    @request = OpenStruct.new
    @controller.request = @request
    
    @model = OpenStruct.new
  end
  
  def test_mixed_time__model_returns_date__should_render_without_time
    @model.start_datetime = Date.parse("January 2, 2007")
    output = calendar_date_select(:model, :start_datetime, :time => "mixed")
    assert_no_match(/12:00 AM/, output, "Shouldn't have outputted a time")
  end
  
  def test_mixed_time__model_returns_time__should_render_with_time
    @model.start_datetime = Time.parse("January 2, 2007 12:00 AM")
    output = calendar_date_select(:model, :start_datetime, :time => "mixed")
    assert_match(/12:00 AM/, output, "Should have outputted a time")
  end
  
  def test_time_true__model_returns_date__should_render_with_time
    @model.start_datetime = Date.parse("January 2, 2007")
    output = calendar_date_select(:model, :start_datetime, :time => "true")
    assert_match(/12:00 AM/, output, "Should have outputted a time")
  end
  
  def test_time_false__model_returns_time__should_render_without_time
    @model.start_datetime = Time.parse("January 2, 2007 12:00 AM")
    output = calendar_date_select(:model, :start_datetime)
    assert_no_match(/12:00 AM/, output, "Shouldn't have outputted a time")
  end
  
  def test__nil_model__shouldnt_populate_value
    @model = nil
    output = calendar_date_select(:model, :start_datetime)
    
    assert_no_match(/value/, output)
  end
  
  def test__vdc__should_auto_format_function
    @model.start_datetime = Time.parse("January 2, 2007 12:00 AM")
    output = calendar_date_select(:model, 
      :start_datetime, 
      :valid_date_check => "date < new Date()"
    )
    assert_match("valid_date_check:function(date) { return(date &lt; new Date()) }", output)
    
    output = calendar_date_select(:model, 
      :start_datetime, 
      :valid_date_check => "return(date < new Date())"
    )
    assert_match("valid_date_check:function(date) { return(date &lt; new Date()) }", output)
    output = calendar_date_select(:model, 
      :start_datetime, 
      :valid_date_check => "function(p) { return(date < new Date()) }"
    )
    assert_match("valid_date_check:function(p) { return(date &lt; new Date()) }", output)
  end
  
  def test__vdc__excluded_return__should_raise_error
    throw_message = ":valid_date_check function is missing a 'return' statement.  Try something like: :valid_date_check => 'if (date > new(Date)) return true; else return false;'"
    assert_throws throw_message.to_sym do
      output = calendar_date_select(:model, 
        :start_datetime, 
        :valid_date_check => "date = 5; date < new Date());"
      )
    end
    
    assert_throws throw_message.to_sym do
      output = calendar_date_select(:model, 
        :start_datetime, 
        :valid_date_check => "function(p) { date = 5; date < new Date()); }"
      )
    end
  end
  
  def test__year_range__formats_correctly
    output = calendar_date_select(:model, :start_datetime)
    assert_match("year_range:10", output)
    output = calendar_date_select(:model, :start_datetime, :year_range => 2000..2010)
    assert_match("year_range:[2000, 2010]", output)
    output = calendar_date_select(:model, :start_datetime, :year_range => (15.years.ago..5.years.ago))
    assert_match("year_range:[#{15.years.ago.year}, #{5.years.ago.year}]", output)
  end

  def test__tag__formats_text_correctly_string
    time = "January 2, 2007 12:01:23 AM"
    output = calendar_date_select_tag(:name, time)

    assert_match(time, output, "Should have outputted a correctly formatted time")
  end

  def test__tag__formats_text_correctly_date
    time = Date.new(2007, 01, 02)
    output = calendar_date_select_tag(:name, time)

    assert_no_match(/12:01 AM/, output, "Should not have outputted a time")
    assert_match(CalendarDateSelect.format_date(time), output, "Should have outputted a correctly formatted time")
  end

  def test__tag__formats_text_correctly_time
    time = Time.parse("January 2, 2007 12:01:23 AM")
    output = calendar_date_select_tag(:name, time)

    assert_match(CalendarDateSelect.format_date(time), output, "Should have outputted a correctly formatted time")
  end

  def test__tag__formats_text_correctly_with_time_option
    time = Time.parse("January 2, 2007 12:01:23 AM")
    output = calendar_date_select_tag(:name, time, :time => true)

    assert_match(CalendarDateSelect.format_date(time), output, "Should have outputted a correctly formatted time")
  end

  def test__tag__formats_text_correctly_with_mixed_option
    time = Time.parse("January 2, 2007 12:01:23 AM")
    output = calendar_date_select_tag(:name, time, :time => 'mixed')

    assert_match(CalendarDateSelect.format_date(time), output, "Should have outputted a correctly formatted time")
  end

  def test__tag__formats_text_correctly_time_as_date
    time = Time.parse("January 2, 2007 12:01:23 AM")
    output = calendar_date_select_tag(:name, time, :time => false)

    assert_no_match(/12:01 AM/, output, "Should not have outputted a time")
    assert_match(time.strftime(CalendarDateSelect.date_format_string(false)), output, "Should have outputted a correctly formatted time")
  end

  def test__tag__formats_text_correctly_time_with_format
    time = Time.parse("January 2, 2007 12:01:00 AM")
    output = calendar_date_select_tag(:name, time, :format => "%Y-%m-%d")

    assert_no_match(/12:01 AM/, output, "Should not have outputted a time")
    assert_match('2007-01-02', output, "Should have outputted a correctly formatted time")
  end
  
  def test__nil_object_option__should_disregard
    @model.start_datetime = Time.parse("January 2, 2007 12:00 AM")
    output = calendar_date_select(:model, :start_datetime, :time => true, :object => nil)
    assert_match(CalendarDateSelect.format_date(@model.start_datetime), output, "Should have outputted a time")
  end  

end


