class Rating < ActiveRecord::Base
  belongs_to :rateable, polymorphic: true
  belongs_to :user

  before_save { rateable_type.capitalize! } #must be Class name(capitalized) to call @rating.rateable

  validates_presence_of :user_id, :rateable_id, :rateable_type, :value
end
