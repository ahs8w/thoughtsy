module ProfileHelper
  
  def username(user)
    if user.id != current_user.id
      user.username
    else
      "You"
    end
  end

  def average_user_rating(user)
    ratings = user.response_ratings
    unless ratings.empty?     
      "Average rating: #{ratings.sum('value')/ratings.size}"
    else
      "No ratings"
    end
  end

  def personal_posts(user)
    user.posts.personal.descending
  end

  # def unique_response_posts(user)
  #   # user.responses.descending.map(&:post).uniq
  #   # user.responses.pluck(:post).uniq
  # end

  def public_posts(user)
    posts = user.posts.answered + user.posts_responded_to.uniq
    posts.sort_by { |post| post[:updated_at] }.reverse!   # posts sorted by most recent update/responses
  end
end