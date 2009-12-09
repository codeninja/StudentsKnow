class AddWeightToAds < ActiveRecord::Migration
  def self.up
    add_column :ads, :weight, :integer, :default =>1
  end

  def self.down
    remove_column :ads, :weight
  end
end
