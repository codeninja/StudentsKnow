class CreateAdbackends < ActiveRecord::Migration
  def self.up
    create_table :adbackends do |t|
      t.string :name
    end
    add_index :adbackends, :name
    
    Adbackend.create(:name => "azoogle")
  end

  def self.down
    drop_table :adbackends
  end
end
