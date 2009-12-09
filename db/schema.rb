# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 59) do

  create_table "ad_zones", :force => true do |t|
    t.integer  "adpage_id"
    t.string   "name"
    t.string   "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ad_zones", ["adpage_id"], :name => "index_ad_zones_on_adpage_id"
  add_index "ad_zones", ["name"], :name => "index_ad_zones_on_name"
  add_index "ad_zones", ["size"], :name => "index_ad_zones_on_size"

  create_table "ad_zones_ads", :id => false, :force => true do |t|
    t.integer "ad_id"
    t.integer "ad_zone_id"
  end

  add_index "ad_zones_ads", ["ad_id", "ad_zone_id"], :name => "index_ad_zones_ads_on_ad_id_and_ad_zone_id"

  create_table "adbackends", :force => true do |t|
    t.string "name"
  end

  add_index "adbackends", ["name"], :name => "index_adbackends_on_name"

  create_table "admins", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "name_first"
    t.string   "name_middle"
    t.string   "name_last"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "time_zone",                               :default => "Etc/UTC"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.integer  "visits_count"
    t.datetime "last_login_at"
    t.string   "password_reset_code",       :limit => 40
    t.datetime "password_reset_at"
  end

  add_index "admins", ["login"], :name => "index_admins_on_login"

  create_table "adpages", :force => true do |t|
    t.string "name"
  end

  add_index "adpages", ["name"], :name => "index_adpages_on_name"

  create_table "adpages_ads", :id => false, :force => true do |t|
    t.integer "ad_id"
    t.integer "adpage_id"
  end

  add_index "adpages_ads", ["ad_id", "adpage_id"], :name => "index_adpages_ads_on_ad_id_and_adpage_id"

  create_table "ads", :force => true do |t|
    t.integer  "adbackend_id"
    t.integer  "offer_id"
    t.integer  "width"
    t.integer  "height"
    t.string   "name"
    t.string   "review_link"
    t.text     "code"
    t.date     "expires"
    t.decimal  "payout",       :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_text",                                :default => ""
    t.string   "size",                                        :default => "oob"
    t.boolean  "text_only",                                   :default => false
    t.integer  "weight",                                      :default => 1
  end

  add_index "ads", ["adbackend_id"], :name => "index_ads_on_adbackend_id"
  add_index "ads", ["offer_id"], :name => "index_ads_on_offer_id"
  add_index "ads", ["size"], :name => "index_ads_on_size"
  add_index "ads", ["text_only"], :name => "index_ads_on_text_only"

  create_table "assets", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "attachable_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.string   "checksum"
    t.string   "attachable_type"
    t.boolean  "is_duplicate",    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_ticket"
    t.string   "length"
    t.integer  "status",          :default => 0
  end

  add_index "assets", ["parent_id"], :name => "index_assets_on_parent_id"
  add_index "assets", ["checksum"], :name => "index_assets_on_checksum"
  add_index "assets", ["attachable_id", "attachable_type"], :name => "index_assets_on_attachable_id_and_attachable_type"
  add_index "assets", ["upload_ticket"], :name => "index_assets_on_upload_ticket"
  add_index "assets", ["status"], :name => "index_assets_on_status"

  create_table "azoogle_accounts", :force => true do |t|
    t.string   "login_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "azoogle_creatives", :force => true do |t|
    t.integer  "azoogle_offer_id"
    t.string   "sub_id"
    t.string   "creative_type"
    t.integer  "width"
    t.integer  "height"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "azoogle_creatives", ["azoogle_offer_id", "sub_id"], :name => "index_azoogle_creatives_on_azoogle_offer_id_and_sub_id"
  add_index "azoogle_creatives", ["creative_type"], :name => "index_azoogle_creatives_on_creative_type"
  add_index "azoogle_creatives", ["width", "height"], :name => "index_azoogle_creatives_on_width_and_height"

  create_table "azoogle_offer_categories", :force => true do |t|
    t.string "name"
  end

  add_index "azoogle_offer_categories", ["name"], :name => "index_azoogle_offer_categories_on_name"

  create_table "azoogle_offers", :force => true do |t|
    t.integer  "azoogle_account_id"
    t.integer  "offer_id"
    t.string   "title"
    t.string   "description"
    t.string   "notices"
    t.date     "open_date"
    t.date     "expiry_date"
    t.integer  "amount",             :limit => 10, :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "azoogle_offers", ["azoogle_account_id"], :name => "index_azoogle_offers_on_azoogle_account_id"

  create_table "azoogle_offers_categories", :id => false, :force => true do |t|
    t.integer "offer_id"
    t.integer "category_id"
  end

  add_index "azoogle_offers_categories", ["category_id", "offer_id"], :name => "index_azoogle_offers_categories_on_category_id_and_offer_id"

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.datetime "created_at",                                     :null => false
    t.integer  "commentable_id",                 :default => 0,  :null => false
    t.string   "commentable_type", :limit => 15, :default => "", :null => false
    t.integer  "user_id",                        :default => 0,  :null => false
  end

  add_index "comments", ["user_id"], :name => "fk_comments_user"

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "favoriteable_id"
    t.string   "favoriteable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["user_id"], :name => "index_favorites_on_user_id"
  add_index "favorites", ["favoriteable_type", "favoriteable_id"], :name => "index_favorites_on_favoriteable_type_and_favoriteable_id"

  create_table "hits", :force => true do |t|
    t.string   "hittable_type"
    t.string   "kind"
    t.integer  "hittable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",       :default => 0
  end

  add_index "hits", ["hittable_id", "hittable_type", "kind"], :name => "index_hits_on_hittable_id_and_hittable_type_and_kind"
  add_index "hits", ["user_id"], :name => "index_hits_on_user_id"

  create_table "images", :force => true do |t|
    t.integer  "user_id"
    t.string   "description"
    t.boolean  "profile_pic", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["user_id"], :name => "index_images_on_user_id"

  create_table "invite_emails", :force => true do |t|
    t.string   "email"
    t.boolean  "delivered"
    t.boolean  "valid"
    t.integer  "invite_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invites", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "friends"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "know_feeds", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "know_feeds", ["user_id"], :name => "index_know_feeds_on_user_id"

  create_table "knows", :force => true do |t|
    t.integer  "user_id"
    t.integer  "knowable_id"
    t.string   "knowable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "knows", ["user_id"], :name => "index_knows_on_user_id"
  add_index "knows", ["knowable_id", "knowable_type"], :name => "index_knows_on_knowable_id_and_knowable_type"

  create_table "messages", :force => true do |t|
    t.string   "user_id",    :default => "", :null => false
    t.string   "topic"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "notifications", :force => true do |t|
    t.integer  "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.string   "country"
    t.string   "state"
    t.string   "zip"
    t.string   "gender"
    t.string   "university"
    t.datetime "dob"
    t.datetime "start"
    t.datetime "graduation"
    t.boolean  "receive_emails"
    t.boolean  "email_sent"
    t.boolean  "over_13"
    t.boolean  "terms"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "classes"
    t.string   "website"
    t.string   "city"
    t.text     "bio"
    t.string   "paypal_email"
    t.boolean  "optin",           :default => true
    t.date     "grad_start"
    t.date     "grad_grad"
    t.string   "grad_university"
    t.text     "fb_options"
  end

  add_index "profiles", ["paypal_email"], :name => "index_profiles_on_paypal_email"

  create_table "rates", :force => true do |t|
    t.string "rate_name"
    t.float  "rate"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "value",         :default => 3
    t.integer  "user_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["user_id"], :name => "index_ratings_on_user_id"
  add_index "ratings", ["rateable_id", "rateable_type"], :name => "index_ratings_on_rateable_id_and_rateable_type"

  create_table "referrals", :force => true do |t|
    t.string  "code"
    t.string  "referrable_type"
    t.integer "user_id"
    t.integer "referrable_id"
  end

  add_index "referrals", ["referrable_id", "referrable_type"], :name => "index_referrals_on_referrable_id_and_referrable_type"
  add_index "referrals", ["code"], :name => "index_referrals_on_code"
  add_index "referrals", ["user_id"], :name => "index_referrals_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.boolean "is_category", :default => false
    t.string  "description", :default => "0"
  end

  add_index "tags", ["is_category"], :name => "index_tags_on_is_category"
  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "name_first"
    t.string   "name_middle"
    t.string   "name_last"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "time_zone",                               :default => "Etc/UTC"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.integer  "visits_count"
    t.datetime "last_login_at"
    t.string   "password_reset_code",       :limit => 40
    t.datetime "password_reset_at"
    t.integer  "tier",                                    :default => 1
    t.integer  "fbid"
    t.string   "referral_code"
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["fbid"], :name => "index_users_on_fbid"

  create_table "videos", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.string   "university"
    t.string   "class_number"
    t.string   "professor"
    t.string   "subject"
    t.string   "book_title"
    t.string   "book_author"
    t.string   "chapter"
    t.string   "isbn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "in_q",          :default => false
    t.string   "upload_ticket"
    t.boolean  "approved",      :default => false
  end

  add_index "videos", ["user_id"], :name => "index_videos_on_user_id"
  add_index "videos", ["in_q"], :name => "index_videos_on_in_q"
  add_index "videos", ["upload_ticket"], :name => "index_videos_on_upload_ticket"

end
