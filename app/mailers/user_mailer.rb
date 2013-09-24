class UserMailer < ActionMailer::Base
  default from: "admin@thoughtsy.com"      #hash of default values for emails sent from this mailer

  def password_reset(user)
    @user = user
    mail to: @user.email, subject: 'Password reset'
  end
end
