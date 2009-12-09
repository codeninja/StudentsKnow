class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :friends
      t.string :message

      t.timestamps
    end
  end

  def self.down
    drop_table :invites
  end
end
