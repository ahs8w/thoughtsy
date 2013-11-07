module ProfileHelper
  
  def username(user)
    if user.id != current_user.id
      user.username
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

  def unique_posts(user)
    responses(user).map(&:post).uniq
  end
end