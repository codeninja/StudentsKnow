class CreateKnows < ActiveRecord::Migration
  def self.up
    create_table :knows do |t|
      t.integer :user_id, :knowable_id
      t.string :knowable_type
      t.timestamps
    end
    
    add_index :knows, :user_id
    add_index :knows, [:knowable_id, :knowable_type]
    
    Video.find(:all).each do |v|
      k = Know.create(:user_id => v.user_id, :knowable_id => v.id, :knowable_type => 'Video')
      k.tag_list = v.tag_list
    end
  end

  def self.down
    drop_table :knows
  end
end
