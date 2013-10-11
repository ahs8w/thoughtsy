class RemoveFollowerIdFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :follower_id
  end
end
