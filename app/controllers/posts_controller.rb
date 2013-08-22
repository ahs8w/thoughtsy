class PostsController < ApplicationController
  before_action :signed_in_user
  before_action :admin_user, only: :destroy

  def index
    @posts = Post.paginate(page: params[:page])
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = "Post created!"
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end

  def destroy
    Post.find(params[:id]).destroy
    flash[:success] = "Post destroyed."
    redirect_to :back
  end


  private

    def post_params
      params.require(:post).permit(:content)
    end
end