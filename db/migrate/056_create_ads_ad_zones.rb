class CreateAdsAdZones < ActiveRecord::Migration
  def self.up
    create_table :ad_zones_ads, :id => false do |t|
      t.integer :ad_id, :ad_zone_id
    end
    add_index :ad_zones_ads, [:ad_id, :ad_zone_id]
  end

  def self.down
    drop_table :ad_zones_ads
  end
end
