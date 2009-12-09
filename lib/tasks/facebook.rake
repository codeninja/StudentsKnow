namespace :facebook do
  desc "Update Facebook Profile Boxes"
  task :update_profiles => :environment do
    include Facebooker
    
    puts "Updating Facebook User Profile Boxes:"
    User.find(:all, :conditions => 'fbid IS NOT NULL').each do |user|
      puts " * Delivering facebook profile for #{user.login}..."
      begin
        fb_session = Facebooker::Session.create(Facebooker::Session.api_key, Facebooker::Session.secret_key)
        fb_user = Facebooker::User.new(user.fbid, fb_session)
        FacebookPublisher.deliver_profile_for_user(fb_user)
      rescue
        puts "  - Error sending profile for #{user.login}."
      end
    end
  end
  
end