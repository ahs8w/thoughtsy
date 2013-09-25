class Post < ActiveRecord::Base
  belongs_to :user, inverse_of: :posts
  has_many :responses, inverse_of: :post

  validates_presence_of :user_id, :content

  state_machine :state, initial: :unanswered do
    # after_transition on: :answer, do: [:send_response_email]

    event :accept do
      transition :unanswered => :pending
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

    def initialize
      super()
    end
  end
end
