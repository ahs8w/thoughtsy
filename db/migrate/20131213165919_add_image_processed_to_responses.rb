class AddImageProcessedToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :image_processed, :boolean
  end
end
