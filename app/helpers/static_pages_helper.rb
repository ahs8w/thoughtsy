module StaticPagesHelper

  if signed_in?
    @post = current_user.posts.build
    if current_user.token_id?                                   # token_id exists
      if current_user.timer_valid                               #   timer valid
        status = 3
        @token_post = Post.find(current_user.token_id)
      else                                                      #   timer expired
        @oldpost = Post.find(current_user.token_id)   
        current_user.reset_tokens     
        @token_post = Post.available(current_user).first
        @oldpost.expire!
        if current_user.posts_available                         #     posts available
          status = 4
        else                                                    #     not available
          status = 5
        end
      end
    else                                                        # no token_id
      @token_post = Post.available(current_user).first
      if current_user.posts_available                           #     posts available
        status = 2
      else                                                      #     not available
        status = 1
      end
    end
  end

## view logics ##
  expire_time = current_user.token_timer + 24.hours

  !current_user.token_id? && !current_user.posts_available #1
    small_message: "There are currently no unanswered posts available.  Get posting!!"
  end
  
  if !current_user.token_id? && current_user.posts_available #2
    button_text: "See a new thought" button_class: "primary"
  end

  if current_user.token_id? #3
    button_text: "Post your response" button_class: "warning"
    small_message: "#{distance_of_time_in_words(Time.zone.now, expire_time)} until your response expires!"
  end

  if !current_user.timer_valid && current_user.posts_available #4
    button_text: "See a new thought" button_class: "danger"
    small_message: "Your response expired #{distance_of_time_in_words_to_now(Time.zone.now, expire_time)} ago.  
              Click the button to get another thought."
  end

  if !current_user.timer_valid && !current_user.posts_available #5
    small_message: "Your response expired #{distance_of_time_in_words_to_now(Time.zone.now, expire_time)} ago.  
              There are currently no unanswered posts available.  Get posting!!"
  end
end
