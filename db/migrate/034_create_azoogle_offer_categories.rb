class CreateAzoogleOfferCategories < ActiveRecord::Migration
  def self.up
    create_table :azoogle_offer_categories do |t|
      t.string :name
    end
    add_index :azoogle_offer_categories, :name
    
    create_table :azoogle_offers_categories, :id => false do |t|
      t.integer :offer_id, :category_id
    end
    add_index :azoogle_offers_categories, [:category_id, :offer_id]
  end

  def self.down
    drop_table :azoogle_offer_categories
    drop_table :azoogle_offers_categories
  end
end
