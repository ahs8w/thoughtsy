class Rating < ActiveRecord::Base
  belongs_to :response
  belongs_to :user

  validates_presence_of :user_id, :response_id, :value
  validates_uniqueness_of :user_id, scope: :response_id, message: "You already rated this thought."
end
