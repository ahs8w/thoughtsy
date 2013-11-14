module RatingsHelper

  def current_user_rating(thought)
    rating = current_user.ratings.find_by_response_id(thought.id)
    human_value(rating.value)
  end

  def human_value(value)
    if value == 1 then "weak"
    elsif value == 2 then "average"
    elsif value == 3 then "thought provoking"
    elsif value == 5 then "brilliant!"
    end
  end
end
