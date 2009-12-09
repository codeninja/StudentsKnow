class AddSystemTable < ActiveRecord::Migration
  def self.up
     create_table :rates do |r|
        r.string :rate_name
        r.float :rate
      end
       Rate.create(:rate_name => "referral", :rate => 0.01)
       Rate.create(:rate_name => "view", :rate => 0.02 )

  end

  def self.down
     drop_table :rates
  end
end
