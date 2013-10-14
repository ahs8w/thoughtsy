class SubscriptionsController < ApplicationController
  def create
    @post = Post.find(params[:subscription][:post_id])
    @post.unanswer!
    current_user.subscribe!(@post)
    flash[:success] = "Thought followed."
    redirect_to @post
  end

  def destroy
    @post = Post.find(params[:id])
    current_user.unsubscribe!(@post)
    flash[:success] = "Thought unfollowed."
    redirect_to @post
  end
end