class Response < ActiveRecord::Base
  belongs_to :user, inverse_of: :responses, counter_cache: true
  belongs_to :post                  # must be on two seperate lines -> undefined method 'arity'
  
  has_many :ratings, dependent: :destroy
  has_many :raters, through: :ratings, source: :user

  after_save :update_all, :enqueue_image

  mount_uploader :image, ImageUploader

  validates_presence_of :user_id, :post_id
  validate :image_or_content


  scope :descending, -> { order('created_at DESC') }  # scopes take an anonymous function (for 'lazy' evaluation)
  scope :ascending,  -> { order('created_at ASC') }


  # Carrierwave-direct image upload helper
  def image_name
    File.basename(image.path || image.filename) if image
  end

  def enqueue_image
    if has_image_upload? && !image_processed
      self.process_image
    end
  end
  def process_image
    self.remote_image_url = image.direct_fog_url(with_path: true)
    self.update_column(:image_processed, true)
    save
  end
  
private

  def image_or_content
    errors.add(:base, "Response must include either an image or content") unless content.present? || has_image_upload?
  end

  def update_all
    self.post.answer!
    self.user.reset_tokens
    UserMailer.response_emails(self)
  end

  def self.unrated
    includes(:ratings).where("ratings.id IS NULL").references(:ratings)
    # joins('LEFT OUTER JOIN ratings ON ratings.response_id = responses.id WHERE ratings.id IS NULL')
  end
end
