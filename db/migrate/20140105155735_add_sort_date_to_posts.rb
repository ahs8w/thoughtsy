class AddSortDateToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :sort_date, :datetime
  end
end
