class UserMailer < ActionMailer::Base
  default from: "admin@thoughtsy.com"      #hash of default values for emails sent from this mailer

  def password_reset(user)
    @user = user
    mail to: @user.email, subject: 'Password reset'
  end

  def inactive_user_email(user)
    @user = user
    mail to: @user.email, subject: 'Thoughtsy needs you!'
  end

  def response_email(user)
    @user = user
    mail to: @user.email, subject: 'Someone has responded to your thought!'
    # followers.each do |f|
    #   mail to: f.email, subject: "Someone has responded to the thought you're following"
    # end
  end
end
