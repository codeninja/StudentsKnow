require "Azoogle"

PUBLISHER_ID = "35435"
LOGIN = "paul@sentientservices.com"
PASSWORD = "f443f"

az  = Azoogle::Azoogle.new( :publisher_id => PUBLISHER_ID,
                            :login => LOGIN,
                            :password => PASSWORD,
                            :debug => false )


puts az.get_ads({:ad_type => :banner, :sub_id => 'another-test', :category => "other"}, 5).inspect