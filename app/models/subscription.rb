class Subscription < ActiveRecord::Base
  belongs_to :post
  belongs_to :user

  validates_presence_of :user_id, :post_id

  after_create do |subscription|
    subscription.post.user.update_score!(3)
  end

  after_destroy do |subscription|
    subscription.post.user.update_score!(-3)
  end
end
