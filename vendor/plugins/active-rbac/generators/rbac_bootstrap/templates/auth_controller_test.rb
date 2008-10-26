require File.dirname(__FILE__) + '/../test_helper'
require 'auth_controller'

# Re-raise errors caught by the controller.
class AuthController; def rescue_action(e) raise e end; end

class AuthControllerTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    @controller = AuthController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_login_should_render_form_on_GET
    get :login
    
    assert_response :success
    assert_template 'auth/login'
    
    # assertions about the view's contents
    form_hash = { :tag => 'form' }
    assert_tag form_hash
    
    assert_tag :tag => 'input', :attributes => { :type => 'text', :name => 'user[login]', :value => '' },
      :ancestor => form_hash
    assert_tag :tag => 'input', :attributes => { :type => 'password', :name => 'user[password]', :value => '' },
      :ancestor => form_hash
    assert_tag :tag => 'input', :attributes => { :type => 'submit', :name => 'submit_login' }, :ancestor => form_hash
  end
  
  def test_login_should_set_current_user_on_POST_with_valid_login_and_password
    post :login, :user => { :login => users(:first).email, :password => 'password' }
    
    assert_response :redirect
    assert_redirected_to '/'
    
    assert_equal users(:first), @controller.current_user
  end
  
  def test_login_should_not_set_current_user_on_POST_with_invalid_login
    post :login, :user => { :login => users(:first).email + "<invalid>", :password => 'password' }
    
    assert_response :success
    assert_template 'auth/login'
    
    assert @controller.current_user.is_anonymous?
  end
  
  def test_login_should_not_set_current_user_on_POST_with_invalid_password
    post :login, :user => { :login => users(:first).email, :password => '<invalid password>' }
    
    assert_response :success
    assert_template 'auth/login'
    
    assert @controller.current_user.is_anonymous?
  end
  
  def test_logout_should_render_form_on_GET
    get :logout
    
    assert_response :success
    assert_template 'auth/logout'
    
    # assertions about the view's contents
    form_hash = { :tag => 'form' }
    assert_tag form_hash

    assert_tag :tag => 'input', :attributes => { :type => 'submit', :name => 'submit_yes' }, :ancestor => form_hash
    assert_tag :tag => 'input', :attributes => { :type => 'submit', :name => 'submit_no' }, :ancestor => form_hash
  end
  
  def test_logout_resets_current_user_on_POST_with_submit_yes
    set_current_user(users(:first))
    
    post :logout, :submit_yes => 'Yes'
    
    assert_response :redirect
    assert_redirected_to '/'
    
    assert_kind_of AnonymousUser, @controller.current_user
  end
  
  def test_logout_does_not_reset_current_user_on_POST_with_submit_no
    set_current_user(users(:first))
    
    post :logout, :submit_no => 'No'
    
    assert_response :redirect
    assert_redirected_to '/'
    
    assert_equal users(:first), @controller.current_user
  end
end
