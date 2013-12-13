class AddImageProcessedToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :image_processed, :boolean
  end
end
