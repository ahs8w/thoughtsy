class AddResponseIdToRatings < ActiveRecord::Migration
  def change
    change_table :ratings do |t|
      t.integer :response_id
      t.remove :rateable_id, :rateable_type
    end
  end
end
