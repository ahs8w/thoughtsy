class AddResponderTokenToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :responder_token, :integer
  end
end
