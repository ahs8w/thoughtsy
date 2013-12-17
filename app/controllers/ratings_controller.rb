class RatingsController < ApplicationController
  before_action :signed_in_user
  before_action :follower_or_author
 
  def create
    @rating = current_user.ratings.build(rating_params)
    @response = @rating.response
    @post = @response.post
    @message = Message.new
    if @rating.save
      UserMailer.delay.brilliant_email(@response) if @rating.value == 5
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
      params.require(:rating).permit(:response_id, :value)
    end

    def follower_or_author
      response = Response.find(rating_params[:response_id])  # or (params[:rating][:response_id])
      post = response.post
      author = post.user
      unless current_user.id == author.id || current_user.followed_posts.include?(post)
        flash[:info] = "Unauthorized access"
        redirect_to root_path
      end
    end
end