class ImagesController < ApplicationController
  include ImagesHelper
  
  def new
    @uploader = Post.new.image
    @uploader.success_action_redirect = new_post_url
    respond_to do |format|
      format.js
      format.html
    end
  end

  def remove
    @key = params[:key]
    remove_image_s3(@key)
    redirect_to new_post_url
  end
end