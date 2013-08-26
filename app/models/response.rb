class Response < ActiveRecord::Base
  validates_presence_of :user_id, :post_id, :content

  belongs_to :user
  belongs_to :post                    # must be on two seperate lines -> undefined method 'arity'

  default_scope -> { order('created_at DESC') }
end
