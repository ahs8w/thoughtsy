class ResponsesController < ApplicationController
  before_action :signed_in_user
  before_action :admin_user, only: :destroy
  after_action  :set_tokens, only: :new

  def index
    @responses = Response.paginate(page: params[:page])
  end

  def new
    if current_user.token_id?
      if current_user.token_timer > 24.hours.ago      # 'greater-than' as in 'after'
        @post = Post.find(current_user.token_id)
      else
        @oldpost = Post.find(current_user.token_id)
        expire_all(@oldpost)
        @post = Post.where("state == 'unanswered' AND user_id != ?", current_user.id).first
      end
    else
      @post = Post.where("state == 'unanswered' AND user_id != ?", current_user.id).first
    end
    @author = @post.user
    @response = Response.new
    @post.accept(current_user.id)
  end

  def create
    @response = current_user.responses.build(response_params)
    @post = @response.post
    if @response.save
      answer_all(@post)
      flash[:success] = "Response sent!"
      redirect_to posts_path
    else
      @author = @post.user    # render doesn't instantiate any variables (on error; need @author for gravatar)
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

    def set_tokens
      current_user.set_tokens(@post.id)
    end

    def expire_all(post)
      post.expire!
      current_user.reset_tokens
    end

    def answer_all(post)
      post.answer!
      current_user.reset_tokens
    end
end