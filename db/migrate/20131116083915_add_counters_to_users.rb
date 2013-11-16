class AddCountersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :posts_count, :integer, default: 0, null: false
    add_column :users, :responses_count, :integer, default: 0, null: false

    User.find_each(select: 'id') do |result|
      User.reset_counters(result.id, :posts)
      User.reset_counters(result.id, :responses)
    end
  end
end
