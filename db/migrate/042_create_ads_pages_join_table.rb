class CreateAdsPagesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :adpages_ads, :id => false do |t|
      t.integer :ad_id, :adpage_id
    end
    add_index :adpages_ads, [:ad_id, :adpage_id]
  end

  def self.down
    drop_table :adpages_ads
  end
end
