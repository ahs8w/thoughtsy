class RatingsController < ApplicationController
  before_action :signed_in_user
 
  def create
    @rating = current_user.ratings.build(rating_params)
    @rateable = @rating.rateable
    @clicked = params[:commit]
    if @clicked == 'rubbish'
      @new_post = Post.available(current_user).ascending.first
      @rateable.unanswer!
      current_user.reset_tokens
      # send mail to admin
    end

    if @rating.save
      flash.now[:success] = "Rating saved."
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: "You have already rated this post." }
        format.js   { flash.now[:alert] = "You have already rated this post." }
      end
    end
  end

  private
    # def create
    #   if current_user.id == @rateable.user_id
    #     redirect_to parent_url, alert: "You cannot rate your own thought"
    #   else

    # def parent_url
    #   if params[:controller] == 'posts'
    #     post_path(params[:id])
    #   else 
    #     response_path(params[:id])
    #   end
    # end

    def rating_params
      params.require(:rating).permit(:rateable_id, :rateable_type, :value)
    end
end