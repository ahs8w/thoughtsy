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


  # scope :queued,      -> { where("state == ? OR state == ?", 'unanswered', 'subscribed') }
  # scope :a,           ->(user) { includes(:subscriptions).where.not(subscriptions: {user_id: user.id}).references(:subscriptions) }
  # scope :b,           ->(user) { joins(:subscriptions).where.not(subscriptions: {user_id: user.id}) }
  # scope :subscribed,  ->(user) { sub.joins(:subscriptions).where.not(subscriptions: {user_id: user.id}) }
  # scope :available, ->(user) { available_unanswered(user).available_subscribed(user) }


  after_create do |post|
    post.user.update_score!(1)
  end

  state_machine :state, initial: :unanswered do

    after_transition on: :flag do |post, transition|
      UserMailer.flag_email(post).deliver
      post.user.update_score!(-3)
    end

## keep for reference!!  pass in arguments to the transition callback  
    # after_transition on: :accept do |post, transition|
    #   post.set_responder_token(transition.args.first)
    # end

    event :accept do
      transition any => :pending
    end

    event :expire do
      transition any => :unanswered
    end

    event :answer do
      transition all - [:subscribed] => :answered
      transition :subscribed => :followed
    end

    event :unanswer do
      transition any => :unanswered
    end

    event :subscribe do
      transition any => :subscribed
    end

    event :flag do
      transition any => :flagged
    end
  end

  private
    def image_or_content
      errors.add(:base, "Post must include either an image or content") unless content.present? || image.present?
    end

## keep for reference!!  see above
  # def set_responder_token(id)
  #   self.responder_token = id
  #   save!
  # end
end
