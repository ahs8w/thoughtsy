class StaticPagesController < ApplicationController
  include StaticPagesHelper

  def home
    if signed_in?
      @post = Post.new
      if current_user.token_id?                                   # token_id exists
        if current_user.timer_valid                               #   timer valid
          output_3
          @token_post = Post.find(current_user.token_id)
        else                                                      #   timer expired   
          if current_user.posts_available                         #     posts available
            output_4
          else                                                    #     not available
            output_5
          end
          @oldpost = Post.find(current_user.token_id)
          # can't reset_tokens here because it sets off Post validation error
          @token_post = Post.answerable(current_user).ascending.first
          @oldpost.expire! unless @oldpost.state == 'answered' || @oldpost.state == 'reposted'
          user_expire_effects
        end
      else                                                        # no token_id
        @token_post = Post.answerable(current_user).ascending.first
        if current_user.posts_available                           #     posts available
          output_2
        else                                                      #     not available
          output_1
        end
      end
    end
  end

  def about
  end

  def team
  end

  def contact
  end

private
  def user_expire_effects
    current_user.reset_tokens
    current_user.update_score!(-3)
    @oldpost.add_unavailable_users(current_user)
  end
end
