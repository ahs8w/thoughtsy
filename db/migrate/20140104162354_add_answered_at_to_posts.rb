class AddAnsweredAtToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :answered_at, :datetime
  end
end
