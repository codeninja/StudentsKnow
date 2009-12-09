class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += ' Please activate your new account' 
    @body[:code] = user.activation_code
    @body[:url]  = activate_url(:host => HOSTNAME, :activation_code => @body[:code])
  end
  
  def activation(user)
    setup_email(user)
    @subject    += ' Your account has been activated!'
    @body[:url]  = home_url(:host => HOSTNAME)
  end
  
  def forgot_password(user)
    setup_email(user)
    @subject    += ' You have requested to change your password'
    @body[:url]  = reset_password_url(:host => HOSTNAME, :id => user.password_reset_code)
    @login = user.login
  end
  
  def reset_password(user)
    setup_email(user)
    @subject    += ' Your password has been reset.'
  end
  
  def send_message_to_friend(user, email_address, message, video_id)
    setup_email(user)
    @recipients  = "#{email_address}"
    @subject     = ' One of your friends would like you to take a look at this video' 
    @body[:url]  = watch_video_url(:host => HOSTNAME, :id => video_id)
    @body[:login] = user.login
    @body[:message] = message
  end
  
  def invite_friends
    
  end
  
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @subject     = "Notification from StudentsKnow.com"
      @sent_on     = Time.now
      @body[:user] = user
      @headers = {"reply-to" => "noreply@studentsknow.com"}
    end
end
