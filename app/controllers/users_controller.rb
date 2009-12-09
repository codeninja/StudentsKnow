class UsersController < ApplicationController
  include ExceptionNotifiable
  local_addresses.clear
  
  before_filter :login_required, :except => [:show, :index]
  layout 'home'
  
  # render new.rhtml
  def new
    @user = User.new()
  end
  
  def index
    store_location
    @users = User.find(:all)
  end
  
  def edit_password
    @user = User.find_by_id_or_login(params[:id])
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    redirect_back_or_default(home_path)
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def update_password
    @user = self.current_user
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Your password was updated"
      redirect_to user_path(self.current_user)
    else
      flash[:notice] = "Your passwords do not match!"
      render :action => 'edit'
    end
  end
  
  # def show
  #   store_location
  #   @user = User.find_by_id_or_login(params[:id])
  #   @comment = Comment.new()
  #   @comments = @user.profile.comments.reverse || []
  #   @user_logged_in = self.current_user
  #   
  #   @is_my_profile = true if @user.id == self.current_user.id if logged_in?
  #   
  #   unless params[:id] == "false"
  #     @user = User.find_by_login(params[:id])
  #     @page_title = "#{@user.login}'s Profile"
  #   else 
  #     @user = self.current_user
  #   end
  #   
  #   @page_title = "My Profile" if @user.id == self.current_user.id
  #   
  #   if logged_in?
  #     if self.current_user.id == @user.id  and @user.profile.nil?
  #       ir = true
  #       redirect_to new_profile_path
  #     end
  #   end
  #   if @user.profile.nil? and (not ir)
  #     flash[:error] = "This user doesn't have a profile to view."
  #     redirect_to home_url
  #   else
  #     redirect_to new_profile_path
  #   end  
  #   # rescue 
  #   #     flash[:error] = "This user doesn't have a profile to view."
  #   #     if @user.profile.nil? and (not ir)
  #   #       flash[:error] = nil
  #   #       redirect_to new_profile_path
  #   #     else
  #   #       redirect_to home_url
  #   #     end
  # end
  
  def show
    store_location
    @user = User.find_by_id_or_login(params[:id])

    if logged_in?
      @user_logged_in = self.current_user
      if @user.id == self.current_user.id
        @is_my_profile = true 
        @page_title = "My Profile"
        @rated = Video.recently_rated_by(self.current_user)
        @viewed = Video.recently_viewed_by(self.current_user)
      else
        @page_title = "#{@user.login}'s Profile"
      end
    else
      @page_title = "#{@user.login}'s Profile"
    end

    if @user.profile.nil?
      if @is_my_profile
        redirect_to new_profile_path
      else
        flash[:error] = "This user does not yet have a profile to view."
        redirect_to home_url
      end
      return
    end

    @comment = Comment.new()
    @comments = (@user.profile.comments.reverse || []) unless @user.profile.nil?
  end

end
