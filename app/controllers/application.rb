# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require 'azoogle'
  
  helper :all # include all helpers, all the time
  
  include AuthenticatedSystem
  # before_filter :login_from_cookie
  
  include BcmsErrorHandler
  around_filter :catch_errors

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery   :secret => '81dd80ae3ecf0easd05eb1a7991asdfasdSDFgfdshfdcd6c8d4ab6'
  
  
  
  def get_ads(page, options,number=1)
    Ad.find_by_page(page, options, number).collect{|a| a.code if a}
  end
  
  def get_text_ads(options,number=1)
    Ad.find_by_page(options, number).collect{|a| {:title => a.display_text, :url => a.code} if a}
  end
  
  def know_categories
    Tag.find(:all, :conditions => "is_category = 1 AND name <> 'site-feedback'", :order => 'name asc')
  end
  
  def strip_dashes(text)
    text.upcase.gsub(/-/,'&nbsp;')
  end
  
  def set_ad_admin_active
    @ad_admin_active = true
  end

  class NullPage
    def zone
      return NullZone.new
    end
  end

  class NullZone
    def get
      return NullAd.new
    end
  end

  class NullAd
    def code
      return ""
    end
  end

end

class Array
  def interleave(o)
    out = []
    each_with_index{|x,i| out << x << o[i]}
    return out.compact
  end
  
  def uniq_by
    clean = []
    self.collect{|x| yield(x)}.uniq.each do |x|
      clean << self.select{|y| yield(y) == x}.last
    end
    clean
  end
end


