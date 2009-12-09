require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < ActiveSupport::TestCase
  include AuthenticatedTestHelper
  fixtures :profiles, :users

  def test_should_create_profile
    assert_difference 'Profile.count' do
      user = create_user
      profile = create_profile(:user_id => user.id)
      assert !profile.new_record?, "#{profile.errors.full_messages.to_sentence}"
      assert profile.user_id == user.id, "User ids dont match!"
    end
  end
  
  
  
   #def test_should_require_user
   # assert_no_difference 'Profile.count' do
   #   p = create_profile(:user_id => nil)
   #   assert !p.new_record?, "#{p.errors.full_messages.to_sentence}"
   # end
  #end

  def test_should_require_country
    assert_no_difference 'Profile.count' do
      user = create_user
      p = create_profile(:user_id => user.id, :country => nil)
      assert p.errors.on(:country), "Errors on Country"
    end
  end
  
  def test_should_require_state
    assert_no_difference 'Profile.count' do
      user = create_user
      p = create_profile(:user_id => user.id, :state => nil)
      assert p.errors.on(:state), "Errors on State"
    end
  end
  
  def test_should_require_zip
    assert_no_difference 'Profile.count' do
      user = create_user
      p = create_profile(:user_id => user.id, :zip => nil)
      assert p.errors.on(:zip), "Errors on Zip"
    end
  end
  
   def test_should_require_gender
    assert_no_difference 'Profile.count' do
      user = create_user
      p = create_profile(:user_id => user.id, :gender => nil)
      assert p.errors.on(:gender), "Errors on Gender"
    end
  end
  
   def test_should_require_university
    assert_no_difference 'Profile.count' do
      user = create_user
      p = create_profile(:user_id => user.id, :university => nil)
      assert p.errors.on(:university), "Errors on University"
    end
  end
  
   def test_should_require_dob
    assert_no_difference 'Profile.count' do
      user = create_user
      p = create_profile(:user_id => user.id, :dob => nil)
      assert p.errors.on(:dob), "Errors on DOB"
    end
  end
  
   def test_should_require_start
    assert_no_difference 'Profile.count' do
      user = create_user
      p = create_profile(:user_id => user.id, :start => nil)
      assert p.errors.on(:start), "Errors on Start"
    end
  end
  
  def test_should_require_graduation
    assert_no_difference 'Profile.count' do
      user = create_user
      p = create_profile(:user_id => user.id, :graduation => nil)
      assert p.errors.on(:graduation), "Errors on Start"
    end
  end
  
  
   def test_should_not_require_terms_on_update
    p = profiles(:quentin).update_attributes(:country => 'USSR', :terms => nil)
    assert_equal profiles(:quentin).country, "USSR"
  end
  
  
  
  
  
  protected
  def create_profile(options = {:userid => user.id})
    Profile.create({ :user_id=> :userid, :country => 'USA', :state => 'Texas', :zip => '12345', :gender => 'male', :university => "UT", :graduation => 2.years.from_now.to_s , :dob => 25.years.ago.to_s, :start => 2.years.ago.to_s }.merge(options))
  end
  
  def create_user(options = {})
    User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
  
  
end
