module RatingsHelper

  def current_user_rating(thought)
    rating = current_user.ratings.find_by_rateable_id_and_rateable_type(thought.id, thought.class.name)
    human_value(rating.value)
  end
  ## find by rateable_id and type

  def human_value(value)
    if value == 1 then "weak"
    elsif value == 2 then "average"
    elsif value == 3 then "thought provoking"
    elsif value == 5 then "brilliant!"
    end
  end
end
