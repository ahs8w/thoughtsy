class AddRespondedToToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :responded_to, :boolean, default: false
    add_index  :posts, :responded_to
  end
end
