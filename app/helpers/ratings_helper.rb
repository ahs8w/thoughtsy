module RatingsHelper

  def rating_ballot
    if @rating = current_user.ratings.where("rateable_type = ? AND rateable_id = ?", 
                                            params[:controller].classify, params[:id])
      @rating
    else
      @rating = current_user.ratings.new
      @rating
    end
  end
  # checks for existing rating from current user and returns it or creates a new rating for that user

  # def current_user_rating
  #   if @rating = current_user.ratings.where("rateable_type = ? AND rateable_id = ?", 
  #                                           params[:controller].classify, params[:id])
  #     @rating.value
  #   else
  #     'N/A'
  #   end
  # end

  def current_user_rating
    if @rating = current_user.ratings.find_by_rateable_id_and_rateable_type(params[:id], params[:controller].classify)
      @rating.value 
    else
      'N/A'
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
