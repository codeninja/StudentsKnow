class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :value, :rateable_id, :rateable_type
  validates_inclusion_of :value, :in => -1..5
  
  validates_presence_of :user_id, :unless => :anonymous
  validates_uniqueness_of :user_id, :scope => [:rateable_id, :rateable_type], :unless => :in_oks?
  
 
  
  attr_accessor :anonymous
  
  def in_oks?
     if :anonymous or (:value == -1)
       return true
     end
     false
   end
  
  def self.average_rating_for(object)
    Rating.average('value', :conditions => ['rateable_id = ? AND rateable_type = ?', object.id, object.class]).avg_value
  end
  
  
end
