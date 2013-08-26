class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.text :content
      t.integer :user_id
      t.integer :post_id

      t.timestamps
    end
    add_index :responses, :user_id
    add_index :responses, :post_id
  end
end
