require 'hit_tracker'
ActiveRecord::Base.send(:include, Resource::Tracker)

require 'controller_actions'
ActionController::Base.send(:include, Controller::Hit)
