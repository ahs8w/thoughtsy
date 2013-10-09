module RatingsHelper

  def current_user_rating
    rating = current_user.ratings.find_by_response_id(@response.id)
    human_value(rating.value)
  end

  def human_value(value)
    if value == 1 then "weak"
    elsif value == 2 then "average"
    elsif value == 3 then "thought provoking"
    elsif value == 4 then "brilliant!"
    end
  end
end

  # def average_rating
  #   if ratings.exists?
  #     @value = 0
  #     self.ratings.each do |rating|
  #       @value = @value + rating.value
  #     end
  #     @total = self.ratings.size
  #     @value.to_f / @total.to_f
  #   else
  #     "not yet rated"
  #   end
  # end
