class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :post_id

      t.timestamps
    end

    add_index :subscriptions, :user_id
    add_index :subscriptions, :post_id
    add_index :subscriptions, [:post_id, :user_id], unique: true
  end
end