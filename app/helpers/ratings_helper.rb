module RatingsHelper

  def current_user_rating
    rating = current_user.ratings.find_by_rateable_id_and_rateable_type(@rateable.id, @rateable.class)
    rating.value
  end

  def human_value(value)
    "uninteresting" if value == 1
    "average" if value == 2
    "thought provoking" if value == 3
    "brilliant!" if value == 4
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
