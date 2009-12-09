class AddReferrals < ActiveRecord::Migration
  def self.up
    create_table :referrals do |t|
      t.string :code, :referrable_type
      t.integer :user_id, :referrable_id
    end
    add_index :referrals, [:referrable_id, :referrable_type]
    add_index :referrals, :code
    add_index :referrals, :user_id
  end

  def self.down
    drop_table :referrals
  end
end
