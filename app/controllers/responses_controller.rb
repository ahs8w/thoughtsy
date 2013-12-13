class ResponsesController < ApplicationController
  before_action :signed_in_user
  before_action :tokened_responder, only: :create
  before_action :set_user_tokens, only: :new

  def new 
    @post = Post.find(params[:post_id])
    @post.accept!
    @response = @post.responses.new(key: params[:key])
    unless @response.filename_valid?
      flash[:danger] = @response.errors.full_messages.to_sentence
      redirect_to 'new'
    end
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
      params.require(:response).permit(:content, :post_id, :image)
    end

    def set_user_tokens
      post = Post.find(params[:post_id])
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