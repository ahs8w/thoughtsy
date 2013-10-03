module RatingsHelper

  def rating_ballot
    if @rating = current_user.ratings.where("rateable_type = ? AND rateable_id = ?", 
                                            params[:controller_name].classify, params[:id])
      @rating
    else
      current_user.ratings.new
    end
  end
  # checks for existing rating from current user and returns it or creates a new rating for that user

  def current_user_rating
    if @rating = current_user.ratings.where("rateable_type = ? AND rateable_id = ?", 
                                            params[:controller_name].classify, params[:id])
      @rating.value
    else
      'N/A'
    end
  end

end
