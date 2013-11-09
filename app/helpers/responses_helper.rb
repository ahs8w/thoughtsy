module ResponsesHelper 

  def post_follower(post)
    current_user.followed_posts.include?(post)
  end

  def author_or_follower(post)
    current_user == post.user || post_follower(post)
  end
end