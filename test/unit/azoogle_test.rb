require File.dirname(__FILE__) + '/../test_helper'
class AzoogleTest < ActiveSupport::TestCase
  require 'azoogle'
  
  # fixtures :none
  def setup
    @az = Azoogle::AzAdServer.new
  end
  
  # def test_setup
  #   assert AzoogleAccount.count == 1
  # end
  
  # def test_init_offer_list
  #   @az.init_offer_list!
  # end
  
  # def test_refresh_offers_with_code
  #   @az.refresh_offers('test-code',true)
  # end
  
  def test_get_ads
    @az.get_ads(:sub_id => 'test-code')
    @az.get_ads(:sub_id => 'test-code1')
  end
  
end