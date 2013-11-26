module UsersHelper

# Home Page #
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.username, class: "gravatar")
  end

  def unrated_array(user)
    unrated = []
    user.posts.answered.each do |post|
      post.responses.each do |response|
        if response.ratings.where(user_id: user.id).empty?
          unrated << response
        end
      end
    end
    return unrated
  end

  # def unrated_responses(user)
  #   unrated = unrated_array(user)
  #   if unrated.count == 1
  #     link_to("You have 1 unrated response", post_path(unrated.first.post))
  #   elsif unrated.count > 1
  #     link_to("You have #{pluralize(unrated.count, 'unrated response')}", user_path(user))
  #   end
  # end

  def unrated_response_path(user)
    unrated = unrated_array(user)
    if unrated.count == 1
      post_path(unrated.first.post)
    elsif unrated.count > 1
      user_path(user)
    end
  end

  def unrated_response_text(user)
    unrated = unrated_array(user)
    if unrated.count == 1
      "1 unrated response"
    elsif unrated.count > 1
      "#{pluralize(unrated.count, 'unrated response')}"
    end
  end

  def unread_messages(user)
    msgs = user.received_messages.unread
    link_to("You have #{pluralize(msgs.count, 'unread message')}", user_messages_path(user)) unless msgs.empty?
  end

  def unread_message_text(user)
    msgs = user.received_messages.unread
    "#{pluralize(msgs.count, 'unread message')}"
  end
end
