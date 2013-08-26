class AddIndexCreatedAtToResponses < ActiveRecord::Migration
  def change
    add_index :responses, :created_at
  end
end
