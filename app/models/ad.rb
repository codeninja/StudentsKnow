# == Schema Information
# Schema version: 57
#
# Table name: ads
#
#  id           :integer(11)     not null, primary key
#  adbackend_id :integer(11)     
#  offer_id     :integer(11)     
#  width        :integer(11)     
#  height       :integer(11)     
#  name         :string(255)     
#  review_link  :string(255)     
#  code         :text            
#  expires      :date            
#  payout       :decimal(10, 2)  
#  created_at   :datetime        
#  updated_at   :datetime        
#  display_text :string(255)     default("")
#  size         :string(255)     default("oob")
#  text_only    :boolean(1)      
#

class Ad < ActiveRecord::Base
  require 'null_objs'
  belongs_to :adbackend
  has_and_belongs_to_many :adpages
  has_and_belongs_to_many :ad_zones
  
  track_hits
  
  SIZE_MAP = {
                :tall => [
                  [120,600],
                  [160,600]
                ],

                :wide => [
                  [728,90]
                ],

                :block => [
                  [300,250],
                  [120,240]
                ],
                
                :wide_block => [
                  [600,400],
                  [720,300]
                ],
                
                :tall_block => [
                  [425,600]
                ],
                
                :tiny => [
                  [120, 60],
                  [125,125]
                ],
                
                :text =>
                  [nil,nil]
              }
  
  def self.detect_size(w,h)
    s = Ad::SIZE_MAP.to_a.select{|s| s[1].include?([w,h])}
    return (s.empty? ? "oob" : s.last[0].to_s)
  end
  
  def self.size_options_for_select
    options = []
    SIZE_MAP.each_pair do |label, sizes|
      options << [label.to_s,label.to_s]
    end
    return options
  end
  
  def before_save
    self.size = Ad.detect_size(width,height) if (size.empty? || size == "oob") unless text_only
  end
  
  def self.text_only
    Ad.find(:all, :conditions => "text_only = 1")
  end
  
  def self.get_text(code, number=1)
    
  end
  
  def self.find_by_page(page, in_options,number=1)
    raise "argument must be a hash" unless in_options.is_a?(Hash)
    default_options = {:page => :any, :dimensions => :any, :sub_id => 'sk'}
    options = default_options.merge(in_options)
        
    condition_strings = []
    conditions_hash = {:name => options[:page]}
    
    if options[:size]
      condition_strings << "size = :size"
      conditions_hash[:size] = options[:size].to_s
    end
    
    unless page == :any
      condition_strings << "adpages.name = :name"
      conditions_hash[:page] = page.to_s
    end
    
    conditions_string = condition_strings.collect{|s| "(#{s})"}.join(' AND ')
    
    ads = Ad.find(:all, :include => :adpages, :conditions => [conditions_string, conditions_hash], :limit => number, :order => "RAND()")
    ads = ads.collect do |ad|
      if ad.adbackend.name == 'azoogle'
        ad.code = ad.code.sub(/^(.+a href=['"][^'"]+?)(["'])(.+)$/){ |s| $1 + "?sub_id=#{options[:sub_id]}" + $2 + " target='_blank' " + $3}
        ad.code = ad.code.sub(/^(.+clickTAG=[^'"]+)['"](.+)$/){ |s| $1 + "?sub_id=#{options[:sub_id]}'" + $2 }
        ad.code = ad.code.sub(/^(.+img width="[0-9]+" height="[0-9]+" src="[^'"]+)['"](.+)$/){ |s| $1 + "?sub_id=#{options[:sub_id]}'" + $2 }
        ad
      else
        ad
      end
    end 
    
    return ads
  end
  
  def self.hack!(ads,options)
    out_ads = ads.collect do |ad|
      case ad.adbackend.name
      when "azoogle"
        options[:sub_id] ||= 'nil'
        ad.code = ad.code.sub(/^(.+a href=['"][^'"]+?)(["'])(.+)$/){ |s| $1 + "?sub_id=#{options[:sub_id]}" + $2 + " target='_blank' " + $3}
        ad.code = ad.code.sub(/^(.+clickTAG=[^'"]+)['"](.+)$/){ |s| $1 + "?sub_id=#{options[:sub_id]}'" + $2 }
        ad.code = ad.code.sub(/^(.+img width="[0-9]+" height="[0-9]+" src="[^'"]+)['"](.+)$/){ |s| $1 + "?sub_id=#{options[:sub_id]}'" + $2 }
        ad
      else
        ad
      end
    end 
    return out_ads
  end
  
  def self.page(page_name)
    (Adpage.find_by_name(page_name.to_s, :include => :ad_zones) || NullPage.new)
  end
  
  def payout=(amt)
    if amt.is_a?(String)
      self[:payout] = amt.sub(/^\$/,'').to_f
    else
      self[:payout] = amt
    end
  end
  
end
