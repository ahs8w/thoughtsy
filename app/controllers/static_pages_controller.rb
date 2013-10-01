class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @post = current_user.posts.build
      if current_user.token_id?
        if current_user.timer_valid                     # token_timer is valid:
          @token_post = Post.find(current_user.token_id)
        else                                            # token_timer is expired:
          @oldpost = Post.find(current_user.token_id)   
          current_user.reset_tokens     
          @token_post = Post.available(current_user).first
          @oldpost.expire!            ## wait on :expire! to ensure a new post is selected
        end
      else
        @token_post = Post.available(current_user).first
      end
    end
  end

  def about
  end

  def team
  end

  def contact
  end
end
