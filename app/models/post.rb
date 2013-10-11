class Post < ActiveRecord::Base
  belongs_to :user, inverse_of: :posts
  has_many :responses

  has_many :subscriptions
  has_many :followers, through: :subscriptions, source: :user
  
  validates_presence_of :user_id, :content

  scope :ascending, -> { order('created_at ASC') }
  scope :available, ->(user) { where("state == 'unanswered' AND user_id != ?", user.id) }

  state_machine :state, initial: :unanswered do

## keep for reference!!  pass in arguments to the transition callback  
    # after_transition on: :accept do |post, transition|
    #   post.set_responder_token(transition.args.first)
    # end

    event :accept do
      transition any => :pending
    end

    event :expire do
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
  end

## keep for reference!!  see above
  # def set_responder_token(id)
  #   self.responder_token = id
  #   save!
  # end
end
