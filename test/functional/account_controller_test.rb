require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_show_new
    get :new
    assert assigns["user"]
    assert_response :success
  end
  
  def test_should_do_new
    post :new, {:user => {:login => 'test', :password => '12345', :password_confirmation => '12345', :email => 'test@example.com'}}
    assert assigns["user"]
    assert !assigns["user"].new_record?
    assert flash[:notice] = 'user was successfully newd.'
    assert_response :success
  end
  
  def test_should_redirect_back_new_upon_new_failure
    post :new, {:user => {:login => 'test', :password => '12345', :password_confirmation => '12345', :email => 'test@example.com'}}
    assert assigns["user"]
    assert_response :success
  end
  
  def test_activate_by_post
    post :activate, {:user => {:activation_code => users(:quentin).activation_code}}
    assert assigns["user"]
    assert assigns["user"].activated?
    assert_response :redirect
  end
  
  def test_activate_by_post_failure
    post :activate, {:user => {:activation_code => 'foo'}}
    assert_nil assigns["user"]
    assert_response :success
  end

  def test_activate_by_post_no_params
    post :activate
    assert_nil assigns["user"]
    assert_response :success
  end
  
  def test_new_account
    get :new
    assert assigns["user"]
    assert_response :success
  end
  
  
  def test_forgot_password_get
    get :forgot_password
    assert_response :success
  end
  
  def test_forgot_password_post
    post :forgot_password, {:user => {:email => 'bill@example.com'}}
    assert_equal(flash[:notice], "A password reset link has been sent to your email address." )
    assert_response :redirect
  end
  
  def test_reset_password_post_id
    user = users("bill")
    user.forgot_password
    user.save
    post :reset_password, {:id => user.password_reset_code}
    assert assigns["user"]
    assert_not_nil assigns["user"].password_reset_code
  end
  
  def test_reset_password_post_invalid_id
    user = users("bill")
    user.forgot_password
    user.save
    post :reset_password, {:id => 'foo'}
    assert_nil assigns["user"]
    assert !flash.empty?   
  end

  # def test_should_allow_signup
  #   assert_difference 'User.count' do
  #     create_user
  #     assert_response :redirect
  #   end
  # end
  # 
  # def test_should_require_login_on_signup
  #   assert_no_difference 'User.count' do
  #     create_user(:login => nil)
  #     assert assigns(:user).errors.on(:login)
  #     assert_response :success
  #   end
  # end
  # 
  # def test_should_require_password_on_signup
  #   assert_no_difference 'User.count' do
  #     create_user(:password => nil)
  #     assert assigns(:user).errors.on(:password)
  #     assert_response :success
  #   end
  # end
  # 
  # def test_should_require_password_confirmation_on_signup
  #   assert_no_difference 'User.count' do
  #     create_user(:password_confirmation => nil)
  #     assert assigns(:user).errors.on(:password_confirmation)
  #     assert_response :success
  #   end
  # end
  # 
  # def test_should_require_email_on_signup
  #   assert_no_difference 'User.count' do
  #     create_user(:email => nil)
  #     assert assigns(:user).errors.on(:email)
  #     assert_response :success
  #   end
  # end
  

  protected
    # def create_user(options = {})
    #   post :create, :user => { :login => 'quire', :email => 'quire@example.com',
    #     :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    # end
end
