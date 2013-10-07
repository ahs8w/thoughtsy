class Rating < ActiveRecord::Base
  belongs_to :rateable, polymorphic: true
  belongs_to :user

  before_save { rateable_type.capitalize! } #must be Class name(capitalized) to call @rating.rateable

  validates_presence_of :user_id, :rateable_id, :rateable_type, :value
  validates_uniqueness_of :user_id, scope: [:rateable_id, :rateable_type], message: "You already rated this thought."

  scope :Post, ->(id) { where("rateable_type = 'Post' AND rateable_id = ?", id) }
  scope :Response, ->(id) { where("rateable_type = 'Response' AND rateable_id = ?", id) }
end
