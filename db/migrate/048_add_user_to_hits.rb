class AddUserToHits < ActiveRecord::Migration
  def self.up
    add_column :hits, :user_id, :integer, :default => 0
    add_index :hits, :user_id
  end

  def self.down
    remove_column :hits, :user_id
  end
end
