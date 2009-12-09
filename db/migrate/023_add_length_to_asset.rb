class AddLengthToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :length, :string
  end

  def self.down
    remove_column :assets, :length
  end
end
