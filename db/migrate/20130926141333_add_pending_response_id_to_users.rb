class AddPendingResponseIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pending_response_id, :integer
  end
end
