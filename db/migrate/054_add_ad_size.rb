class AddAdSize < ActiveRecord::Migration
  def self.up
    add_column :ads, :size, :string, :default => "oob"
    add_index :ads, :size
    Ad.find(:all).each{|a| a.save}
  end

  def self.down
    remove_index :ads, :size
    remove_column :ads, :size
  end
end
