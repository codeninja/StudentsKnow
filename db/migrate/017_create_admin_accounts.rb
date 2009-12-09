class CreateAdminAccounts < ActiveRecord::Migration

  def self.up
    create_table :admins, :force => true do |t|
      t.string :login, :email, :name_first, :name_middle, :name_last
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :time_zone, :default => 'Etc/UTC'
      t.timestamps
      t.string :remember_token
      t.datetime :remember_token_expires_at
      t.string :activation_code, :limit => 40
      t.datetime :activated_at
      t.integer :visits_count
      t.datetime :last_login_at
      t.string :password_reset_code, :limit => 40
      t.datetime :password_reset_at
    end
    add_index :admins, :login
  end

  def self.down
    drop_table :admins
  end
end


