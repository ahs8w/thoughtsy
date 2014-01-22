module ProfileHelper
  require 'will_paginate/array'
  
  def username(user)
    if user.id != current_user.id
      user.username
    else
      "You"
    end
  end

  def average_response_rating(user)
    ratings = user.response_ratings
    unless ratings.empty?     
      "Average rating: #{(ratings.sum('value').to_f/ratings.size).round(2)}"
    else
      "No ratings"
    end
  end

  def average_post_rating(user)
    ratings = user.post_ratings
    unless ratings.empty?     
      "Average rating: #{(ratings.sum('value').to_f/ratings.size).round(2)}"
    else
      "No ratings"
    end
  end

  def average_rating(thought)
    (thought.ratings.sum('value').to_f/thought.ratings.size).round(2)
  end

  def unrated_count(post)
    pluralize(post.responses.unrated.size, "unrated response")
  end

  def personal_posts(user)
    user.posts.personal.descending
  end

  def public_posts(user)
    posts = user.posts.answered + user.response_posts.uniq
    posts.sort_by { |post| post[:sort_date] }.reverse!   # posts sorted by most recent update/responses
  end

  def settings_link
    if signed_in?
      link_to "user settings page", edit_user_path(current_user)
    else
      "user settings page when signed in"
    end
  end
end