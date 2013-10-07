class RemoveDefaultValueFromRatings < ActiveRecord::Migration
  def change
    change_column_default :ratings, :value, nil
  end
end
