# == Schema Information
# Schema version: 57
#
# Table name: know_feeds
#
#  id         :integer(11)     not null, primary key
#  user_id    :integer(11)     
#  name       :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class KnowFeed < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :user
  # has_many :knows, :as => :taggable, :through => :taggings, :source => :taggable
  
  
  validates_presence_of :user_id, :name
  validates_uniqueness_of :name
  # validates_length_of :name, :between => 1..40

  def filters=(filter_name_list)    
    cats = category_names
    self.tag_list = nil
    cats.each{|c| self.tag_list.add c}
    unless (filter_name_list || "").empty?
      # only use the first filter
      filter_name = (filter_name_list || "").split(/\s{0,},\s{0,}/).first
      self.tag_list.add filter_name
    end
    self.save
    return self.tag_list
  end
  
  def knows(limit=5)
    filter_results(Video.find_with_tags(categories, {:limit => limit, :order => 'date'}))
  end
  
  def categories
    tag_list.collect{|t| Tag.find_by_name(t)}.select{|t| t.is_category}
  end
  
  def category_names
    categories.collect{|t| t.name}
  end
  
  def filters
    filter_names
  end
  
  def just_filters
    tag_list.collect{|t| Tag.find_by_name(t)}.select{|t| not t.is_category}
  end
  
  def filter_names
    just_filters.collect{|t| t.name}
  end
  
  private 
  
  def filter_results(results, limit=10)
    unless filters.empty?
      results.select{|r| filters.select{|f| r.tag_list.include?(f)}.size > 0}.compact[0..(limit-1)]
    else
      results[0..(limit-1)]
    end
  end
  
  
end
