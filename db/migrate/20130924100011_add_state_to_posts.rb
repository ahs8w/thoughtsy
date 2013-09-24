class AddStateToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :state, :string
    add_index  :posts, :state

    remove_column :posts, :responded_to
  end
end
