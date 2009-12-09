class AddTierToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :tier, :integer, :default => 1
  end

  def self.down
    remove_column :users, :tier
  end
end
