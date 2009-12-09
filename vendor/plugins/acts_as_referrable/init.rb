# Include hook code here
require 'acts_as_referrable'
ActiveRecord::Base.send(:include, Mwd::Acts::Referrable)