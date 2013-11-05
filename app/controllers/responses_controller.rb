class ResponsesController < ApplicationController
  before_action :signed_in_user
  before_action :author_or_follower, only: :show
  before_action :tokened_responder, only: :create
  before_action :set_tokens_and_state, only: :new

  def new 
    @post = Post.find(params[:post_id])
    @response = @post.responses.new
    @post.set_expiration_timer
  end

  def show
    # Ratings Page #
    @response = Response.find(params[:id])
    @post = @response.post
    @rating = Rating.new
  end

  def create
    @response = current_user.responses.build(response_params)
    @post = @response.post
    if @response.save
      flash[:success] = "Response sent!"
      redirect_to post_path(@post)
    else
      @post = Post.find(params[:post_id])
      render 'new'
    end
  end

  private
    def response_params
      params.require(:response).permit(:content, :post_id, :image, :remote_image_url)
    end

    def set_tokens_and_state
      post = Post.find(params[:post_id])
      post.accept! unless current_user.token_id == post.id
      current_user.set_tokens(post.id)
    end
end


# before_action :admin_user, only: :destroy

# def destroy
#   @response = Response.find(params[:id])
#   @post = @response.post
#   # @post.unanswer!
#   @response.destroy
#   flash[:success] = "Response destroyed!"
#   redirect_to post_path(@post)
# end