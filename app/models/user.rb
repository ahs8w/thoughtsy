class User < ActiveRecord::Base
# associations
  has_many :posts, inverse_of: :user, dependent: :destroy
  has_many :responses, inverse_of: :user, dependent: :destroy
  has_many :ratings
  has_many :messages

  has_many :subscriptions
  has_many :followed_posts, through: :subscriptions, source: :post

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

# User.methods
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
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = User.new_remember_token
    end while User.exists?(column => self[column])
  end

# State_machine tokens
  def set_tokens(id)
    self.token_id ||= id
    self.token_timer ||= Time.zone.now
    save!
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
    Post.available(self).size > 0
  end

# Subscriptions
  def subscribe!(post)
    self.subscriptions.create!(post_id: post.id)
  end

  def unsubscribe!(post)
    self.subscriptions.find_by(post_id: post.id).destroy!
  end
  
  private

    def password_required?                # necessary for 'password_reset' to function
      !persisted? || !password.nil? || !password_confirmation.nil?
    end

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
