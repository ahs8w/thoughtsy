class Post < ActiveRecord::Base
  belongs_to :user, inverse_of: :posts, counter_cache: true
  
  has_many :responses
  has_many :responders, through: :responses, source: :user

  has_many :ratings, as: :rateable, dependent: :destroy
  has_many :raters, through: :ratings, source: :user

  mount_uploader :image, ImageUploader
  
  validates_presence_of :user_id
  validate :image_or_content

  after_create do |post|
    post.user.update_score!(1)
    post.add_unavailable_users(post.user)
    post.set_sort_date
  end


  scope :ascending,   -> { order('sort_date ASC') }
  scope :descending,  -> { order('sort_date DESC') }

  scope :queued,      -> { where("state = ? OR state = ?", "unanswered", "answered") }
  scope :answerable,  ->(user) { queued.where.not("? = ANY (unavailable_users)", user.id) }

  scope :answered,    -> { where("state = ? OR state = ?", "answered", "unqueued") }
  scope :personal,    -> { where.not("state = ? OR state = ?", "answered", "unqueued") }


  state_machine :state, initial: :unanswered do

    after_transition on: :flag do |post, transition|
      UserMailer.delay.flag_email(post)
      post.user.update_score!(-3)
    end

    after_transition on: :accept, do: :set_token_timer
    after_transition on: :expire, do: :reset_token_timer
    after_transition on: :answer do |post, transition| 
      post.set_sort_date
      post.unqueue! unless post.respondable?
    end

    event :accept do
      transition any => :pending
    end

    event :expire do
      transition :pending => :answered, :if => lambda { |post| post.responses.any? }
      transition :pending => :unanswered
    end

    event :answer do
      transition any => :answered
    end

    event :unanswer do
      transition any => :unanswered
    end

    event :flag do
      transition any => :flagged
    end

    event :unqueue do
      transition any => :unqueued
    end
  end

  def respondable?
    self.responses.size < 3 || self.avg_score >= 4
  end

  def avg_score
    if self.ratings.size != 0
      self.ratings.sum('value')/self.ratings.size
    else
      0
    end
  end

  def set_token_timer
    self.update_attribute(:token_timer, Time.zone.now) unless self.token_timer
  end

  def reset_token_timer
    self.update_attribute(:token_timer, nil)
  end

  def set_sort_date
    self.update_attribute(:sort_date, Time.zone.now)
  end

  def add_unavailable_users(user)
    unavailable_users_will_change!
    self.update_attribute(:unavailable_users, unavailable_users.push(user.id))
  end
  
  def remove_unavailable_users(user)
    unavailable_users_will_change!
    self.update_attribute(:unavailable_users, (unavailable_users.delete(user.id); unavailable_users))
  end                                         # delete returns deleted value rather than the array...

  ############# Heroku Scheduler ##############
  def Post.check_expirations
    pending_posts = Post.where(state: 'pending')
    pending_posts.each do |post|
      post.expire! if post.token_timer? && post.token_timer < 24.hours.ago
    end
  end

  ### Carrierwave-direct image upload helpers ###
  def image_name
    File.basename(image.path || image.filename) if image
  end

  def enqueue_image
    if has_image_upload? && !image_processed
      Delayed::Job.enqueue ImageProcessor.new(id, key)
    end
  end

  class ImageProcessor < Struct.new(:id, :key)
    def perform
      post = Post.find(id)
      post.key = key
      post.remote_image_url = post.image.direct_fog_url(with_path: true)
      post.update_column(:image_processed, true)
      post.save!
    end
  end

private

  def image_or_content
    errors.add(:base, "Post must include either an image or content") unless content.present? || has_image_upload?
  end
end