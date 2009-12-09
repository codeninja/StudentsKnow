class AccountController < ApplicationController
  include ExceptionNotifiable
  local_addresses.clear
  
  layout "home"
  # signup for account
  # def new
  #   @user = User.new(params[:user])
  # end

  def new
    params[:user].delete('form') if params[:user]
    @user = User.new(params[:user])
    @user.request_captcha_validation = false
    respond_to do |format|
      if @user.save
        # format.xml  { render :xml => @user.to_xml }#FLEX
        format.html do
          flash[:notice] = 'Your account was created.  Check your email, and click on the link provided to activate your account and sign in.'
          redirect_to home_url
        end
      else
        # format.xml { render :xml => @user.errors.to_xml_full }#FLEX
        format.html { render :action => 'new', :format => :html }
      end
    end    
  end

  #activate account - via get (in the email sent with account creation) or post (from the form)
  def activate
   # if request.post?
   
   #   return unless params[:user]
   #   params[:activation_code] ||= params[:user][:activation_code]
   # end
    
   # return unless params[:activation_code]
    
    if (@user = self.current_user = User.find_by_activation_code(params[:activation_code]))
      if logged_in? && !current_user.activated?
        current_user.activate
        flash[:notice] = "Signup complete!  You are now logged in."
        redirect_to user_path(self.current_user)
      else
        flash[:error] = "There was a problem with your activation"
      end
    else
      flash[:error] = "That activation code was not found!"
      # redirect_to forgot_password_path
      return
    end
  end

  #gain email address
  def forgot_password
      return unless request.post?
      if @user = User.find_by_email(params[:user][:email])
          @user.forgot_password
          @user.save
          flash[:notice] = "A password reset link has been sent to your email address." 
          redirect_to login_url
      else
          raise ActiveRecord::RecordNotFound 
      end
    rescue
      flash[:notice] = "You entered an invalid email address."
  end
  
  def reset_password
    @reset_code = (params[:id] || (params[:user].is_a? Hash ? params[:user][:password_reset_code] : nil))
    @user = User.find_by_password_reset_code(@reset_code)
    
    if params[:user].is_a? Hash
      password = params[:user][:password]
      password_confirmation = params[:user][:password_confirmation]
    else
      password = password_confirmation = nil
    end
    
    if request.post?
      @user.password = password
      @user.password_confirmation = password_confirmation
      if @user.save
        flash[:notice] = "Password was reset."
        self.current_user = @user
        redirect_to user_path(@user)
      else
        flash[:error] = "Invalid password or confirmation." 
        redirect_to reset_password_url(:id => params[:id])
        # raise "Invalid password or confirmation." 
      end
    end
    # rescue
    #   flash[:notice] = "Invalid Password Reset Code."
    #   redirect_to '/'
  end

  
end