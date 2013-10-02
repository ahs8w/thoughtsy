module StaticPagesHelper
  include ActionView::Helpers::DateHelper
## view logics ##
  def expiration
    expire_time = current_user.token_timer + 24.hours
    distance_of_time_in_words(Time.zone.now, expire_time)
  end

  # no tokens && no available posts
  def output_1
    @small_message = "There are currently no unanswered posts available.  Get posting!!"
  end
  
  # no tokens && available posts
  def output_2
    @button_text = "See a new thought" 
    @button_class = "primary"
  end

  # valid timer
  def output_3
    @button_text = "Post your response" 
    @button_class = "warning"
    @small_message = "#{expiration} until your response expires!"
  end

  # timer expired && available posts
  def output_4
    @button_text = "See a new thought" 
    @button_class = "danger"
    @small_message = "Your response expired #{expiration} ago.  
    Click the button to get another thought."
  end

  # timer expired && no available posts
  def output_5
    @small_message = "Your response expired #{expiration} ago.  
    There are currently no unanswered posts available.  Get posting!!"
  end
end
