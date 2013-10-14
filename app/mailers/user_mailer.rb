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

  def response_email(response)
    @response = response
    @post = @response.post
    @user = @post.user
    mail to: @user.email, subject: 'Someone has responded to your thought!'
  end

  def follower_response_email(response)
    @response = response
    @post = @response.post
    @recipients = @post.followers
    emails = @recipients.collect(&:email).join(', ')
    mail bcc: emails, to: 'info@thoughtsy.com', subject: "Someone has responded to the thought you're following"
  end

  def message_email(message)
    @message = message
    @recipient = User.find(@message.to_id)
    @sender = User.find(@message.user_id)
    mail to: @recipient.email, subject: "#{@sender.username} sent you a personal message."
  end

  def flag_email(post)
    @post = post
    mail to: 'admin@thoughtsy.com', subject: "Thoughtsy: post flagged"
  end

  def brilliant_email(response)
    @response = response
    mail to: 'admin@thoughtsy.com', subject: "Thoughtsy: response rated 'brilliant'"
  end
end