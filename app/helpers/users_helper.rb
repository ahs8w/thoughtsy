module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.username, class: "gravatar")
  end

  def username(thought)
    if thought.user.id != current_user.id
      thought.user.username
    else
      "You"
    end
  end

  def answered_posts(user)
    user.posts.answered.descending
  end

  def personal_posts(user)
    user.posts.personal.descending
  end

  def responses(user)
    user.responses.descending
  end
end
