module RatingsHelper

  def current_user_rating
    # if @rating = current_user.ratings.find_by_rateable_id_and_rateable_type(params[:id], params[:controller].classify)
    if @rateable.raters.first == current_user
      @rateable.ratings.first.value
    else
      'N/A'
    end
  end

  def human_value
    "uninteresting" if 1
    "average" if 2
    "thought provoking" if 3
    "brilliant!" if 4
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
