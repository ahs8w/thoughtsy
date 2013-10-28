class AddTokenToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :viewed?, :boolean, default: :false
    rename_column :messages, :to_id, :receiver_id
  end
end
