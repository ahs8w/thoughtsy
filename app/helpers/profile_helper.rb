module ProfileHelper
  
  def username(user)
    if user.id != current_user.id
      user.username
    else
      "You"
    end
  end

  def average_user_rating(user)
    unless user.response_ratings.empty?
      score = 0
      user.response_ratings.each do |rating|
        score += rating.value
      end
      total = user.response_ratings.size
      "average rating: #{score.to_f / total.to_f}"
    else
      "user has no rated responses"
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