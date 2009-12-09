class AddFbidToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :fbid, :integer
    add_index :users, :fbid
  end

  def self.down
    remove_column :users, :fbid
  end
end
