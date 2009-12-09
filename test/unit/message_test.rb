require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < ActiveSupport::TestCase
  
  
  #MESSAGE TESTS WERE WRITTEN IN RSPEC, LOOK THERE FOR THEM!
  
  
  
  
   fixtures :tags
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  
  def test_should_create_message
    assert_difference 'Message.count' do
      user = User.find :first
      message = create_message(:user_id => user.id, :topic=> "test", :data => "data", :category => "Math")
      #assert message.new_record?, "#{message.errors.full_messages.to_sentence}"
      assert message.user_id == user.id, "User ids dont match!"
    end
  end
  
  
  
   def test_should_require_user
        m = create_message(:topic => "test", :data => "data", :category => "Math")
        assert m.new_record?, "message create fails as expected"
  end
  




  
  
  
  protected
  def create_message(options = {})
    #mes = Message.create({ :user_id=> :userid }.merge(options))
    Message.create(options)
  end
  
  def create_user(options = {})
     User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
   end

  
  
  
  
  
  
  
  
  
  
end
