class AddTokenTimerToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :token_timer, :datetime
  end
end
