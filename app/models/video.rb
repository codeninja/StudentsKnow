# == Schema Information
# Schema version: 57
#
# Table name: videos
#
#  id            :integer(11)     not null, primary key
#  user_id       :integer(11)     
#  name          :string(255)     
#  description   :string(255)     
#  university    :string(255)     
#  class_number  :string(255)     
#  professor     :string(255)     
#  subject       :string(255)     
#  book_title    :string(255)     
#  book_author   :string(255)     
#  chapter       :string(255)     
#  isbn          :string(255)     
#  created_at    :datetime        
#  updated_at    :datetime        
#  in_q          :boolean(1)      
#  upload_ticket :string(255)     
#  approved      :boolean(1)      
#

class Video < ActiveRecord::Base
  # require 'af_extras'
  # include Attachment_fu_extras
  
  include WhiteListHelper
  
  acts_as_taggable
  acts_as_commentable
  acts_as_rateable
  acts_as_favoriteable
  track_hits
  acts_as_referrable
  
  belongs_to :user
  
  has_one :know, :as => :knowable
  has_one :videoasset, :as => :attachable, :dependent => :destroy
  
  delegate :status, :to => :videoasset
  
  validates_presence_of :user_id
  validates_presence_of :name
  validates_presence_of :description
  validates_length_of :name, :within => 5..40
  validates_length_of :description, :within => 5..250

  # SEARCH_FIELDS = %w(name description university professor subject)
  SEARCH_FIELDS = %w(name description university professor subject user_id)

  

  def can_be_dirtied_by?(user)
    r = Rating.find(:first, :conditions => "user_id = #{user.id} AND rateable_id=#{self.id} AND rateable_type='Video' AND value='-1' ")
    if r.nil? && !(self.approved)
        return true
    end
    false
  end
  
  
  def self.per_page
    10
  end
  
  def before_save
    assign_tags
    assign_to_category
    k = Know.create(:user_id => user_id, :knowable_type => 'Video', :knowable_id => id)
    know = k
  end
  
  def after_create
    hit
  end
  
  def regular_tags
    tags.reject{|t| t.is_category }.collect{|t| t.name}
  end
  
  def embed_code
    return "script type stuff goes here"
  end
  
  # File Upload Logic
  alias :asset :videoasset
  validates_presence_of :fileupload, :on => :create, :if => Proc.new{|v| v.upload_ticket.nil? }
  attr_reader :fileupload
  
  def fileupload=(thedata)
    asset.destroy if asset
    @fileupload = thedata
    errors.add_to_base("Invalid upload") unless Asset.is_valid_file?(thedata)
    if new_record?
      create_videoasset(:uploaded_data => thedata)
    else
      asset.update_attributes({:uploaded_data => thedata})
    end
  end
  
  def public_filename(*args)
    videoasset.public_filename(*args) if videoasset
  end
  
  def attach_uploaded_asset!(klass)
    if (a = klass.find_by_upload_ticket(upload_ticket))
      self.videoasset.destroy if self.videoasset
      self.reload
      self.videoasset = a
      save
      return a
    else
      return nil
    end
  end
  
  # Category assignment logic
  attr_accessor :category
  validates_presence_of :category, :on => :create
  
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
      logger.warn "Error assigning the category '#{category}' to Video(#{id})"
      nil
  end
  
  def category
    @category ||= ((category_tag = (tags.select{|t| t.is_category}.first)).nil? ? nil : category_tag.name)
  end
  
  # Tag assignment logic
  # attr_accessor :tagnames
  def assign_tags
    unless (@tagnames || []).empty?
      cat = category
      self.tag_list = nil
      self.tag_list.add(cat)
      tagnames.each do |tag|
        self.tag_list.add tag
      end
    end
  end
  
  def tagnames
    (tag_list + ((@tagnames || []) || [])).uniq
  end
  
  def tagnames=(tagnames_string)
    @tagnames = (white_list(tagnames_string || "")).split(/,/).uniq
    # @tagnames = ((@tagnames || []) + (tagnames_string || "").split(/,/)).uniq
  end
  
  def self.tags(options={})
    tags = self.tags_count.to_a.sort{|x,y| x[1] <=> y[1]}
    if options[:limit] 
      tags = tags[0..(options[:limit] - 1)].sort{|x,y| x[0] <=> y[0]}
    else
      tags = tags.sort{|x,y| x[0] <=> y[0]}
    end
  end
	
  def all_tags
    tags = self.tags.collect{|t| t.name}.uniq
  end
	

  def self.order_sql_by(text)
    mytable = self.table_name
    sql = "#{mytable}.name asc"
    default_sort = "#{mytable}.created_at desc"
    case text
      when "name"
        sql = "#{mytable}.name asc"
      when "date"
        sql = "#{mytable}.created_at desc"
      when 'author'
        sql = 'users.login asc'
      when 'rating'
        sql = "avg_rating desc"
      when 'views'
        sql = 'total_views desc'
      when 'comments'
        sql = 'total_comments desc'
    end
    sql += ", #{default_sort}" unless sql == default_sort    
    return sql
  end

  # This finder builds ActiveRecord find method options and SQL in a model-agnostic fashion
  #  in order to retrieve records with nearly arbitrary precision for pagination or simple
  #  array result.  Additional find conditions (using standard ActiveRecord conditions syntax)
  #  may be specified within the options hash argument using the :conditions key to further 
  #  narrow the records returned.
  #
  # Videos are optionally found by tag name (the tag match boolean can be toggled from
  #  OR to AND using ":exclusive_tags => true"), and sorted by one of the following:
  #   debate title, date, author, number of views, number of comments, and average rating
  #
  # Videos that are not ready for viewing are not retrieved by default,
  #  but this can be toggled using :omit_unencoded => true.
  #  
  # A Video has many Tags, Comments, and one Asset (the abstract model containing file meta-data), 
  #   and is related to the User model
  # The Video model is extended by a the acts_as_taggable_on_steroids plugin, 
  #  as well as a custom plugin to track views which are associated with Users,
  #  and a custom plugin that tracks user ratings
  #
  # Default options = {:limit => 10, :page=> 1, :order => "name", :paginate => false, :exclusive_tags => true}
  # possible values for :order => 'name', 'date', 'author', 'rating', 'comments', and 'views'
  # Video.find_with_tags([tagname1,tagname2], options_hash)
  def self.find_with_tags(selections=[],options={})
    mytable = self.table_name
    myclass = self.class_name.capitalize
    
    defaults = {:limit => 5, :page=> 1, :order => "name", :paginate => false, :exclusive_tags => true, :omit_incomplete => true, :omit_unencoded => true, :condition_boolean => 'AND'}
    
    options = defaults.merge(options)
    options[:page] ||= 1
    options[:limit] ||= 5
    options[:page] = options[:page].to_i
    options[:limit] = options[:limit].to_i
    options[:offset] = (options[:page] - 1) * options[:limit]
    options[:order_sql] = self.order_sql_by(options[:order])
    
    if options[:exclusive_tags]
      options[:conditions] ||= {}
      options.merge(:exclude => true) 
    end
    
    unless options[:conditions].is_a?(Hash)
      options_for_find = find_options_for_find_tagged_with(selections, {:conditions => options[:conditions]})
    else
      options_for_find = find_options_for_find_tagged_with(selections)
    end
    
    if selections.empty?
      options_for_find.merge!(:conditions => options[:conditions])
    end

    asset_status_join ="
    LEFT JOIN
     (
      SELECT #{mytable}.id AS assets_parent_id, assets.status as status
        FROM #{mytable}
          INNER JOIN assets ON assets.attachable_id = #{mytable}.id AND assets.attachable_type = '#{myclass}'
        GROUP BY assets_parent_id
     ) AS assets_status on #{mytable}.id = assets_status.assets_parent_id
    "
    
    hits_join = " 
    LEFT JOIN
     (
      SELECT #{mytable}.id AS #{myclass.downcase}_hit_id, COUNT(hits.id) as total_views
        FROM #{mytable}
          INNER JOIN hits ON hits.hittable_id = #{mytable}.id AND
                             hits.hittable_type = '#{myclass}'
        GROUP BY #{myclass.downcase}_hit_id
     ) AS hit_stats ON #{mytable}.id = hit_stats.#{myclass.downcase}_hit_id "
    
    rating_join = " 
    LEFT JOIN
      (
        SELECT #{mytable}.id AS #{myclass.downcase}_rating_id, AVG(ratings.value) AS avg_rating
          FROM #{mytable}
            INNER JOIN ratings ON ratings.rateable_id = #{mytable}.id AND
                                  ratings.rateable_type = '#{myclass}'
          GROUP BY #{myclass.downcase}_rating_id
      ) AS rating_stats ON #{mytable}.id = rating_stats.#{myclass.downcase}_rating_id "
    
    comments_join = "
    LEFT JOIN
     (
      SELECT #{mytable}.id AS #{myclass.downcase}_comment_id, COUNT(comments.id) as total_comments
        FROM #{mytable}
          INNER JOIN comments ON comments.commentable_id = #{mytable}.id AND
                             comments.commentable_type = '#{myclass}'
        GROUP BY #{myclass.downcase}_comment_id
     ) AS comment_stats ON #{mytable}.id = comment_stats.#{myclass.downcase}_comment_id
    "
    
    asset_join = "
    LEFT JOIN
     (
      SELECT #{mytable}.id AS assets_parent_id, COUNT(assets.id) as asset_count
        FROM #{mytable}
          INNER JOIN assets ON assets.attachable_id = #{mytable}.id AND assets.attachable_type = '#{myclass}'
        GROUP BY assets_parent_id
     ) AS assets_count on #{mytable}.id = assets_count.assets_parent_id
    "
    
    user_join = "
    INNER JOIN users on #{mytable}.user_id = users.id
    "
    
    # Build Joins for Count
    # count_joins = ((options_for_find[:joins] || '') + (options[:omit_unencoded] ? asset_status_join : '')) + asset_join
    count_join_array = []
    count_join_array << options_for_find[:joins] if options_for_find[:joins]
    count_join_array << asset_status_join if options[:omit_unencoded]
    count_join_array << asset_join
    count_join_array << user_join
    # count_joins = ((options_for_find[:joins] || '') + (options[:omit_unencoded] ? asset_status_join : '')) + asset_join + "INNER JOIN users on users.id = #{mytable}.user_id"
    count_joins = count_join_array.join(' ')
    
    # Build Conditions for count
    condition_string_array = []
    condition_string_array << options_for_find[:conditions] unless (options_for_find[:conditions] || '').empty?
    condition_string_array << "status = 2" if options[:omit_unencoded]
    condition_string_array << "asset_count > 0" if options[:omit_incomplete]
    options_for_count_conditions = condition_string_array.compact.collect{|c| "(#{c})"}.join(' AND ')
    options_for_count_conditions = "(#{options[:conditions]}) #{options[:condition_boolean]} (#{options_for_count_conditions})" unless (options[:conditions] || '').empty?
    
    options_for_count = options_for_find.merge({ :select => "COUNT(distinct #{mytable}.id) as num_#{mytable}", 
                                                 :joins => count_joins,
                                                 :conditions => options_for_count_conditions})
    
    # Build conditions for find
    condition_string_array = []
    condition_string_array << options_for_find[:conditions] unless options_for_find[:conditions].empty?
    condition_string_array << "asset_count > 0" if options[:omit_incomplete]
    condition_string_array << "status = 2" if options[:omit_unencoded]
    find_conditions_string = condition_string_array.compact.collect{|c| "(#{c})"}.join(' AND ')
    find_conditions_string = "(#{options[:conditions]}) #{options[:condition_boolean]} (#{find_conditions_string})" unless (options[:conditions] || '').empty?
    
    # Build Joins for find
    join_string_array = []
    join_string_array << options_for_find[:joins]
    join_string_array << user_join
    join_string_array << asset_join if options[:omit_incomplete]
    join_string_array << asset_status_join if options[:omit_unencoded]
    case options[:order]
      when 'views'
        order_join = hits_join
      when 'rating'
        order_join = rating_join
      when 'comments'
        order_join = comments_join
      else
        order_join = nil
    end
    join_string_array << order_join if order_join
    find_join_string = join_string_array.join(' ')
    
    # Build options for find
    options_for_find[:select] ||= "#{mytable}.*"
    options_for_find[:joins] ||= ""
    options_for_find =  options_for_find.merge(
      {  
        :limit => options[:limit],
        :offset => options[:offset],
        :order => options[:order_sql],
        :select => options_for_find[:select] + "#{', total_views' if options[:order] == 'views'}#{', avg_rating' if options[:order] == 'rating'}#{', total_comments' if options[:order] == 'comments'}#{", asset_count " if options[:omit_incomplete]}",
        :from => "videos",
        :joins => find_join_string,
        :order => options[:order_sql],
        :group => "#{mytable}.id",
        :conditions => find_conditions_string
      }
    )
  
    # Get Count
    count = find(:first, options_for_count).attributes["num_#{mytable}"]
    
    # Find objects
    collection = find(:all, options_for_find)
    
    if options[:paginate]
      return { :page => collection, 
        :page_number => options[:page], 
        :total => count, 
        :offset => options[:offset], 
        :pages => (count.to_f / options[:limit]).ceil,
        :order => options[:order],
        :tags => selections.join(','),
        :limit => options[:limit] 
      }
    else
      return collection
    end
  end
  
  def self.search(search_string,options={})
     search_fields = SEARCH_FIELDS
     mytable = self.table_name
     split_search = search_string.split(/[ ,]/).collect{|s| s.gsub(/\W/,'')}.reject{|s| s.empty?}

     # find tags that match search terms
     search_tags_cond_array = []
     split_search.each_with_index{ |s,index| search_tags_cond_array << "(name like '%#{s}%')"  }
     search_tags_cond = search_tags_cond_array.join(" OR ")              
     search_tags = ((t = Tag.find(:all, :conditions => search_tags_cond)).empty? ? [] : t.collect{|x| x.name})

     # omit list search terms that matched tags
     tags_re = Regexp.new("/(#{split_search.join('|')})/i")
     omit_terms = split_search.select{|ss| search_tags.select{|st| st.match(/#{ss}/i)}.size > 0 } + search_tags

     # assemble terms and search fields
     cond_str_array = []
     cond_hash = {}
     (split_search - omit_terms).each_with_index do |s,index|
        search_item = "%#{s}%"
        search_item_key = "item#{index}"
        search_item_cond_array = []
        search_fields.each do |sf|
          if (t = sf.match(/^user_id$/))
            search_users = User.find(:all, :conditions => ["login like ?",search_item])
            search_item_cond_array << "(#{mytable}.user_id IN (#{search_users.collect{|u| "'#{u.id}'"}.join(',')},0))" unless search_users.empty?
          else
            search_item_cond_array << "(#{mytable}.#{sf} LIKE :#{search_item_key})"
          end
        end
        search_item_cond_str = "(#{search_item_cond_array.join(" OR ")})"
        cond_str_array << search_item_cond_str
        cond_hash[search_item_key.to_sym] = search_item
     end

     # build conditions sql string
     unless cond_str_array.empty?
       conditions = ""
       cond_str = "(#{cond_str_array.join(" OR ")})"
       conditions_arr = [cond_str, cond_hash]
       add_conditions!(conditions, conditions_arr)
       conditions.sub!(/WHERE/,'')
     end

     # pass off the work to find_with_tags, providing search tags array and conditions string
     search_results = self.find_with_tags(search_tags, options.merge(:conditions => conditions, :exclusive_tags => false, :condition_boolean => 'OR'))

     return search_results.merge(:search_string => search_string)
  end
  
  def self.per_page
    5  #controlls pagination for comments and or videos in the front end, change HERE 
  end
  
  def create_ticket!(user=nil)
    if user.is_a?(User)
      self.upload_ticket = "#{user.id}-#{Time.now.to_i}-#{rand(1000)}"
    else
      self.upload_ticket = "#{rand(10000)}-#{Time.now.to_i}-#{rand(1000)}"
    end
    save unless new_record?
    return upload_ticket
  end

  def self.recently_viewed_by(the_user, limit=10)
    self.find(:all, :joins => :hits, :conditions => ["hits.user_id = ?", the_user.id] , :limit => limit).compact
  end
  
  def self.recently_rated_by(the_user, limit=10)
    self.find(:all, :joins => :ratings, :conditions => ["ratings.user_id = ?", the_user.id], :limit => limit).compact
  end
  
  def to_param
    "#{id}-_#{name.to_s.gsub(" ","_").gsub(/[^a-z0-9_-]/i,'')}"
  end


end
