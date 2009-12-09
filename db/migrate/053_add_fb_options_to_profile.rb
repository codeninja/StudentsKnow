class AddFbOptionsToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :fb_options, :text
  end

  def self.down
    remove_column :profiles, :fb_options
  end
end
