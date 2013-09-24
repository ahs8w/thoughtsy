class Post < ActiveRecord::Base
  belongs_to :user, inverse_of: :posts
  has_many :responses, inverse_of: :post

  validates_presence_of :user_id, :content

  state_machine :state, initial: :unanswered do
    event :email do
      transition :unanswered => :emailed
    end

    event :decline do
      transition :emailed => :unanswered
    end

    event :accept do
      transition [:unanswered, :emailed] => :pending
    end

    event :expire do
      transition [:emailed, :pending] => :unanswered
    end

    event :answer do
      transition :pending => :answered
    end

    def initialize
      super()
    end
  end
end
