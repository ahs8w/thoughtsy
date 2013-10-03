class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :user_id
      t.integer :rateable_id
      t.string :rateable_type, limit: 20
      t.integer :value

      t.timestamps
    end
    add_index :ratings, :user_id
  end
end
