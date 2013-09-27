class Post < ActiveRecord::Base
  belongs_to :user, inverse_of: :posts
  has_one :response

  validates_presence_of :user_id, :content

  default_scope -> { order('created_at ASC') }

  state_machine :state, initial: :unanswered do
    after_transition on: :answer, do: [:send_response_email, :reset_responder_token]

# allows us to pass in arguments to the transition callback to define the user  
    after_transition on: :accept do |post, transition|
      post.set_responder_token(transition.args.first)
    end

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
  end

  def send_response_email
    UserMailer.response_email(self.user).deliver
  end

  def set_responder_token(id)
    self.responder_token = id
    save!
  end

  def reset_responder_token
    self.responder_token = nil
    save!
  end
end
