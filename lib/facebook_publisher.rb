class FacebookPublisher < Facebooker::Rails::Publisher
  include FacebookHelper
  
  def profile_for_user(user_to_update)
      @user = User.find_by_fbid(user_to_update.uid)
      raise "User with FBID #{user_to_update.uid} not found" unless @user
      send_as :profile
      from user_to_update
      recipients user_to_update
      active_feed = @user.profile.get_fb_option(:profile_feed)
      fbml = render( :partial =>"/facebook/profile_box.fbml.erb", 
                     :locals => { :user => @user, 
                                  :active_feed => active_feed,
                                  :knows => profile_feed_knows(@user, active_feed),
                                  :feed_description => feed_description(active_feed)})
      profile(fbml)
      action =  render(:partial => "facebook/profile_action.fbml.erb") 
      profile_action(action) 
  end
end

