class ResponsesController < ApplicationController
  before_action :signed_in_user
  before_action :admin_user, only: :destroy
  after_action  :start_response_timer, only: :new

  def index
    @responses = Response.paginate(page: params[:page])
  end

  def new
    if current_user.pending_response_id? && current_user.response_timer > 24.hours.ago
      @post = Post.find(current_user.pending_response_id)
    # elsif current_user.pending_response_id? && current_user.response_timer < 24.hours.ago
    #   @oldpost = Post.find(current_user.pending_response_id)
    #   @oldpost.unanswer!
    #   @post = Post.where("state == 'unanswered' AND user_id != ?", current_user.id).first
    #   current_user.reset_response_and_timer
    else
      @post = Post.where("state == 'unanswered' AND user_id != ?", current_user.id).first
    end
    @author = @post.user
    @response = Response.new
    @post.accept!
  end

  def create
    @response = current_user.responses.build(response_params)
    @post = @response.post
    if current_user.response_timer < 24.hours.ago   #'less-than' as in 'before'
      @post.expire!
      current_user.reset_response_and_timer
      redirect_to root_path
    elsif @response.save
      @post.answer!
      current_user.reset_response_and_timer
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

    def start_response_timer
      current_user.set_response_and_timer(@post.id)
    end
end