class AddRateableReferencesToRatings < ActiveRecord::Migration
  def change
    rename_column :ratings, :response_id, :rateable_id
    add_column    :ratings, :rateable_type, :string

    Rating.reset_column_information
    reversible do |dir|
      dir.up { Rating.update_all rateable_type: 'Response' }
    end
  end
end
