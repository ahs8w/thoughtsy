module UsersHelper

# Home Page #
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.username, class: "gravatar")
  end

  def unrated_responses(user)
    unrated = []
    user.posts.answered.each do |post|
      post.responses.each do |response|
        if response.ratings.where(user_id: user.id).empty?
          unrated << response
        end
      end
    end
    if unrated.count == 1
      link_to("You have 1 unrated response", post_path(unrated.first.post))
    elsif unrated.count > 1
      link_to("You have #{pluralize(unrated.count, 'unrated response')}", user_path(user))
    end
  end

  def unread_messages(user)
    msgs = user.received_messages.unread
    count = msgs.count
    link_to("You have #{pluralize(count, 'unread message')}", user_messages_path(user)) unless msgs.empty?
  end

end
