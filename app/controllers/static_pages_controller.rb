class StaticPagesController < ApplicationController
  def home
    @post = current_user.posts.build if signed_in?
  end

  def about
  end

  def team
  end

  def contact
  end

  def mockup
    @post = current_user.posts.build if signed_in?
  end
end
