class Response < ActiveRecord::Base
  validates_presence_of :user_id, :post_id, :content

  belongs_to :user, inverse_of: :responses
  belongs_to :post, inverse_of: :responses         # must be on two seperate lines -> undefined method 'arity'

  default_scope -> { order('created_at DESC') }  # scopes take an anonymous function (for 'lazy' evaluation)
end
