class AdEngineController < ApplicationController
  include ExceptionNotifiable
  local_addresses.clear
  
  def index
    #### code for reference
    # @referral_code = params[:rc]
    # @referral = Referral.find_by_code(@referral_code)
    # @video = @referral.referrable
    # @referring_user = @referral.user
    #######
    
    code = (params[:rc] || 'sk')
#    @ads = get_text_ads({:page => 'text_ad', :sub_id => code},10)
    @ads = Ad.page(:text_ads).zone(:default).get(10, {:sub_id => code})
    # @ads = []
    
    respond_to do |format|
      format.xml
    end
  end
  
  
end
