class AddVideoStatus < ActiveRecord::Migration
  def self.up
    add_column :assets, :status, :integer, :default => 2
    add_index :assets, :status
  end

  def self.down
    remove_column :assets, :status
  end
end
