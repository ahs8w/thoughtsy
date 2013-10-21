module PostsHelper

## to fix bug that very long words break the layout
    # raw method: prevent Rails from escaping the resulting HTML
    # sanitize method: needed to prevent cross-site scripting
    # ternary operator

  def wrap(content)
    sanitize(raw(content.split.map{ |s| wrap_long_string(s) }.join(' ')))
  end

  def date_time(thought)
    if thought.created_at < 10.days.ago
      thought.created_at.to_formatted_s(:short_ordinal)
    else
      "#{time_ago_in_words(thought.created_at)} ago"
    end
  end

  def wrapped(content)
    truncate(wrap(content), length: 65, separator: ' ')
  end
  
  private

    def wrap_long_string(text, max_width = 30)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text :
                                  text.scan(regex).join(zero_width_space)
    end
end