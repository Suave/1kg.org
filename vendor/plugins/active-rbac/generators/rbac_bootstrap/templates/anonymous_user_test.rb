require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def test_find_by_credentials_works_with_correct_login_and_password
    result = User.find_by_credentials(users(:first).email, 'password')
    
    assert_equal users(:first), result
  end

  def test_find_by_credentials_works_with_incorrect_login
    result = User.find_by_credentials(users(:first).email + '<invalid>', 'password')
    
    assert_nil result
  end

  def test_find_by_credentials_works_with_incorrect_password
    result = User.find_by_credentials(users(:first).email, '<password>')
    
    assert_nil result
  end
end
