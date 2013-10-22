class PostsController < ApplicationController
  before_action :signed_in_user
  before_action :admin_user, only: [:destroy, :index]
  # before_action :set_tokens_and_state, :correct_responder, only: :show

  def index
    @posts = Post.where(state: ["unanswered", "pending", "flagged"]).ascending.paginate(page: params[:page])
  end

  # def show
  #   @post = Post.find(params[:id])
  #   @rating = Rating.new
  #   @response = Response.new
  # end

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
        format.html { render partial: 'static_pages/post_form' }    # render root_url doesn't work -> template missing!!!!!!
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

  def flag
    @post = Post.find(params[:id])
    @token_post = Post.available(current_user).ascending.first
    @post.flag!       # sends flag_email on transition
    current_user.reset_tokens
    respond_to do |format|
      format.html do
        flash[:notice] = "Post flagged."
        redirect_to new_post_response_path(@token_post)
      end
      format.js { flash.now[:notice] = "Post flagged." }
    end
  end

  private
    def post_params
      params.require(:post).permit(:content)
    end

    # def set_tokens_and_state
    #   post = Post.find(params[:id])
    #   post.accept! unless current_user.token_id == post.id
    #   current_user.set_tokens(post.id)
    # end
end