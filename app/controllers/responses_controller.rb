class ResponsesController < ApplicationController
  before_action :signed_in_user
  before_action :tokened_responder, only: :create

  after_action  :accept_and_set_tokens, only: :new

  def new 
    @post = Post.find(params[:post_id])
    @response = @post.responses.new(key: params[:key])
    @rating = Rating.new
  end

  def show  # Ratings Page #
    @response = Response.find(params[:id])
    @post = @response.post
    @rating = Rating.new
  end

  def create
    @response = current_user.responses.build(response_params)
    @post = Post.find(params[:post_id])
    if @response.save
      @response.enqueue_image
      @response.update_all
      flash[:success] = "Response sent!"
      redirect_to posts_path
    else
      @post
      @rating = Rating.new
      render 'new'
    end
  end

private

  def response_params
    params.require(:response).permit(:content, :post_id, :image, :key)
  end

  def accept_and_set_tokens
    post = Post.find(params[:post_id])
    current_user.set_tokens(post.id)
    post.accept!
    post.add_unavailable_users(current_user)
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