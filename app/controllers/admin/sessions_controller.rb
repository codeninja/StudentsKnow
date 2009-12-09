# This controller handles the login/logout function of the site.  
class Admin::SessionsController < ApplicationController
   layout "admin/admin"
   
  def login

    if admin_logged_in?
      redirect_to admin_users_url
    end

    
    
  end

  def new
    # render :action => 'login', :controller => 'home'
    redirect_to admin_login_url
  end

  def create
    self.current_admin = Admin.authenticate(params[:login], params[:password])
    if admin_logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:admin_auth_token] = { :value => self.current_admin.remember_token , :expires => self.current_admin.remember_token_expires_at }
      end
      redirect_back_or_default(admin_users_path)
      flash[:notice] = "Logged in successfully"
    else
      flash[:error] = "The login and password you provided did not match."
      # render :action => 'login', :controller => 'home'
      redirect_to admin_login_url
    end
  end

  def destroy
    self.current_admin.forget_me if admin_logged_in?
    cookies.delete :admin_auth_token
    reset_session
    flash[:notice] = "You have been logged out of the admin system."
    redirect_to(admin_login_path)
  end
end

