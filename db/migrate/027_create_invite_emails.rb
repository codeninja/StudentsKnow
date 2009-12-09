class CreateInviteEmails < ActiveRecord::Migration
  def self.up
    create_table :invite_emails do |t|
      t.string :email
      t.boolean :delivered
      t.boolean :valid
      t.integer :invite_id

      t.timestamps
    end
  end

  def self.down
    drop_table :invite_emails
  end
end
