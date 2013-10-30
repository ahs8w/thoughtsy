class Response < ActiveRecord::Base
  validates_presence_of :user_id, :post_id
  validate :image_or_content

  belongs_to :user, inverse_of: :responses
  belongs_to :post                               # must be on two seperate lines -> undefined method 'arity'
  
  has_many :ratings, dependent: :destroy
  has_many :raters, through: :ratings, source: :user

  mount_uploader :image, ImageUploader

  scope :descending, -> { order('created_at DESC') }  # scopes take an anonymous function (for 'lazy' evaluation)
  scope :ascending,  -> { order('created_at ASC') }

  private
    def image_or_content
      errors.add(:base, "Post must include either an image or content") unless content.present? || image.present?
    end
end
