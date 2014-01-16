class PostsController < ApplicationController
  before_action :signed_in_user, except: :index
  before_action :admin_user, only: [:destroy, :queue]
  before_action :tokened_responder, only: :flag

  def queue
    @posts = Post.where.not(state: "unqueued").ascending.paginate(page: params[:page])
  end

  def new
    @post = Post.new(key: params[:key])
  end

  def index
    @posts = Post.answered.descending.paginate(page: params[:page], :per_page => 20)
  end

  def show
    @post = Post.find(params[:id])
    @responses = @post.responses.descending
    @rating = Rating.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      @post.enqueue_image
      flash[:success] = "Post created!"
      redirect_to root_url
    else
      render 'new'
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @user = @post.user
    @post.destroy!
    flash[:success] = "Post destroyed!"
    respond_to do |format|
      format.html { redirect_to :queue }
      format.js 
    end
  end

# Response#New #
  def flag
    @post = Post.find(params[:id])
    @token_post = Post.answerable(current_user).ascending.first
    @post.flag!       # sends flag_email on transition
    current_user.reset_tokens
    flash[:warning] = "Thought flagged."
    if @token_post
      redirect_to new_post_response_path(@token_post)
    else
      redirect_to root_url
    end
  end

  def language
    @post = Post.find(params[:id])
    @token_post = Post.answerable(current_user).ascending.first
    @post.expire!
    current_user.reset_tokens
    flash[:info] = "Thought reposted."
    if @token_post
      redirect_to new_post_response_path(@token_post)
    else
      redirect_to root_url
    end
  end
#

  private
    def post_params
      params.require(:post).permit(:content, :image, :key)
    end

    def rollback_tokens
      current_user.reset_tokens if signed_in? && !current_user.timer_valid
    end
end