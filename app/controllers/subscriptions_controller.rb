class SubscriptionsController < ApplicationController
  before_action :signed_in_user

  def create
    @post = Post.find(params[:subscription][:post_id])
    current_user.subscribe!(@post)
    flash[:info] = "Thought followed."
    redirect_to post_path(@post)
  end

  def destroy
    @post = Post.find(params[:id])
    current_user.unsubscribe!(@post)
    flash[:info] = "Thought unfollowed."
    redirect_to post_path(@post)
  end
end