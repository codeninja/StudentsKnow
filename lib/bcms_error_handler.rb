module BcmsErrorHandler
        
  def catch_errors
    begin
      yield
    rescue AuthenticationFailed
      flash[:notice] = "Could not authenticate your account"
      redirect_to login_url
    rescue AccessDenied #extended to allow for different handling for different requests
      respond_to do |accepts|
        accepts.html do
          flash[:notice] = "You must login to proceed"
          redirect_to login_url
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could not authenticate you", :status => '401 Unauthorized'
        end
      end
    rescue PermissionDenied
      flash[:notice] = "You do not have sufficient privledges for that request"
      redirect_back_or_default '/'
    rescue ActivationRequired
      flash[:notice] = "Your account requires activation. You may use the forgot password link to activate your account."
      redirect_to login_url
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Sorry, can't find that record."
      render :template=>'../../public/404.html', :layout=>false
    rescue => e
      flash[:notice] = e.to_s
    end
    
  end
  
end

class AuthenticationFailed < StandardError; end
class AccessDenied < StandardError; end
class PermissionDenied < StandardError; end
class ActivationRequired < StandardError; end
