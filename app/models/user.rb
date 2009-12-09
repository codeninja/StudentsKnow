# == Schema Information
# Schema version: 57
#
# Table name: users
#
#  id                        :integer(11)     not null, primary key
#  login                     :string(255)     
#  email                     :string(255)     
#  name_first                :string(255)     
#  name_middle               :string(255)     
#  name_last                 :string(255)     
#  crypted_password          :string(40)      
#  salt                      :string(40)      
#  time_zone                 :string(255)     default("Etc/UTC")
#  created_at                :datetime        
#  updated_at                :datetime        
#  remember_token            :string(255)     
#  remember_token_expires_at :datetime        
#  activation_code           :string(40)      
#  activated_at              :datetime        
#  visits_count              :integer(11)     
#  last_login_at             :datetime        
#  password_reset_code       :string(40)      
#  password_reset_at         :datetime        
#  tier                      :integer(11)     default(1)
#  fbid                      :integer(11)     
#

require 'digest/sha1'
class User < ActiveRecord::Base
  include AuthenticatedBase
  
  validates_captcha :if => :request_captcha_validation?
  
  attr_accessor :request_captcha_validation
  attr_accessible :captcha_validation, :captcha_id

  validates_uniqueness_of :login, :email, :case_sensitive => false
  validates_presence_of :login, :email
  validates_confirmation_of :password, :email, :if => :password_required?
  # validates_presence_of :terms_of_service, :on => :create, :message => "You must be over 13 to use this site!"
  
  validates_format_of :email,
    :with =>  %r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i ,
    :message => "Invalid email format"
  
  validates_format_of :login, 
    :with => /^[a-zA-Z]+[a-zA-Z0-9\-_]+$/, 
    :message => "Your login must contain only letters, numbers, or the characters: '-' and '_'."

  # Protect internal methods from mass-update with update_attributes
  attr_accessible :login, :name_first, :name_middle, :name_last, :email, :email_confirmation, :password, :password_confirmation, :time_zone, :role_ids
  
  has_one :profile_pic, :class_name => "Image", :conditions => "profile_pic = 1"
  has_one :profile, :dependent => :destroy
  has_many :videos
  has_many :images, :dependent => :destroy
  has_many :messages
  has_many :favorites, :dependent => :destroy
  has_many :referrals, :dependent => :destroy
  has_many :posts, :class_name => "Comment", :conditions => "commentable_type = 'Message'"
  has_many :know_feeds
  
  has_many :knows

  def self.search(search_string)
    User.find(:all, :conditions => ['login LIKE ?', "%#{search_string}%"])
  end
  
  def public_videos
    videos.select{|v| v.status == 2}
  end

  def before_save
    tier = 1
  end

  def after_create
    profile = Profile.create(:user_id => id, :tier => 1)
  end

  def favorite_knows
    favorites.collect{|f| f.favoriteable.is_a?(Tag) ? nil : f.favoriteable }.compact
  end


  def to_param
    login.to_s
  end
  
  def self.find_by_id_or_login(info)
    find(:first, :conditions => ['id = ? or login = ?', info, info])
  end

  # Returns an array of available logins, or nil if the login is available
   def self.suggest_login?(in_text,number=3,force=false)
     text = URI.decode(in_text)
     if User.find_by_login(text) or force
       possible = Array.new(number*2){text + rand(10000).to_s}.uniq
       possible_sql = "login IN (#{possible.collect{|u| "'#{u}'"}.join(', ') })"
       possible -= User.find(:all, :select => "login", :conditions => possible_sql).collect{|u| u.login}
       if possible.empty?
         return User.suggest_login?(text,number)
       else
         return possible[0..number].sort
       end
     end
   end
   
  def age(dob)
    return nil unless dob.is_a?(Date)
    now = Time.now
    # how many years?
    # has their birthday occured this year yet?
    # subtract 1 if so, 0 if not
      age = now.year - dob.year - (dob.to_time.change(:year => now.year) > now ? 1 : 0)
  end
  
   def self.admin_per_page
    50 #controlls pagination for Users in admin system, change HERE 
  end
  
  
  
  def to_param
    login
  end

  def fullname
    name = name_first
    name+= " #{name_middle}" unless name_middle.nil?
    name+= " #{name_last}"
  end

  def self.find_by_param(*args)
    find_by_login(*args)
  end

  alias_method :ar_to_xml, :to_xml

  def to_xml(options={})
    default_except = []
    default_except += self.class.protected_attributes() unless self.class.protected_attributes.nil?  #include any protected attributes if any
    default_except = [ :salt, :crypted_password, :activation_code, :password_reset_at, :password_reset_code, :remember_token_expires_at, :remember_token ]
    options[:except] = (options[:except] ? options[:except] + default_except : default_except)   
    ar_to_xml(options)
  end

  def request_captcha_validation?
    (self.request_captcha_validation==true)? true : false
  end
  


  # Get top posters for an asset class, ordered by calculated weight, views, or average rating
  #   for posts in an asset class, optionally restricted by a tag list
  #
  # accepted arguments => (Fixnum, {:cutoff => Time, :class => (Video,Podcast, etc.), :order => ['default','rating','views'], :tags => [String or Array of String]})
  def self.top_posters(limit=10,opts={})
    default_options = {:cutoff => 100.months.ago, :class => Video, :order => 'default', :tags => []}
    options = default_options.merge(opts) 
    
    options[:tags] = [options[:tags]].flatten unless (options[:tags].is_a?(Array) and options[:tags].is_a?(String))
    raise "invalid tags" unless options[:tags].is_a?(Array)
    
    asset_table = options[:class].table_name
    asset_class = options[:class].to_s
    cutoff = options[:cutoff].to_s(:db)
    
    default_order_sql = 'weight DESC'
    order_sql = ''
    case options[:order]
      when 'rating'
        order_sql = 'rating DESC'
      when 'views'
        order_sql = 'views DESC'
    end
    order_sql = [order_sql,default_order_sql].reject{|x| x.empty?}.join(', ') unless order_sql == default_order_sql
  
    logger.info options[:tags].inspect
    
    tag_sql = ""
    unless options[:tags].empty?
      tag_sql = "
      INNER JOIN taggings on taggings.taggable_id = videos.id AND
                            taggings.taggable_type = 'Video'
      INNER JOIN tags on tags.id = taggings.tag_id AND
                            tags.name IN (#{options[:tags].collect{|t| "'#{t}'"}.join(',')})"
    end
    
    weight_sql = "(rating * (views + 1))"                      
 
    sql_string = "
      SELECT users.*, rating, views, #{weight_sql} AS weight
        FROM users
            LEFT JOIN
              (
                SELECT users.*, AVG(ratings.value) as rating
                  FROM users
                    INNER JOIN #{asset_table} ON #{asset_table}.user_id = users.id
                    #{tag_sql}
                    INNER JOIN ratings ON ratings.rateable_id = #{asset_table}.id AND 
                                          ratings.rateable_type = '#{asset_class}' AND
                                          ratings.created_at > '#{cutoff}'
                  GROUP BY users.id
              ) AS rating_stats ON users.id = rating_stats.id
            LEFT JOIN
             (
              SELECT users.*, COUNT(hits.id) as views
                FROM users
                  INNER JOIN #{asset_table} ON #{asset_table}.user_id = users.id
                  #{tag_sql}
                  INNER JOIN hits ON hits.hittable_id = #{asset_table}.id AND
                                     hits.hittable_type = '#{asset_class}' AND
                                     hits.created_at > '#{cutoff}'
                GROUP BY users.id
             ) AS hit_stats ON users.id = hit_stats.id
        ORDER BY #{order_sql}
        LIMIT #{limit}"
    User.find_by_sql(sanitize_sql(sql_string)).reject{|u| u.weight.nil?}
  end

  def total_posts
    videos.count
  end
  
  def total_views
    sql_string = "
      SELECT users.id, COUNT(hits.id) as totalhits
        FROM users
          INNER JOIN videos on videos.user_id = users.id
          INNER JOIN hits ON hits.hittable_id = videos.id AND 
                                hits.hittable_type = 'Video'
        WHERE users.id = #{self.id}
        GROUP BY users.id"
    u = User.find_by_sql(sql_string).first
    return (u ? u.totalhits : 0)
  end
  
  def total_views_this_month
    start_date = 1.month.ago.to_s(:db)
 
    sql_string = "
      SELECT users.id, COUNT(hits.id) as totalhits
        FROM users
          INNER JOIN videos on videos.user_id = users.id
          INNER JOIN hits ON hits.hittable_id = videos.id AND 
                                hits.hittable_type = 'Video' AND
                                hits.created_at > '#{start_date}'
                                
        WHERE users.id = #{self.id}
        GROUP BY users.id"
    u = User.find_by_sql(sql_string).first
    return (u ? u.totalhits : 0)
  end
  
  def total_views_this_week
    start_date = 1.week.ago.to_s(:db)
 
    sql_string = "
      SELECT users.id, COUNT(hits.id) as totalhits
        FROM users
          INNER JOIN videos on videos.user_id = users.id
          INNER JOIN hits ON hits.hittable_id = videos.id AND 
                                hits.hittable_type = 'Video' AND
                                hits.created_at > '#{start_date}'
                                
        WHERE users.id = #{self.id}
        GROUP BY users.id"
    u = User.find_by_sql(sql_string).first
    return (u ? u.totalhits : 0)
  end
  
  

  
  def avg_rating(output = :letter)
    sql_string = "
      SELECT users.id, AVG(ratings.value) as avgrating
        FROM users
          INNER JOIN videos on videos.user_id = users.id
          INNER JOIN ratings ON ratings.rateable_id = videos.id AND 
                                ratings.rateable_type = 'Video'
        WHERE users.id = #{self.id}
        GROUP BY users.id"
        
    u = User.find_by_sql(sql_string).first
    r = u ? u.avgrating.to_f : 3.0
    case output
      when :letter
        return Video.to_letter_grade(r)
      when :decimal
        return r.to_f
    end
  end
  
  
end
