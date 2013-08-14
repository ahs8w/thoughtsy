class User < ActiveRecord::Base
# callbacks
  before_save { email.downcase! }


# validations
  validates :name, presence: true, length: { maximum: 50 }

  has_secure_password
  validates :password, length: { minimum: 6 }
            # presence validations are automatically added by has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
                    # uniqueness caveat -> does not guarantee uniqueness!!  must enforce at db level also w/ email index
end
