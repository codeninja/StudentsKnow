class AddPaypalEmail < ActiveRecord::Migration
  def self.up
    add_column :profiles, :paypal_email, :string
    add_index :profiles, :paypal_email
  end

  def self.down
    remove_column :profiles, :paypal_email
  end
end
