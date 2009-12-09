class CreateAzoogleAccounts < ActiveRecord::Migration
  def self.up
    create_table :azoogle_accounts do |t|
      t.string :login_hash
      t.timestamps
    end
  end

  def self.down
    drop_table :azoogle_accounts
  end
end
