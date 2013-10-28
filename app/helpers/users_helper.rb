module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.username, class: "gravatar")
  end

  def username(user)
    if user.id != current_user.id
      user.username
    else
      "You"
    end
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
      link_to("You have 1 unrated response", post_response_path(unrated.first.post, unrated.first))
    elsif unrated.count > 1
      link_to("You have #{pluralize(unrated.count, 'unrated response')}", user_path(user))
    end
  end

# Profile Page #
  def answered_posts(user)
    user.posts.answered.descending
  end

  def personal_posts(user)
    user.posts.personal.descending
  end

  def responses(user)
    user.responses.descending
  end

  def unique_posts(user)
    responses(user).map(&:post).uniq
  end
end
