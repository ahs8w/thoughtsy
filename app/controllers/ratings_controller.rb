class RatingsController < ApplicationController
  before_action :signed_in_user
 
  def create
    @rating = current_user.ratings.build(rating_params)
    @rateable = @rating.rateable
    @message = Message.new
    if @rating.save
      # UserMailer.delay.brilliant_email(@response) if @rating.value == 5
      flash.now[:success] = "Rating saved."
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    else
      respond_to do |format|
        format.html do
          flash[:danger] = "Your rating could not be saved."
          redirect_to :back
        end
        format.js  { flash.now[:danger] = "Your rating could not be saved." }
      end
    end
  end


private


  def rating_params
    params.require(:rating).permit(:rateable_id, :rateable_type, :value)
  end
end