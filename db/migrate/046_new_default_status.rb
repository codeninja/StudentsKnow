class NewDefaultStatus < ActiveRecord::Migration
  def self.up
    change_column :assets, :status, :integer, :default => 0
  end

  def self.down
  end
end
