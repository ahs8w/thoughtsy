class ResponsesController < ApplicationController
  before_action :signed_in_user
  before_action :admin_user, only: :destroy

  def index
    @responses = Response.paginate(page: params[:page])
  end

  def new
    @post = Post.where("state == 'unanswered' AND user_id != ?", current_user.id).first
    @author = @post.user
    @response = Response.new
    @post.accept!
  end

  def create
    @response = current_user.responses.build(response_params)
    @post = @response.post
    if @response.save
      @post.answer!
      flash[:success] = "Response sent!"
      redirect_to posts_path
    else
      @author = @post.user    # render doesn't instantiate any variables (on error; need @author for gravatar)
      @post.unanswer!
      render 'new'
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
end