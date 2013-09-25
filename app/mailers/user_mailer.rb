class UserMailer < ActionMailer::Base
  default from: "admin@thoughtsy.com"      #hash of default values for emails sent from this mailer

  def password_reset(user)
    @user = user
    mail to: @user.email, subject: 'Password reset'
  end

  def post_email(user)
    @user = user
    mail to: @user.email, subject: 'Thoughtsy needs you!'
  end

  def response_email(user)
    @user = user
    mail to: @user.email, subject: 'Someone has responded to your thought!'
  end
end
