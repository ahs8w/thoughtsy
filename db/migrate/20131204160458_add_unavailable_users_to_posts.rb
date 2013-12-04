class AddUnavailableUsersToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :unavailable_users, :integer, array: true, default: []
  end
end
