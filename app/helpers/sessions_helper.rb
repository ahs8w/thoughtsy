module SessionsHelper

## authentication methods
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user    # assignment function
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def current_user=(user)       # syntax for defining an assignment function
    @current_user = user 
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
      # '||=' sets @current_user variable to user w/ corresponding remember_token only if not already set
  end

  def current_user?(user)
    user == current_user
  end

## before filters
  def admin_user
    unless user_admin?
      flash[:info] = "Unauthorized access"
      redirect_to(root_url) 
    end
  end
  
  def user_admin?
    current_user.admin?
  end

  def signed_in_user
    unless signed_in?
      store_location
      flash[:info] = "Please sign in."
      redirect_to signin_url
    end
  end

  def signed_in?
    !current_user.nil?          # signed_in? -> true  if current_user is not nil
  end

  def tokened_responder
    token = current_user.token_id
    unless token == params[:id].to_i || token == params[:post_id].to_i
      flash[:info] = "Unauthorized access"
      redirect_to root_url
    end
  end

  def post_author
    post = Post.find(params[:id])
    redirect_to root_path unless current_user.id == post.user.id
  end

## Friendly Forwarding ##
  
  def redirect_back_or(default)                    # used in 'Users#create' 
    redirect_to(session[:return_to] || default)    # redirects to desired page (if it exists) or default
    session.delete(:return_to)                     # remove stored url so subsequent signins don't render protected page
  end

  def store_location                          # used in 'signed_in_user' before filter
    session[:return_to] = request.url         # stores desired page in session hash
  end
end
