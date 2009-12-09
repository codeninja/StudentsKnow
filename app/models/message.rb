# == Schema Information
# Schema version: 57
#
# Table name: messages
#
#  id         :integer(11)     not null, primary key
#  user_id    :string(255)     default(""), not null
#  topic      :string(255)     
#  data       :text            
#  created_at :datetime        
#  updated_at :datetime        
#

class Message < ActiveRecord::Base
    
 include WhiteListHelper

  validates_presence_of :user_id, :topic, :data
  acts_as_commentable
  acts_as_taggable
  belongs_to :user

  validates_presence_of :category, :on => :create
 
  def topic=(text)
    write_attribute(:topic, white_list(text))
   end

  def data=(text)
    write_attribute(:data, white_list(text))
  end   
  
  def before_save
    assign_tags
    assign_to_category
  end
  
  def self.per_page
    5  #controlls pagination for Messages, change HERE 
  end
  
  def self.admin_per_page
    30  #controlls pagination for Messages in admin system, change HERE 
  end
        
        
          # Category assignment logic
  attr_accessor :category

  
  def assign_to_category
    if category
      tags.select{|t| t.is_category}.each{|t| tag_list.remove(t.name)}
      if (t = Tag.find_by_name(category))
        if t.is_category
          self.tag_list.add(category)
        else
          return false
        end
      end
    end
    true
    rescue
      logger.warn "Error assigning the category '#{category}' to Message(#{id})"
      nil
  end
  
  def category
    @category ||= ((category_tag = (tags.select{|t| t.is_category}.first)).nil? ? nil : category_tag.name)
  end
  
  def category_id(cat)
    Tag.find(:first, :conditions => ["is_category = ? and name = ?", 1, cat]).id
  end
  
  # Tag assignment logic
  attr_accessor :tagnames
  def assign_tags
    cat = category
    self.tag_list = nil
    tag_list.add(cat)
    tagnames.each do |tag|
      self.tag_list.add tag
    end
  end
  
  def tagnames
    (tag_list + ((@tagnames || []) || [])).uniq
  end
  
  def tagnames=(tagnames_string)
    @tagnames = ((@tagnames || []) + tagnames_string.split(/[, ]+/)).uniq
  end

        
  def self.get_parent(reply)
    return Message.find(:first, :conditions => "id = '#{reply.commentable_id}'")
  end   
        
        
end
