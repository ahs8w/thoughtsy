module MessagesHelper

  def user_display(message)
    if current_user == message.user
      "To: #{message.receiver.username}"
    else
      "From: #{message.user.username}"
    end
  end
end