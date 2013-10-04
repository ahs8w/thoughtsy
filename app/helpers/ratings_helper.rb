module RatingsHelper

  def current_user_rating
    if @rating = current_user.ratings.find_by_rateable_id_and_rateable_type(params[:id], params[:controller].classify)
      @rating.human_value 
    else
      'N/A'
    end
  end

  def human_value
    case
      when '1' then "uninteresting"
      when '2' then "average"
      when '3' then "thought provoking"
      when '4' then "brilliant!"
    end
  end

  def average_rating
    if ratings.exists?
      @value = 0
      self.ratings.each do |rating|
        @value = @value + rating.value
      end
      @total = self.ratings.size
      @value.to_f / @total.to_f
    else
      "not yet rated"
    end
  end

end
