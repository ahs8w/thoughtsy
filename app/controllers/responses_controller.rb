class ResponsesController < ApplicationController
  before_action :signed_in_user
  before_action :admin_user, only: :destroy

  def index
    @responses = Response.descending.paginate(page: params[:page])
  end

  def show
    @response = Response.find(params[:id])
    @rateable = @response
    @rating = Rating.new
    @post = @response.post
  end

  def create
    @response = current_user.responses.build(response_params)
    @post = @response.post
    if @response.save
      answer_all(@post)
      flash[:success] = "Response sent!"
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js
      end
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