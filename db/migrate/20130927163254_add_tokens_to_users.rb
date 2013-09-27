class AddTokensToUsers < ActiveRecord::Migration
  def change
    add_column :users, :token_id,    :integer
    add_column :users, :token_timer, :datetime
  end
end
