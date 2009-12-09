class CreateAzoogleCreatives < ActiveRecord::Migration
  def self.up
    create_table :azoogle_creatives do |t|
      t.integer :azoogle_offer_id
      t.string :sub_id
      t.string :creative_type
      t.integer :width
      t.integer :height
      t.string :data
      t.timestamps
    end
    add_index :azoogle_creatives, [:azoogle_offer_id, :sub_id]
    add_index :azoogle_creatives, :creative_type
    add_index :azoogle_creatives, [:width, :height]
  end

  def self.down
    drop_table :azoogle_creatives
  end
end
