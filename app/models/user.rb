class User < ActiveRecord::Base
# associations
  has_many :posts, inverse_of: :user, dependent: :destroy
  has_many :responses, inverse_of: :user, dependent: :destroy
  has_many :response_posts, through: :responses, source: :post
    # all posts that a user has responded to

  has_many :ratings
  has_many :response_ratings, through: :responses, source: :ratings
    # all ratings for user.responses
  has_many :post_ratings, through: :posts, source: :ratings
    # all ratings for user.posts

  has_many :messages, inverse_of: :user
  has_many :received_messages, class_name: 'Message', foreign_key: :receiver_id
  

  scope :score_descending,  -> { order('score DESC') }


# callbacks
  before_save { email.downcase! }
  before_create :create_remember_token

# validations
  validates :username, presence: true, length: { maximum: 50 }

  has_secure_password
  validates :password, length: { minimum: 6 }, :if => :password_required?
            # presence validations are automatically added by has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
                    # uniqueness caveat -> does not guarantee uniqueness!!  must enforce at db level also w/ email index

# Session methods
  def User.new_remember_token
    SecureRandom.urlsafe_base64
    # any large random string works:  returns a random string of length 16 with each character having 64 possibilities
    # store this base64 token on the browser and an encrypted version in the database
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
    # encryption method we use to store the remember_token;  SHA1 is much faster than Bcrypt
  end

# Password_reset methods
  def send_password_reset
    generate_token(:password_reset_token)
    self.update_attribute(:password_reset_sent_at, Time.zone.now)
    UserMailer.delay.password_reset(self)
  end

  def generate_token(column)
    begin
      self[column] = User.new_remember_token
    end while User.exists?(column => self[column])
  end

# State_machine tokens
  def set_tokens(id)
    self.update_attribute(:token_id, id) unless self.token_id
    self.update_attribute(:token_timer, Time.zone.now) unless self.token_timer
  end

  def reset_tokens
    self.update_attribute(:token_id, nil)
    self.update_attribute(:token_timer, nil)
    # self.save!      #this sets off an error in the post form when token_timer > 24.hours.ago??
  end

  def timer_valid
    if self.token_timer?
      self.token_timer > 24.hours.ago
    else
      return false
    end
  end

  def posts_available
    Post.answerable(self).size > 0
  end

# Reputation
  def update_score!(value)
    new_score = self.score + value
    self.update_attribute(:score, new_score)
  end
  
  private

    def password_required?                # necessary for 'password_reset' to function
      !persisted? || !password.nil? || !password_confirmation.nil?
    end

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
