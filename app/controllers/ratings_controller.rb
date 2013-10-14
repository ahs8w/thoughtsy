class RatingsController < ApplicationController
  before_action :signed_in_user
 
  def create
    @rating = current_user.ratings.build(rating_params)
    @response = @rating.response
    @message = Message.new
    if @rating.save
      UserMailer.brilliant_email(@response).deliver if params[:commit] == 'brilliant!'
      flash.now[:success] = "Rating saved."
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: "Your rating could not be saved." }
        format.js   { flash.now[:alert] = "Your rating could not be saved." }
      end
    end
  end

  private
    def rating_params
      params.require(:rating).permit(:response_id, :value)
    end
end