module PostsHelper

  ## to fix bug that very long words break the layout
    # raw method: prevent Rails from escaping the resulting HTML
    # sanitize method: needed to prevent cross-site scripting
    # ternary operator:  boolean?  ?  do one thing  :  (else:) do something else

  def wrap(content)
    sanitize(raw(content.split.map{ |s| wrap_long_string(s) }.join(' ')))
  end
    # split: divides str into substrings based on delimiter(default: whitespace)
    # map: applies wrap_long_string method to each substring(word)

  def custom_format(content)
    simple_format(sanitize(raw(content)))
  end
    # allows for n/ entered into content to be maintained in display
    # doesn't function properly when truncated

  def responded_time(thought)
    if thought.sort_date < 10.days.ago
      thought.sort_date.to_formatted_s(:short_ordinal)
    else
      "#{time_ago_in_words(thought.sort_date)} ago"
    end
  end

  def created_time(thought)
    if thought.created_at < 10.days.ago
      thought.created_at.to_formatted_s(:short_ordinal)
    else
      "#{time_ago_in_words(thought.created_at)} ago"
    end
  end

  def wrapped(content, length)
    truncate(wrap(content), length: length, separator: ' ')
  end

  def not_subscribed(user)
    posts = Post.available(user).includes(:subscription).limit(10)
    a = []
    posts.each do |post|
      unless post.followers.include(user)
        a << post
      end
    end
    a.ascending.first
  end

  private

    def wrap_long_string(text, max_width = 30)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text : text.scan(regex).join(zero_width_space)
    end
      # ZWS html character: white space which renders with zero width
      # scan(regex): breaks text into seperate 30 character strings in an array
      # join(ZWS): joins elements in array by ZWS and returns a string
end