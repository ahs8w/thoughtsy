class ResponsesController < ApplicationController
  before_action :signed_in_user
  before_action :admin_user, only: :destroy

  def index
    @responses = Response.descending.paginate(page: params[:page])
  end

  def show
    @response = Response.find(params[:id])
    @post = @response.post
    @rating = Rating.new
  end

  def create
    @response = current_user.responses.build(response_params)
    @post = @response.post
    if @response.save
      answer_all(@post)
      # email @post.user and @post.followers
      flash[:success] = "Response sent!"
      redirect_to response_path(@response)
    else
      @rateable = @post
      @rating = Rating.new
      render 'posts/show'
    end
  end

  def destroy
    @response = Response.find(params[:id])
    @response.post.unanswer!
    @response.destroy
    flash[:success] = "Response destroyed!"
    redirect_to responses_path
  end

  private
    def response_params
      params.require(:response).permit(:content, :post_id)
    end

    def answer_all(post)
      post.answer!
      current_user.reset_tokens
    end
end