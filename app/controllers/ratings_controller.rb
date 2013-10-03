class RatingsController < ApplicationController
  before_action :signed_in_user

  def create
    @rateable = params[:controller_name].classify.constantize.find(params[:id])
    if current_user.id == @rateable.user_id
      redirect_to parent_url, alert: "You cannot rate your own post"
    else
      @rating = @rateable.ratings.build(rating_params)
      if @rating.save
        flash.now[:success] = "Rating saved."
        respond_to do |format|
          format.html { redirect_to parent_url }
          format.js
        end
      else
        respond_to do |format|
          format.html { redirect_to parent_url, alert: "Aack! Something went awry." }
          format.js
        end
      end
    end
  end

  private
    def parent_url
      (params[:controller_name].singularize)_path(params[:id])
    end

    def rating_params
      params.require(:rating).permit(:value)
    end

end
