class AddResponseTimerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :response_timer, :datetime
  end
end
