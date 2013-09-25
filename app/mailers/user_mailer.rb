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

  # def response_email(poster)
  #   @user = poster
  #   mail to: @user.email, subject: 'You have a response waiting'
  # end
end
