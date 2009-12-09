class CreateAzoogleOffers < ActiveRecord::Migration
  def self.up
    create_table :azoogle_offers do |t|
      t.integer :azoogle_account_id, :offer_id
      t.string  :title, 
                :description, 
                :notices 
      t.date :open_date, 
             :expiry_date
      t.decimal :amount
      t.timestamps
    end
    add_index :azoogle_offers, :azoogle_account_id
  end

  def self.down
    drop_table :azoogle_offers
  end
end
