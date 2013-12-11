class ImagesController < ApplicationController
  def new
    @uploader = Post.new.image
    @uploader.success_action_redirect = new_post_url
  end
end