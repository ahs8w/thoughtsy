class RatingsController < ApplicationController
  before_action :signed_in_user

  # def create
  #   @rateable = params[:controller].classify.constantize.find(params[:id])
  #   if current_user.id == @rateable.user_id
  #     redirect_to parent_url, alert: "You cannot rate your own thought"
  #   else
  
  def create
    @rating = current_user.ratings.build(rating_params)
    if @rating.save
      flash.now[:success] = "Rating saved."
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: "Aack! Something went awry" }
        format.js #{ flash.now[:alert] = "Aack! Something went awry" }
      end
    end
  end

  private
    def parent_url
      if params[:controller] == 'posts'
        post_path(params[:id])
      else 
        response_path(params[:id])
      end
    end

    def rating_params
      params.require(:rating).permit(:rateable_id, :rateable_type, :value)
    end
end