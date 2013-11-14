include PostsHelper

class UserMailer < ActionMailer::Base
  default from: "admin@thoughtsy.com"      #hash of default values for emails sent from this mailer

  def password_reset(user)
    @user = user
    mail to: @user.email, subject: 'Password reset'
  end

  def inactive_user_email(user)     # functional but not hooked up
    @user = user
    mail to: @user.email, subject: 'Thoughtsy needs you!'
  end

  def poster_email(user, response)
    @response = response
    @post = @response.post
    @username = user.username
    mail to: user.email, subject: 'Someone has responded to your thought!'
  end

  def follower_email(user, response)
    @response = response
    @post = @response.post
    @username = user.username
    mail to: user.email, subject: "Your followed post has a new response!"
  end

  def self.response_emails(response)
    @post = response.post
    @user = @post.user
    delay.poster_email(@user, response)
    unless @post.followers.empty?
      @post.followers.each do |follower|
        delay.follower_email(follower, response) unless follower == response.user
      end
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
    mail to: 'admin@thoughtsy.com', subject: "Thoughtsy: post flagged"
  end

  def brilliant_email(response)
    @response = response
    @post = @response.post
    mail to: 'admin@thoughtsy.com', subject: "Thoughtsy: response rated 'brilliant'"
  end
end