class Rating < ActiveRecord::Base
  belongs_to :rateable, polymorphic: true
  belongs_to :user

  before_save { rateable_type.capitalize! } #must be Class name(capitalized) to call @rating.rateable

  validates_presence_of :user_id, :rateable_id, :rateable_type, :value
  # validation of unique rating per user per rateable_id/_type

  scope :Post, ->(id) { where("rateable_type = 'Post' AND rateable_id = ?", id) }
  scope :Response, ->(id) { where("rateable_type = 'Response' AND rateable_id = ?", id) }

end
