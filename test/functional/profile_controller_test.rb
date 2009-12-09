require File.dirname(__FILE__) + '/../test_helper'

require 'profiles_controller'

# Re-raise errors caught by the controller.
class ProfilesController; def rescue_action(e) raise e end; end
include AuthenticatedTestHelper

class ProfilesControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
    fixtures :users
    fixtures :profiles
    
  def setup
    @controller = ProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    create_user
  end
  
    def test_should_redirect_on_no_login
        get :show
        assert_response :redirect
    end

    def test_should_show_on_login
        login_as :quentin
        get :show
        assert_response :redirect
        assert_redirected_to user_path :quentin
    end
    
    def test_should_redirect_edit_if_not_logged_in
        get :edit
        assert_response :redirect
        assert_redirected_to :controller => 'sessions', :action => 'new'
    end
    
    def test_should_redirect_edit_if_logged_in
        login_as :quentin
        get :edit
        assert_response :success
    end
    
    def test_should_allow_editing
      login_as :quentin
      get :edit
      post :update, :profile => { :country => 'Taiwan', :state => 'state', :gender => 'gender', :university => 'some school', :dob => Time.now(), :start => Time.now(), :graduation => Time.now()}
      assert_response :redirect
      assert_redirected_to :controller => 'profiles', :action => 'show'
    end
  
    protected
      def create_user(options = {})
        post :create, :user => { :login => 'quire', :email => 'quire@example.com',
          :password => 'quire', :password_confirmation => 'quire' }.merge(options)
      end
  
end

