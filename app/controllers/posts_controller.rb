class PostsController < ApplicationController
  before_action :signed_in_user
  before_action :admin_user, only: [:destroy, :index]

  def index
    @posts = Post.where(state: ["unanswered", "pending"]).ascending.paginate(page: params[:page])
  end

  def show
    @post = Post.find(params[:id])
    @rating = Rating.new
    @response = Response.new
    set_tokens_and_state(@post)
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash.now[:success] = "Post created!"
      respond_to do |format|
        format.html { redirect_to root_url }
        format.js { flash.now[:success] = "Post created!" }
      end
    else
      respond_to do |format|
        format.html { render 'static_pages/home' }    # render root_url doesn't work -> template missing!!!!!!
        format.js
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @user = @post.user
    @post.destroy!
    flash.now[:success] = "Post destroyed!"
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def repost
    @post = Post.find(params[:id])
    @post.unanswer!
    flash[:success] = "Thought reposted."
    redirect_to root_url
  end

  private
    def post_params
      params.require(:post).permit(:content)
    end
end