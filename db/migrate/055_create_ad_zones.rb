class CreateAdZones < ActiveRecord::Migration
  def self.up
    create_table :ad_zones do |t|
      t.integer :adpage_id
      t.string :name, :size
      t.timestamps
    end
    add_index :ad_zones, :adpage_id
    add_index :ad_zones, :name
    add_index :ad_zones, :size
  end

  def self.down
    drop_table :ad_zones
  end
end
