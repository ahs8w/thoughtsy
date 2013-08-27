class UserMailer < ActionMailer::Base
  default from: "a.h.schiller@gmail.com"      #hash of default values for emails sent from this mailer

  def welcome_email(user)
    @user = user
    @url  = 'localhost:3000/users/#{@user.id}'
    mail(to: "#{@user.username} <#{@user.email}>", subject: 'Welcome to Thoughtsy!')
  end
end
