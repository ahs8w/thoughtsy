class ImagesController < ApplicationController
  include ImagesHelper
    
  def new
    if params[:post_id]                       # -> Response
      @post = Post.find(params[:post_id])
      @uploader = Response.new.image
      @uploader.success_action_redirect = new_post_response_url(@post)
    else
      @uploader = Post.new.image
      @uploader.success_action_redirect = new_post_url
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def remove
    @key = params[:key]
    remove_image_s3(@key)
    if params[:post_id]                       # -> Response
      redirect_to new_post_response_url(params[:post_id])
    else
      redirect_to new_post_url
    end
  end
end
