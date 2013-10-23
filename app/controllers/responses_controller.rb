class ResponsesController < ApplicationController
  before_action :signed_in_user
  before_action :admin_user, only: :destroy
  before_action :author_or_follower, only: :show
  before_action :tokened_responder, only: :create
  before_action :set_tokens_and_state, only: :new


  # def index         # post/id/responses
  #   @post = Post.find(params[:post_id])
  #   @responses = @post.responses.ascending.paginate(page: params[:page])
  # end

  def new 
    @post = Post.find(params[:post_id])
    @response = Response.new
  end

# Ratings Page #
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
      send_response_emails(@response)
      flash[:success] = "Response sent!"
      redirect_to posts_path
    else
      @post = Post.find(params[:post_id])
      render 'new'
    end
  end

  def destroy
    @response = Response.find(params[:id])
    @post = @response.post
    @post.unanswer!
    @response.destroy
    flash[:success] = "Response destroyed!"
    redirect_to post_responses_path(@post)
  end

  private
    def response_params
      params.require(:response).permit(:content, :post_id)
    end

    def answer_all(post)
      post.answer!
      current_user.reset_tokens
    end

    def send_response_emails(response)
      UserMailer.response_email(response).deliver
      UserMailer.follower_response_email(response).deliver unless response.post.followers.empty?
    end

    def set_tokens_and_state
      post = Post.find(params[:post_id])
      post.accept! unless current_user.token_id == post.id
      current_user.set_tokens(post.id)
    end

    # def correct_responder
    #   redirect_to(root_url) unless current_user.token_id == params[:id].to_i
    # end
end