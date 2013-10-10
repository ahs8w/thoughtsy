class AddFollowerIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :follower_id, :integer
    add_index  :posts, :follower_id
  end
end
