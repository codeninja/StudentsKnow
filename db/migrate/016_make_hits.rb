class MakeHits < ActiveRecord::Migration
  def self.up
    create_table :hits do |t|
      t.string :hittable_type, :kind
      t.integer :hittable_id
      t.timestamps
    end
    add_index :hits, [:hittable_id, :hittable_type, :kind]
  end

  def self.down
    drop_table :hits
  end
end
