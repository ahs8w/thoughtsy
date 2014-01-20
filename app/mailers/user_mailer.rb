include PostsHelper

class UserMailer < ActionMailer::Base
  default from: "Thoughtsy@thoughtsy.com"      #hash of default values for emails sent from this mailer

  def welcome_email(user)
    @user = user
    mail to: @user.email, subject: 'Welcome to Thoughtsy'
  end

  def password_reset(user)
    @user = user
    mail to: @user.email, subject: 'Password reset'
  end

  def inactive_user_email(user)     # functional but not hooked up
    @user = user
    mail to: @user.email, subject: 'Thoughtsy needs you!'
  end

  def poster_email(response)
    @response = response
    @post = @response.post
    @username = @post.user.username
    mail to: @post.user.email, subject: 'Someone has responded to your thought!'
  end

  def responder_email(user, response)
    @response = response
    @post = response.post
    @username = user.username
    mail to: user.email, subject: 'Someone has responded to a shared thought!'
  end

  def self.response_emails(response)
    delay.poster_email(response)
    @post = response.post
    @author = response.user
    @responders = []
    @post.responses.each do |response|
      @responders << response.user unless response.user.id == @author.id
    end
    @responders.each do |user|
      delay.responder_email(user, response)
    end
  end

  def message_email(message)
    @message = message
    @recipient = User.find(@message.receiver_id)
    @sender = User.find(@message.user_id)
    mail to: @recipient.email, subject: "#{@sender.username} sent you a personal message."
  end

  def flag_email(post)
    @post = post
    mail to: 'a.h.schiller@gmail.com', subject: "Thoughtsy: post flagged"
  end

  def brilliant_email(rateable)
    @rateable = rateable.class.find(rateable.id)
    if @rateable.instance_of?(Post)
      @post = @rateable
    else
      @post = @rateable.post
    end
    mail to: 'a.h.schiller@gmail.com', subject: "Thoughtsy: thought rated 'brilliant'"
  end
end