class Response < ActiveRecord::Base

# Class methods {  
  validates_presence_of :user_id, :post_id
  validate :image_or_content

  belongs_to :user, inverse_of: :responses, counter_cache: true
  belongs_to :post                  # must be on two seperate lines -> undefined method 'arity'
  
  has_many :ratings, dependent: :destroy
  has_many :raters, through: :ratings, source: :user

  after_save :update_all

  mount_uploader :image, ImageUploader

  scope :descending, -> { order('created_at DESC') }  # scopes take an anonymous function (for 'lazy' evaluation)
  scope :ascending,  -> { order('created_at ASC') }
# }

  private

  # Instance methods {
    def image_or_content
      errors.add(:base, "Post must include either an image or content") unless content.present? || image.present?
    end

    def update_all
      self.post.answer!
      self.user.reset_tokens
      UserMailer.response_emails(self)
    end
  # }
end
