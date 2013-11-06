class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :receiver, class_name: 'User'

  validates_presence_of :user_id, :content, :receiver_id

  scope :unread, -> { where(viewed?: false) }

  after_save :send_email

  def set_viewed?
    self.update_attribute(:viewed?, true)
  end


  private

  def send_email
    UserMailer.delay.message_email(self)
  end
end
