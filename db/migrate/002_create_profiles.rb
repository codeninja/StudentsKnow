class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :country, :state, :zip, :gender, :university
      t.datetime :dob, :start, :graduation
      t.boolean :receive_emails, :email_sent, :over_13, :terms
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
