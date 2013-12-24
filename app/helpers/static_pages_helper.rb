module StaticPagesHelper
  include ActionView::Helpers::DateHelper
## view logics ##
  def expiration
    expire_time = current_user.token_timer + 24.hours
    distance_of_time_in_words(Time.zone.now, expire_time)
  end

  # no tokens && no available posts
  def output_1
    @button = false
    @small_message = "There are currently no unanswered posts available.  Get posting!!"
  end
  
  # no tokens && available posts
  def output_2
    @button = true
  end

  # valid timer
  def output_3
    @button = true
    @small_message = "#{expiration} until your response expires!"
  end

  # timer expired && available posts
  def output_4
    @button = true
    @small_message = "Your response expired #{expiration} ago.
    Click the button to get another thought."
  end

  # timer expired && no available posts
  def output_5
    @button = false
    @small_message = "Your response expired #{expiration} ago.  
    There are currently no unanswered posts available.  Get posting!!"
  end

## Team ##

  def gravatar_adam(options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest('ahs8w@virginia.edu')
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: "Adam Schiller", class: "gravatar")
  end
end
