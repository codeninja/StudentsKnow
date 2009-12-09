class Admin::RevenuesController < ApplicationController
  layout "admin/admin"
  before_filter :admin_login_required

  def index
  
  end
  
end