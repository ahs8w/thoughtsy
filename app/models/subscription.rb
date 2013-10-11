class Subscription < ActiveRecord::Base
  belongs_to :post
  belongs_to :user

  validates_presence_of :user_id, :post_id
end
