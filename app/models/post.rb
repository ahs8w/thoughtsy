class Post < ActiveRecord::Base
  belongs_to :user, inverse_of: :posts
  has_many :responses, inverse_of: :post

  validates_presence_of :user_id, :content

  def responded_to?
    !self.responses.empty?
  end
end
