class ResponsesController < ApplicationController
  before_action :signed_in_user

  def index
    @responses = Response.paginate(page: params[:page])
  end

  def new
    @post = Post.find(params[:post_id])
    @author = @post.user
    @response = Response.new
  end

  def create
    @post = Post.find(params[:post_id])
    @response = current_user.responses.build(response_params)
    if @response.save
      flash[:success] = "Response sent!"
      redirect_to posts_path
    else
      @author = @post.user    # render doesn't instantiate any variables (on error; need @author for gravatar)
      render 'new'
    end
  end

  def destroy
  end

  private

    def response_params
      params.require(:response).permit(:content, :post_id)
    end
end