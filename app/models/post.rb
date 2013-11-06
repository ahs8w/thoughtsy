class Post < ActiveRecord::Base
  belongs_to :user, inverse_of: :posts
  has_many :responses
  has_many :ratings, through: :responses

  has_many :subscriptions
  has_many :followers, through: :subscriptions, source: :user

  mount_uploader :image, ImageUploader
  
  validates_presence_of :user_id
  validate :image_or_content


  scope :ascending,   -> { order('created_at ASC') }
  scope :descending,  -> { order('created_at DESC') }
  scope :available,   ->(user) { where("(state == ? OR state == ?) AND posts.user_id != ?",
                                       'unanswered', 'followed', user.id) }
  scope :answered,    -> { where("state == ? OR state == ?", 'answered', 'followed') }
  scope :personal,    -> { where.not("state == ?", 'answered') }


  after_create do |post|
    post.user.update_score!(1)
  end

  state_machine :state, initial: :unanswered do

    after_transition on: :flag do |post, transition|
      UserMailer.delay.flag_email(post)
      post.user.update_score!(-3)
    end

    event :accept do
      transition :subscribed => same
      transition any => :pending
    end

    event :expire do
      transition any => :unanswered
    end

    event :answer do
      transition :subscribed => :followed
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
  end


  def self.set_expiration_timer(id)   # makes job queue simpler than passing instances to YAML
    find(id).set_expiration_timer
  end

  def set_expiration_timer
    unless answered? || followed?
      expire!
    end
  end
  handle_asynchronously :set_expiration_timer, :run_at => Proc.new { 25.hours.from_now }


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
