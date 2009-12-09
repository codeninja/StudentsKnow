class CreateAds < ActiveRecord::Migration
  def self.up
    create_table :ads do |t|
      t.integer :adbackend_id, :offer_id, :width, :height
      t.string :name, :review_link
      t.text :code
      t.date :expires
      t.decimal :payout, :precision => 10, :scale => 2
      t.timestamps
    end
    add_index :ads, :adbackend_id
    add_index :ads, :offer_id
  end

  def self.down
    drop_table :ads
  end
end
