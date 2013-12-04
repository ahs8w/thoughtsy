class Post < ActiveRecord::Base
  belongs_to :user, inverse_of: :posts, counter_cache: true
  has_many :responses
  has_many :ratings, through: :responses

  has_many :subscriptions
  has_many :followers, through: :subscriptions, source: :user
    # returns users which are following the post

  mount_uploader :image, ImageUploader
  
  validates_presence_of :user_id
  validate :image_or_content


  scope :ascending,   -> { order('updated_at ASC') }
  scope :descending,  -> { order('updated_at DESC') }
  scope :unanswered,  ->(user) { where("(state = ? OR state = ?) AND posts.user_id != ?",
                                       "unanswered", "reposted", user.id) }
  scope :available,   ->(user) { unanswered(user).where.not("? = ANY (unavailable_users)", user.id) }
  scope :answered,    -> { where("state = ? OR state = ?", "answered", "reposted") }
  scope :personal,    -> { where.not("state = ? OR state = ?", "answered", "reposted") }


  after_create do |post|
    post.user.update_score!(1)
  end

  state_machine :state, initial: :unanswered do

    after_transition on: :flag do |post, transition|
      UserMailer.delay.flag_email(post)
      post.user.update_score!(-3)
    end

    after_transition on: :accept do |post, transition|
      post.set_token_timer
      post.set_expiration_timer
    end

    after_transition on: :expire, do: :reset_token_timer


    event :accept do
      transition :subscribed => same
      transition any => :pending
    end

    event :expire do
      transition any => :unanswered
    end

    event :answer do
      transition :subscribed => :reposted
      transition any => :answered
    end

    event :unanswer do
      transition any => :unanswered
    end

    event :subscribe do
      transition any => :subscribed
    end

    event :unsubscribe do
      transition :subscribed => :pending
    end

    event :flag do
      transition any => :flagged
    end

    event :repost do
      transition any => :reposted
    end
  end


  def set_expiration_timer
    if token_timer? && token_timer < 24.hours.ago
      expire! unless answered? || reposted?
    end
  end
  handle_asynchronously :set_expiration_timer, :run_at => Proc.new { 25.hours.from_now }

  def set_token_timer
    self.update_attribute(:token_timer, Time.zone.now) unless self.token_timer
  end

  def reset_token_timer
    self.update_attribute(:token_timer, nil)
  end

  def add_unavailable_users(user)
    unavailable_users_will_change!
    self.update_attribute(:unavailable_users, unavailable_users.push(user.id))
  end
  
  def remove_unavailable_users(user)
    unavailable_users_will_change!
    self.update_attribute(:unavailable_users, (unavailable_users.delete(user.id); unavailable_users))
  end                                         # delete returns deleted value rather than the array...

  private
  
  def image_or_content
    errors.add(:base, "Post must include either an image or content") unless content.present? || image.present?
  end
end


## keep for reference!!  pass in arguments to the transition callback  
  # after_transition on: :accept do |post, transition|
  #   post.set_responder_token(transition.args.first)
  # end

  # def set_responder_token(id)
  #   self.responder_token = id
  #   save!
  # end
