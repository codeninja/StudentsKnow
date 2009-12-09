class AddTextOnlyFieldToAds < ActiveRecord::Migration
  def self.up
    add_column :ads, :text_only, :boolean, :default => false
    add_index :ads, :text_only
  end

  def self.down
    remove_index :ads, :text_only
    remove_column :ads, :text_only
  end
end
