module RatingsHelper

  def current_user_rating
    if @post.raters.include?(current_user)
      @current_user.ratings.
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
