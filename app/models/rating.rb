class Rating < ActiveRecord::Base
  belongs_to :rateable, polymorphic: true
  belongs_to :user

  validates_presence_of :user_id, :rateable_id, :rateable_type, :value
  validates_uniqueness_of :user_id, scope: [:rateable_id, :rateable_type], message: "already rated this thought."
  validates_with RateableAuthorValidator, fields: :user_id

  after_create do |rating|
    rating.rateable.user.update_score!(rating.value)
  end
end